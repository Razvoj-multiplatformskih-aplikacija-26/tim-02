part of 'tactic_editor_bloc.dart';

sealed class TacticEditorEvent {
  const TacticEditorEvent();
}

final class TacticEditorStarted extends TacticEditorEvent {
  const TacticEditorStarted();
}

final class TacticTitleChanged extends TacticEditorEvent {
  const TacticTitleChanged(this.text);

  final String text;
}

final class TacticDescriptionChanged extends TacticEditorEvent {
  const TacticDescriptionChanged(this.text);

  final String text;
}

final class TacticVariantChosen extends TacticEditorEvent {
  const TacticVariantChosen(this.index);

  final int index;
}

final class TacticPhaseChosen extends TacticEditorEvent {
  const TacticPhaseChosen({required this.early});

  final bool early;
}

final class TacticHexChosen extends TacticEditorEvent {
  const TacticHexChosen(this.position);

  final HexPosition position;
}

final class TacticUnitChanged extends TacticEditorEvent {
  const TacticUnitChanged({this.champion, this.stars});

  final Champion? champion;
  final int? stars;
}

final class TacticItemAdded extends TacticEditorEvent {
  const TacticItemAdded(this.item);

  final Item item;
}

final class TacticItemRemoved extends TacticEditorEvent {
  const TacticItemRemoved(this.index);

  final int index;
}

final class TacticUnitPlaced extends TacticEditorEvent {
  const TacticUnitPlaced();
}

final class TacticUnitRemoved extends TacticEditorEvent {
  const TacticUnitRemoved();
}

final class TacticUnitMoved extends TacticEditorEvent {
  const TacticUnitMoved(this.from, this.to);

  final HexPosition from;
  final HexPosition to;
}

final class TacticFlexAdded extends TacticEditorEvent {
  const TacticFlexAdded(this.champion);

  final Champion champion;
}

final class TacticFlexRemoved extends TacticEditorEvent {
  const TacticFlexRemoved(this.index);

  final int index;
}

final class TacticPriorityAdded extends TacticEditorEvent {
  const TacticPriorityAdded(this.item);

  final Item item;
}

final class TacticPriorityRemoved extends TacticEditorEvent {
  const TacticPriorityRemoved(this.index);

  final int index;
}

final class TacticTipChanged extends TacticEditorEvent {
  const TacticTipChanged(this.text);

  final String text;
}

final class TacticStageTipChanged extends TacticEditorEvent {
  const TacticStageTipChanged(this.stage, this.text);

  final int stage;
  final String text;
}

final class TacticEditorSubmitted extends TacticEditorEvent {
  const TacticEditorSubmitted();
}
