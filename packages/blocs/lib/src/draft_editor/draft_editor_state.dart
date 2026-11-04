part of 'draft_editor_bloc.dart';

enum DraftEditorStatus { editing, saving, saved, deleted, failed }

final class DraftEditorState extends Equatable {
  const DraftEditorState({
    this.id,
    this.variants = const [],
    this.title,
    this.startTitle,
    this.lineup = const Lineup.empty(),
    this.startLineup = const Lineup.empty(),
    this.hex,
    this.champion,
    this.stars = 1,
    this.items = const [],
    this.catalog,
    this.status = DraftEditorStatus.editing,
    this.error,
    this.saved,
  });

  DraftEditorState.edit(Tactic draft)
    : this(
        id: draft.id,
        variants: draft.variants,
        title: draft.title,
        startTitle: draft.title,
        lineup: draft.variants.firstOrNull?.lineup ?? const Lineup.empty(),
        startLineup: draft.variants.firstOrNull?.lineup ?? const Lineup.empty(),
      );

  DraftEditorState.fromTactic(Tactic tactic, TacticVariant variant)
    : this(
        variants: [variant],
        title: tactic.title,
        startTitle: tactic.title,
        lineup: variant.lineup,
        startLineup: variant.lineup,
      );

  final TacticId? id;
  final List<TacticVariant> variants;
  final String? title;
  final String? startTitle;
  final Lineup lineup;
  final Lineup startLineup;
  final HexPosition? hex;
  final Champion? champion;
  final int stars;
  final List<Item> items;
  final Catalog? catalog;
  final DraftEditorStatus status;
  final DomainError? error;
  final Tactic? saved;

  @override
  List<Object?> get props => [
    id,
    variants,
    title,
    startTitle,
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
      'DraftEditorState(${lineup.placements.length} champions, ${items.length} items, ${status.name})';

  bool get dirty =>
      (title ?? '') != (startTitle ?? '') ||
      lineup.placements.length != startLineup.placements.length ||
      !lineup.placements.every(startLineup.placements.contains);

  DomainError? get titleError => switch (title) {
    null => null,
    final title => Tactic.parseTitle(title).errorOrNull,
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

  DraftEditorState selecting(HexPosition position) {
    final unit = lineup.placements.where((p) => p.position == position).firstOrNull?.unit;
    return withUnit(hex: position, champion: unit?.champion, stars: unit?.stars ?? 1, items: unit?.items ?? const []);
  }

  DraftEditorState withUnit({
    required HexPosition? hex,
    Champion? champion,
    int stars = 1,
    List<Item> items = const [],
  }) => DraftEditorState(
    id: id,
    variants: variants,
    title: title,
    startTitle: startTitle,
    lineup: lineup,
    startLineup: startLineup,
    hex: hex,
    champion: champion,
    stars: stars,
    items: items,
    catalog: catalog,
  );

  DraftEditorState copyWith({
    String? title,
    Lineup? lineup,
    Champion? champion,
    int? stars,
    List<Item>? items,
    Catalog? catalog,
    DraftEditorStatus? status,
    DomainError? error,
    Tactic? saved,
  }) => DraftEditorState(
    id: id,
    variants: variants,
    title: title ?? this.title,
    startTitle: startTitle,
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
