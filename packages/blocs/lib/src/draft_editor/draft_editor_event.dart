part of 'draft_editor_bloc.dart';

sealed class DraftEditorEvent {
  const DraftEditorEvent();
}

final class DraftEditorStarted extends DraftEditorEvent {
  const DraftEditorStarted();
}

final class DraftTitleChanged extends DraftEditorEvent {
  const DraftTitleChanged(this.text);

  final String text;
}

final class DraftHexChosen extends DraftEditorEvent {
  const DraftHexChosen(this.position);

  final HexPosition position;
}

final class DraftUnitChanged extends DraftEditorEvent {
  const DraftUnitChanged({this.champion, this.stars});

  final Champion? champion;
  final int? stars;
}

final class DraftItemAdded extends DraftEditorEvent {
  const DraftItemAdded(this.item);

  final Item item;
}

final class DraftItemRemoved extends DraftEditorEvent {
  const DraftItemRemoved(this.index);

  final int index;
}

final class DraftChampionPlaced extends DraftEditorEvent {
  const DraftChampionPlaced();
}

final class DraftChampionRemoved extends DraftEditorEvent {
  const DraftChampionRemoved(this.position);

  final HexPosition position;
}

final class DraftChampionMoved extends DraftEditorEvent {
  const DraftChampionMoved(this.from, this.to);

  final HexPosition from;
  final HexPosition to;
}

final class DraftChampionRestored extends DraftEditorEvent {
  const DraftChampionRestored(this.placement);

  final Placement placement;
}

final class DraftEditorSubmitted extends DraftEditorEvent {
  const DraftEditorSubmitted();
}

final class DraftEditorDeleted extends DraftEditorEvent {
  const DraftEditorDeleted();
}
