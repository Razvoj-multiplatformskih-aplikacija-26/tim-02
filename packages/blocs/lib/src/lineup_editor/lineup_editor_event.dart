part of 'lineup_editor_bloc.dart';

sealed class LineupEditorEvent {
  const LineupEditorEvent();
}

final class LineupNameChanged extends LineupEditorEvent {
  const LineupNameChanged(this.text);

  final String text;
}

final class LineupHexChosen extends LineupEditorEvent {
  const LineupHexChosen(this.position);

  final HexPosition position;
}

final class LineupUnitChanged extends LineupEditorEvent {
  const LineupUnitChanged({this.champion, this.stars});

  final Champion? champion;
  final int? stars;
}

final class LineupItemAdded extends LineupEditorEvent {
  const LineupItemAdded(this.item);

  final Item item;
}

final class LineupItemRemoved extends LineupEditorEvent {
  const LineupItemRemoved(this.index);

  final int index;
}

final class LineupChampionPlaced extends LineupEditorEvent {
  const LineupChampionPlaced();
}

final class LineupChampionRemoved extends LineupEditorEvent {
  const LineupChampionRemoved(this.position);

  final HexPosition position;
}

final class LineupChampionMoved extends LineupEditorEvent {
  const LineupChampionMoved(this.from, this.to);

  final HexPosition from;
  final HexPosition to;
}

final class LineupChampionRestored extends LineupEditorEvent {
  const LineupChampionRestored(this.placement);

  final Placement placement;
}

final class LineupEditorSubmitted extends LineupEditorEvent {
  const LineupEditorSubmitted();
}

final class LineupEditorDeleted extends LineupEditorEvent {
  const LineupEditorDeleted();
}
