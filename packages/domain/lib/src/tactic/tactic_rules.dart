import '../user.dart';
import 'tactic.dart';
import 'tactic_status.dart';

abstract final class AccessPolicy {
  static bool canView(User user, Tactic tactic) =>
      user.role == Role.admin || tactic.authorId == user.id || tactic.status is Published;
}

List<Tactic> visibleTactics(Iterable<Tactic> tactics, User user) =>
    tactics.where((t) => AccessPolicy.canView(user, t)).toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
