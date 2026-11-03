import 'package:equatable/equatable.dart';

import '../catalog.dart';
import '../lineup/lineup.dart';

enum Playstyle { fast9, fast8, reroll1, reroll2, reroll3, loseStreak }

enum Difficulty { easy, medium, hard }

final class TacticVariant extends Equatable {
  const TacticVariant({
    required this.name,
    required this.playstyle,
    required this.difficulty,
    required this.early,
    required this.lineup,
    required this.flex,
    required this.itemPriority,
    required this.tip,
    required this.stageTips,
  });

  final String name;
  final Playstyle playstyle;
  final Difficulty difficulty;
  final Lineup early;
  final Lineup lineup;
  final List<Unit> flex;
  final List<Item> itemPriority;
  final String tip;
  final Map<int, String> stageTips;

  @override
  List<Object?> get props => [name, playstyle, difficulty, early, lineup, flex, itemPriority, tip, stageTips];
}
