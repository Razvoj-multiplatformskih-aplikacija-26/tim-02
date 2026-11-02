part of 'lineup_editor_bloc.dart';

enum LineupEditorStatus { editing, saving, saved, failed }

final class LineupEditorState extends Equatable {
  const LineupEditorState({
    this.id,
    this.basedOn,
    this.name,
    this.lineup = const Lineup.empty(),
    this.champion,
    this.row,
    this.column,
    this.items = const [],
    this.status = LineupEditorStatus.editing,
    this.saved,
  });

  LineupEditorState.edit(PersonalLineup lineup)
    : this(id: lineup.id, basedOn: lineup.basedOn, name: lineup.name.text, lineup: lineup.lineup);

  LineupEditorState.fromVariant(TacticId tactic, TacticVariant variant)
    : this(basedOn: tactic, name: variant.name, lineup: variant.lineup);

  final LineupId? id;
  final TacticId? basedOn;
  final String? name;
  final Lineup lineup;
  final Champion? champion;
  final int? row;
  final int? column;
  final List<Item> items;
  final LineupEditorStatus status;
  final PersonalLineup? saved;

  @override
  List<Object?> get props => [id, basedOn, name, lineup, champion, row, column, items, status, saved];

  @override
  String toString() =>
      'LineupEditorState(${lineup.placements.length} champions, ${items.length} items, ${status.name})';

  DomainError? get nameError => switch (name) {
    null => null,
    final name => LineupName.parse(name).errorOrNull,
  };

  Result<Lineup>? get placed {
    final champion = this.champion;
    if (champion == null) return null;
    return switch ((Unit.parse(champion, items: items), row, column)) {
      (Failure(:final error), _, _) => Failure(error),
      (Success(value: final unit), final row?, final column?) => switch (HexPosition.parse(row, column)) {
        Success(value: final position) => lineup.place(Placement(unit: unit, position: position)),
        Failure(:final error) => Failure(error),
      },
      _ => null,
    };
  }

  LineupEditorState copyWith({
    String? name,
    Lineup? lineup,
    Champion? champion,
    int? row,
    int? column,
    List<Item>? items,
    LineupEditorStatus? status,
    PersonalLineup? saved,
  }) => LineupEditorState(
    id: id,
    basedOn: basedOn,
    name: name ?? this.name,
    lineup: lineup ?? this.lineup,
    champion: champion ?? this.champion,
    row: row ?? this.row,
    column: column ?? this.column,
    items: items ?? this.items,
    status: status ?? this.status,
    saved: saved ?? this.saved,
  );
}
