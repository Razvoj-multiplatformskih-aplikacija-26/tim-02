import 'package:equatable/equatable.dart';

import 'identifiers.dart';

final class Champion extends Equatable {
  const Champion({required this.id, required this.name, required this.cost});

  final ChampionId id;
  final String name;
  final int cost;

  @override
  List<Object?> get props => [id, name, cost];
}
