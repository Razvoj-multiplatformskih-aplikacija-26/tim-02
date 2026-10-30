import 'package:domain/domain.dart';

import 'ports/tactic_repository.dart';

final class GetTierList {
  const GetTierList({required this.tactics});

  final TacticRepository tactics;

  Future<TierList> call() => tactics.currentTierList();
}
