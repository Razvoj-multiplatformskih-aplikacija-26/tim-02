part of 'lineups_bloc.dart';

sealed class LineupsEvent {
  const LineupsEvent();
}

final class LineupsRequested extends LineupsEvent {
  const LineupsRequested();
}

final class LineupSaved extends LineupsEvent {
  const LineupSaved(this.lineup);

  final PersonalLineup lineup;
}

final class LineupDeleted extends LineupsEvent {
  const LineupDeleted(this.id);

  final LineupId id;
}
