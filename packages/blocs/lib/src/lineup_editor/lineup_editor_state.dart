part of 'lineup_editor_bloc.dart';

enum LineupEditorStatus { editing, saving, saved, deleted, failed }

final class LineupEditorState extends Equatable {
  const LineupEditorState({
    this.id,
    this.variants = const [],
    this.name,
    this.startName,
    this.lineup = const Lineup.empty(),
    this.startLineup = const Lineup.empty(),
    this.hex,
    this.champion,
    this.stars = 1,
    this.items = const [],
    this.catalog,
    this.status = LineupEditorStatus.editing,
    this.error,
    this.saved,
  });

  LineupEditorState.edit(Tactic draft)
    : this(
        id: draft.id,
        variants: draft.variants,
        name: draft.title,
        startName: draft.title,
        lineup: draft.variants.firstOrNull?.lineup ?? const Lineup.empty(),
        startLineup: draft.variants.firstOrNull?.lineup ?? const Lineup.empty(),
      );

  LineupEditorState.fromTactic(Tactic tactic, TacticVariant variant)
    : this(
        variants: [variant],
        name: tactic.title,
        startName: tactic.title,
        lineup: variant.lineup,
        startLineup: variant.lineup,
      );

  final TacticId? id;
  final List<TacticVariant> variants;
  final String? name;
  final String? startName;
  final Lineup lineup;
  final Lineup startLineup;
  final HexPosition? hex;
  final Champion? champion;
  final int stars;
  final List<Item> items;
  final Catalog? catalog;
  final LineupEditorStatus status;
  final DomainError? error;
  final Tactic? saved;

  @override
  List<Object?> get props => [
    id,
    variants,
    name,
    startName,
    lineup,
    startLineup,
    hex,
    champion,
    stars,
    items,
    catalog,
    status,
    error,
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
    final name => Tactic.parseTitle(name).errorOrNull,
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
    variants: variants,
    name: name,
    startName: startName,
    lineup: lineup,
    startLineup: startLineup,
    hex: hex,
    champion: champion,
    stars: stars,
    items: items,
    catalog: catalog,
  );

  LineupEditorState copyWith({
    String? name,
    Lineup? lineup,
    Champion? champion,
    int? stars,
    List<Item>? items,
    Catalog? catalog,
    LineupEditorStatus? status,
    DomainError? error,
    Tactic? saved,
  }) => LineupEditorState(
    id: id,
    variants: variants,
    name: name ?? this.name,
    startName: startName,
    lineup: lineup ?? this.lineup,
    startLineup: startLineup,
    hex: hex,
    champion: champion ?? this.champion,
    stars: stars ?? this.stars,
    items: items ?? this.items,
    catalog: catalog ?? this.catalog,
    status: status ?? this.status,
    error: error,
    saved: saved ?? this.saved,
  );
}
