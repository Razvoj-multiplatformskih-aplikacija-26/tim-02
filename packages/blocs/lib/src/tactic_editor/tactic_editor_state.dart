part of 'tactic_editor_bloc.dart';

enum TacticEditorStatus { editing, saving, saved, failed }

final class TacticEditorState extends Equatable {
  const TacticEditorState({
    required this.tactic,
    required this.title,
    required this.description,
    required this.variants,
    this.variant = 0,
    this.early = false,
    this.hex,
    this.champion,
    this.stars = 1,
    this.items = const [],
    this.catalog,
    this.status = TacticEditorStatus.editing,
    this.error,
  });

  TacticEditorState.of(Tactic tactic)
    : this(tactic: tactic, title: tactic.title, description: tactic.description, variants: tactic.variants);

  final Tactic tactic;
  final String title;
  final String description;
  final List<TacticVariant> variants;
  final int variant;
  final bool early;
  final HexPosition? hex;
  final Champion? champion;
  final int stars;
  final List<Item> items;
  final Catalog? catalog;
  final TacticEditorStatus status;
  final DomainError? error;

  @override
  List<Object?> get props => [
    tactic,
    title,
    description,
    variants,
    variant,
    early,
    hex,
    champion,
    stars,
    items,
    catalog,
    status,
    error,
  ];

  @override
  String toString() =>
      'TacticEditorState(${tactic.id.value}, variant $variant, ${early ? 'early' : 'final'}, ${status.name})';

  bool get dirty => tactic.copyWith(title: title, description: description, variants: variants) != tactic;

  TacticVariant? get chosen => variants.elementAtOrNull(variant);

  Lineup get board => switch (chosen) {
    final chosen? => early ? chosen.early : chosen.lineup,
    null => const Lineup.empty(),
  };

  DomainError? get titleError => Tactic.parseTitle(title).errorOrNull;

  Result<Lineup>? get placed {
    final champion = this.champion;
    final hex = this.hex;
    if (champion == null || hex == null) return null;
    return switch (Unit.parse(champion, stars: stars, items: items)) {
      Success(value: final unit) => board.remove(hex).place(Placement(unit: unit, position: hex)),
      Failure(:final error) => Failure(error),
    };
  }

  List<TacticVariant> withChosen(TacticVariant Function(TacticVariant variant) change) => [
    for (final (index, variant) in variants.indexed) index == this.variant ? change(variant) : variant,
  ];

  List<TacticVariant> withBoard(Lineup board) =>
      withChosen((variant) => early ? variant.copyWith(early: board) : variant.copyWith(lineup: board));

  TacticEditorState copyWith({
    Tactic? tactic,
    String? title,
    String? description,
    List<TacticVariant>? variants,
    int? variant,
    bool? early,
    Catalog? catalog,
    TacticEditorStatus? status,
    DomainError? error,
  }) => TacticEditorState(
    tactic: tactic ?? this.tactic,
    title: title ?? this.title,
    description: description ?? this.description,
    variants: variants ?? this.variants,
    variant: variant ?? this.variant,
    early: early ?? this.early,
    hex: hex,
    champion: champion,
    stars: stars,
    items: items,
    catalog: catalog ?? this.catalog,
    status: status ?? this.status,
    error: error,
  );

  TacticEditorState selecting(HexPosition position) {
    final unit = board.placements.where((p) => p.position == position).firstOrNull?.unit;
    return withUnit(hex: position, champion: unit?.champion, stars: unit?.stars ?? 1, items: unit?.items ?? const []);
  }

  TacticEditorState withUnit({HexPosition? hex, Champion? champion, int stars = 1, List<Item> items = const []}) =>
      TacticEditorState(
        tactic: tactic,
        title: title,
        description: description,
        variants: variants,
        variant: variant,
        early: early,
        hex: hex,
        champion: champion,
        stars: stars,
        items: items,
        catalog: catalog,
        status: status,
      );
}
