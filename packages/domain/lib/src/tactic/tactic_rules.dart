import '../errors.dart';
import '../result.dart';
import '../user.dart';
import 'hide_reason.dart';
import 'tactic.dart';
import 'tactic_status.dart';

enum TacticAction { archive, publish, hide, restore }

abstract final class AccessPolicy {
  static bool canView(User user, Tactic tactic) =>
      user.role == Role.admin || tactic.authorId == user.id || tactic.status is Published;

  static bool canArchive(User user, Tactic tactic) => tactic.authorId == user.id;

  static bool canPublish(User user, Tactic tactic) => user.role == Role.creator && tactic.authorId == user.id;

  static bool canModerate(User user) => user.role == Role.admin;
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

final _anyReason = HideReason.parse('Provera dozvole').valueOrNull!;

Set<TacticAction> allowedActions(Tactic tactic, User user, {required DateTime now}) => {
  if (archiveTactic(tactic, by: user, now: now).isSuccess) TacticAction.archive,
  if (publishTactic(tactic, by: user, now: now).isSuccess) TacticAction.publish,
  if (hideTactic(tactic, by: user, reason: _anyReason, now: now).isSuccess) TacticAction.hide,
  if (restoreTactic(tactic, by: user, now: now).isSuccess) TacticAction.restore,
};
