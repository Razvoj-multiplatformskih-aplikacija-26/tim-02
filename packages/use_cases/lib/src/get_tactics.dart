import 'package:domain/domain.dart';

import 'ports/tactic_repository.dart';

final class GetTactics {
  const GetTactics({required this.tactics});

  final TacticRepository tactics;

  Future<List<Tactic>> call(User user) async => visibleTactics(await tactics.all(), user);
}
