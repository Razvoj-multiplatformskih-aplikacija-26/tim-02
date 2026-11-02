part of 'lineup_editor_bloc.dart';

sealed class LineupEditorEvent {
  const LineupEditorEvent();
}

final class LineupNameChanged extends LineupEditorEvent {
  const LineupNameChanged(this.text);

  final String text;
}

final class LineupUnitChanged extends LineupEditorEvent {
  const LineupUnitChanged({this.champion, this.row, this.column});

  final Champion? champion;
  final int? row;
  final int? column;
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

final class LineupEditorSubmitted extends LineupEditorEvent {
  const LineupEditorSubmitted();
}
