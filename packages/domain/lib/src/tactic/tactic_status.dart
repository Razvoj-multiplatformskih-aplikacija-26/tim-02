import 'package:equatable/equatable.dart';

import '../identifiers.dart';
import 'hide_reason.dart';

enum TacticStatusKind { draft, published, hidden, archived }

sealed class TacticStatus extends Equatable {
  const TacticStatus();

  TacticStatusKind get kind => switch (this) {
    Draft() => TacticStatusKind.draft,
    Published() => TacticStatusKind.published,
    Hidden() => TacticStatusKind.hidden,
    Archived() => TacticStatusKind.archived,
  };

  @override
  List<Object?> get props => const [];
}

final class Draft extends TacticStatus {
  const Draft();
}

final class Published extends TacticStatus {
  const Published({required this.at});

  final DateTime at;

  @override
  List<Object?> get props => [at];
}

final class Hidden extends TacticStatus {
  const Hidden({required this.reason, required this.by, required this.at});

  final HideReason reason;
  final UserId by;
  final DateTime at;

  @override
  List<Object?> get props => [reason, by, at];
}

final class Archived extends TacticStatus {
  const Archived({required this.at});

  final DateTime at;

  @override
  List<Object?> get props => [at];
}
