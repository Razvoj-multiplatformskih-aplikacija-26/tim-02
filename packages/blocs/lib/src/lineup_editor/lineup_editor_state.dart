part of 'lineup_editor_bloc.dart';

enum LineupEditorStatus { editing, saving, saved, deleted, failed }

final class LineupEditorState extends Equatable {
  const LineupEditorState({
    this.id,
    this.basedOn,
    this.name,
    this.startName,
    this.lineup = const Lineup.empty(),
    this.startLineup = const Lineup.empty(),
    this.hex,
    this.champion,
    this.stars = 1,
    this.items = const [],
    this.status = LineupEditorStatus.editing,
    this.saved,
  });

  LineupEditorState.edit(PersonalLineup lineup)
    : this(
        id: lineup.id,
        basedOn: lineup.basedOn,
        name: lineup.name.text,
        startName: lineup.name.text,
        lineup: lineup.lineup,
        startLineup: lineup.lineup,
      );

  LineupEditorState.fromTactic(Tactic tactic, TacticVariant variant, {bool early = false})
    : this(
        basedOn: tactic.id,
        name: _shorten(tactic.title),
        startName: _shorten(tactic.title),
        lineup: early ? variant.early : variant.lineup,
        startLineup: early ? variant.early : variant.lineup,
      );

  static String _shorten(String title) =>
      title.length > LineupName.maxLength ? title.substring(0, LineupName.maxLength).trimRight() : title;

  final LineupId? id;
  final TacticId? basedOn;
  final String? name;
  final String? startName;
  final Lineup lineup;
  final Lineup startLineup;
  final HexPosition? hex;
  final Champion? champion;
  final int stars;
  final List<Item> items;
  final LineupEditorStatus status;
  final PersonalLineup? saved;

  @override
  List<Object?> get props => [
    id,
    basedOn,
    name,
    startName,
    lineup,
    startLineup,
    hex,
    champion,
    stars,
    items,
    status,
    saved,
  ];

  @override
  String toString() =>
      'LineupEditorState(${lineup.placements.length} champions, ${items.length} items, ${status.name})';

  bool get dirty =>
      (name ?? '') != (startName ?? '') ||
      lineup.placements.length != startLineup.placements.length ||
      !lineup.placements.every(startLineup.placements.contains);

  DomainError? get nameError => switch (name) {
    null => null,
    final name => LineupName.parse(name).errorOrNull,
  };

  Result<Lineup>? get placed {
    final champion = this.champion;
    final hex = this.hex;
    if (champion == null || hex == null) return null;
    return switch (Unit.parse(champion, stars: stars, items: items)) {
      Success(value: final unit) => lineup.remove(hex).place(Placement(unit: unit, position: hex)),
      Failure(:final error) => Failure(error),
    };
  }

  LineupEditorState withUnit({
    required HexPosition? hex,
    Champion? champion,
    int stars = 1,
    List<Item> items = const [],
  }) => LineupEditorState(
    id: id,
    basedOn: basedOn,
    name: name,
    startName: startName,
    lineup: lineup,
    startLineup: startLineup,
    hex: hex,
    champion: champion,
    stars: stars,
    items: items,
  );

  LineupEditorState copyWith({
    String? name,
    Lineup? lineup,
    Champion? champion,
    int? stars,
    List<Item>? items,
    LineupEditorStatus? status,
    PersonalLineup? saved,
  }) => LineupEditorState(
    id: id,
    basedOn: basedOn,
    name: name ?? this.name,
    startName: startName,
    lineup: lineup ?? this.lineup,
    startLineup: startLineup,
    hex: hex,
    champion: champion ?? this.champion,
    stars: stars ?? this.stars,
    items: items ?? this.items,
    status: status ?? this.status,
    saved: saved ?? this.saved,
  );
}
