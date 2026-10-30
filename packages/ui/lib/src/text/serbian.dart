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
