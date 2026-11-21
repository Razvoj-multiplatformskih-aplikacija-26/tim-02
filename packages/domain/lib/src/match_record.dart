import 'package:equatable/equatable.dart';

import 'identifiers.dart';

final class MatchBoard extends Equatable {
  const MatchBoard({required this.placement, required this.champions});

  final int placement;
  final List<ChampionId> champions;

  @override
  List<Object?> get props => [placement, champions];
}

final class MatchRecord extends Equatable {
  const MatchRecord({required this.id, required this.patch, required this.playedAt, required this.boards});

  final MatchId id;
  final PatchId patch;
  final DateTime playedAt;
  final List<MatchBoard> boards;

  @override
  List<Object?> get props => [id, patch, playedAt, boards];
}
