import '../errors.dart';
import '../result.dart';
import '../user.dart';
import 'tactic.dart';
import 'tactic_status.dart';

enum TacticAction { archive }

abstract final class AccessPolicy {
  static bool canView(User user, Tactic tactic) =>
      user.role == Role.admin || tactic.authorId == user.id || tactic.status is Published;

  static bool canArchive(User user, Tactic tactic) => tactic.authorId == user.id;
}

List<Tactic> visibleTactics(Iterable<Tactic> tactics, User user) =>
    tactics.where((t) => AccessPolicy.canView(user, t)).toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

Result<Tactic> archiveTactic(Tactic tactic, {required User by, required DateTime now}) {
  if (!AccessPolicy.canArchive(by, tactic)) return const Failure(NotAllowed());
  final next = Archived(at: now.toUtc());
  if (!canTransition(tactic.status, next)) return Failure(InvalidTransition(from: tactic.status, to: next));
  return Success(tactic.copyWith(status: next, updatedAt: now.toUtc()));
}

Set<TacticAction> allowedActions(Tactic tactic, User user, {required DateTime now}) => {
  if (archiveTactic(tactic, by: user, now: now).isSuccess) TacticAction.archive,
};
