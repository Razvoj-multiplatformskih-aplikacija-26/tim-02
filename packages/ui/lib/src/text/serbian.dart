import 'package:domain/domain.dart';
import 'package:intl/intl.dart';

const serbianLatin = 'sr_Latn';

final _date = DateFormat('d. MMMM y.', serbianLatin);

String formatDate(DateTime instant) => _date.format(instant.toLocal());

extension TierLabel on Tier {
  String get label => switch (this) {
    Tier.s => 'S',
    Tier.a => 'A',
    Tier.b => 'B',
    Tier.c => 'C',
    Tier.situational => 'Situaciona',
  };
}

extension TacticStatusKindLabel on TacticStatusKind {
  String get label => switch (this) {
    TacticStatusKind.draft => 'Nacrti',
    TacticStatusKind.published => 'Objavljene',
    TacticStatusKind.hidden => 'Sakrivene',
    TacticStatusKind.archived => 'Arhivirane',
  };
}

extension PlaystyleLabel on Playstyle {
  String get label => switch (this) {
    Playstyle.fast9 => 'Brzi nivo 9',
    Playstyle.fast8 => 'Brzi nivo 8',
    Playstyle.reroll1 => 'Reroll na trošku 1',
    Playstyle.reroll2 => 'Reroll na trošku 2',
    Playstyle.reroll3 => 'Reroll na trošku 3',
  };
}

extension DifficultyLabel on Difficulty {
  String get label => switch (this) {
    Difficulty.easy => 'Lako',
    Difficulty.medium => 'Srednje',
    Difficulty.hard => 'Teško',
  };
}

extension TacticActionText on TacticAction {
  String get label => switch (this) {
    TacticAction.archive => 'Arhiviraj',
  };

  String get doneMessage => switch (this) {
    TacticAction.archive => 'Taktika je arhivirana.',
  };
}

String formatChampionCount(int count) => '$count ${count % 10 == 1 && count % 100 != 11 ? 'šampion' : 'šampiona'}';
