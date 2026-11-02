import 'package:equatable/equatable.dart';

import '../identifiers.dart';
import 'lineup.dart';
import 'lineup_name.dart';

final class PersonalLineup extends Equatable {
  const PersonalLineup({required this.id, required this.name, required this.lineup, this.basedOn});

  final LineupId id;
  final LineupName name;
  final Lineup lineup;
  final TacticId? basedOn;

  @override
  List<Object?> get props => [id, name, lineup, basedOn];
}
