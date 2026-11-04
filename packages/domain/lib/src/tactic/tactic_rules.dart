import '../errors.dart';
import '../result.dart';
import '../user.dart';
import 'hide_reason.dart';
import 'tactic.dart';
import 'tactic_status.dart';
import 'tactic_variant.dart';
import 'tier_list.dart';

enum TacticAction { archive, publish, hide, restore }

abstract final class AccessPolicy {
  static bool canView(User user, Tactic tactic) =>
      user.role == Role.admin || tactic.authorId == user.id || tactic.status is Published;

  static bool canArchive(User user, Tactic tactic) => tactic.authorId == user.id;

  static bool canPublish(User user, Tactic tactic) => user.role == Role.creator && tactic.authorId == user.id;

  static bool canModerate(User user) => user.role == Role.admin;

  static bool canEdit(User user, Tactic tactic) => user.role == Role.admin || tactic.authorId == user.id;
}

List<Tactic> visibleTactics(Iterable<Tactic> tactics, User user) =>
    tactics.where((t) => AccessPolicy.canView(user, t)).toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

Result<Tactic> archiveTactic(Tactic tactic, {required User by, required DateTime now}) {
  if (!AccessPolicy.canArchive(by, tactic)) return const Failure(NotAllowed());
  final next = Archived(at: now.toUtc());
  if (!canTransition(tactic.status, next)) return Failure(InvalidTransition(from: tactic.status, to: next));
  return Success(tactic.copyWith(status: next, updatedAt: now.toUtc()));
}

Result<Tactic> publishTactic(Tactic tactic, {required User by, required DateTime now}) {
  if (!AccessPolicy.canPublish(by, tactic)) return const Failure(NotAllowed());
  if (tactic.status is Hidden) return const Failure(HiddenByAdmin());
  final next = Published(at: now.toUtc());
  if (!canTransition(tactic.status, next)) return Failure(InvalidTransition(from: tactic.status, to: next));
  return Success(tactic.copyWith(status: next, updatedAt: now.toUtc()));
}

Result<Tactic> hideTactic(Tactic tactic, {required User by, required HideReason reason, required DateTime now}) {
  if (!AccessPolicy.canModerate(by)) return const Failure(NotAllowed());
  final next = Hidden(reason: reason, by: by.id, at: now.toUtc());
  if (!canTransition(tactic.status, next)) return Failure(InvalidTransition(from: tactic.status, to: next));
  return Success(tactic.copyWith(status: next, updatedAt: now.toUtc()));
}

Result<Tactic> restoreTactic(Tactic tactic, {required User by, required DateTime now}) {
  if (!AccessPolicy.canModerate(by)) return const Failure(NotAllowed());
  final next = Published(at: now.toUtc());
  if (tactic.status is! Hidden) return Failure(InvalidTransition(from: tactic.status, to: next));
  return Success(tactic.copyWith(status: next, updatedAt: now.toUtc()));
}

Result<Tactic> editTactic(
  Tactic tactic, {
  required User by,
  required String title,
  required String description,
  required List<TacticVariant> variants,
  required DateTime now,
}) {
  if (!AccessPolicy.canEdit(by, tactic)) return const Failure(NotAllowed());
  if (tactic.status is Archived) return const Failure(TacticArchived());
  return switch (Tactic.parseTitle(title)) {
    Failure(:final error) => Failure(error),
    _ when variants.isEmpty || variants.any((v) => v.lineup.placements.isEmpty) => const Failure(EmptyBoard()),
    Success(value: final title) => Success(
      tactic.copyWith(title: title, description: description.trim(), variants: variants, updatedAt: now.toUtc()),
    ),
  };
}

bool mayEdit(Tactic tactic, User user) => AccessPolicy.canEdit(user, tactic) && tactic.status is! Archived;

Result<TierList> placeTactic(TierList tierList, Tactic tactic, {required Tier? tier, required User by}) {
  if (!AccessPolicy.canModerate(by)) return const Failure(NotAllowed());
  if (tactic.status is! Published) return const Failure(NotPlaceable());
  return Success(tierList.place(tactic.id, tier));
}

bool mayPlace(Tactic tactic, User user) => AccessPolicy.canModerate(user) && tactic.status is Published;

final _anyReason = HideReason.parse('Provera dozvole').valueOrNull!;

Set<TacticAction> allowedActions(Tactic tactic, User user, {required DateTime now}) => {
  if (archiveTactic(tactic, by: user, now: now).isSuccess) TacticAction.archive,
  if (publishTactic(tactic, by: user, now: now).isSuccess) TacticAction.publish,
  if (hideTactic(tactic, by: user, reason: _anyReason, now: now).isSuccess) TacticAction.hide,
  if (restoreTactic(tactic, by: user, now: now).isSuccess) TacticAction.restore,
};
