import 'package:bloc/bloc.dart';
import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:use_cases/use_cases.dart';

part 'lineup_editor_event.dart';
part 'lineup_editor_state.dart';

final class LineupEditorBloc extends Bloc<LineupEditorEvent, LineupEditorState> {
  LineupEditorBloc({
    required this.saveDraft,
    required this.deleteDraft,
    required this.getCatalog,
    required this.user,
    LineupEditorState initial = const LineupEditorState(),
  }) : super(initial) {
    on<LineupEditorStarted>((event, emit) async {
      emit(state.copyWith(status: LineupEditorStatus.editing));
      try {
        emit(state.copyWith(catalog: await getCatalog()));
      } on Exception {
        emit(state.copyWith(status: LineupEditorStatus.failed));
      }
    });
    on<LineupNameChanged>((event, emit) => emit(state.copyWith(name: event.text)));
    on<LineupHexChosen>((event, emit) {
      final unit = state.lineup.placements.where((p) => p.position == event.position).firstOrNull?.unit;
      emit(
        state.withUnit(
          hex: event.position,
          champion: unit?.champion,
          stars: unit?.stars ?? 1,
          items: unit?.items ?? const [],
        ),
      );
    });
    on<LineupUnitChanged>((event, emit) => emit(state.copyWith(champion: event.champion, stars: event.stars)));
    on<LineupItemAdded>((event, emit) => emit(state.copyWith(items: [...state.items, event.item])));
    on<LineupItemRemoved>((event, emit) => emit(state.copyWith(items: [...state.items]..removeAt(event.index))));
    on<LineupChampionPlaced>((event, emit) {
      if (state.placed case Success(value: final lineup)) emit(state.copyWith(lineup: lineup));
    });
    on<LineupChampionRemoved>((event, emit) {
      final removed = state.copyWith(lineup: state.lineup.remove(event.position));
      emit(event.position == state.hex ? removed.withUnit(hex: state.hex) : removed);
    });
    on<LineupChampionMoved>((event, emit) {
      final moved = state.copyWith(lineup: state.lineup.move(event.from, event.to));
      final unit = moved.lineup.placements.where((p) => p.position == event.to).firstOrNull?.unit;
      emit(
        moved.withUnit(
          hex: event.to,
          champion: unit?.champion,
          stars: unit?.stars ?? 1,
          items: unit?.items ?? const [],
        ),
      );
    });
    on<LineupChampionRestored>((event, emit) {
      if (state.lineup.place(event.placement) case Success(value: final lineup)) emit(state.copyWith(lineup: lineup));
    });
    on<LineupEditorSubmitted>(_onSubmitted);
    on<LineupEditorDeleted>(_onDeleted);
  }

  final SaveDraft saveDraft;
  final DeleteDraft deleteDraft;
  final GetCatalog getCatalog;
  final User user;

  Future<void> _onSubmitted(LineupEditorSubmitted event, Emitter<LineupEditorState> emit) async {
    if (state.status == LineupEditorStatus.saving) return;
    final title = state.name ?? '';
    if (Tactic.parseTitle(title) is Failure) {
      emit(state.copyWith(name: title));
      return;
    }
    final first = state.variants.firstOrNull;
    final variants = [
      first?.copyWith(lineup: state.lineup) ??
          TacticVariant(
            name: title.trim(),
            playstyle: Playstyle.fast8,
            difficulty: Difficulty.medium,
            early: const Lineup.empty(),
            lineup: state.lineup,
            flex: const [],
            itemPriority: const [],
            tip: '',
            stageTips: const {},
          ),
      ...state.variants.skip(1),
    ];
    emit(state.copyWith(status: LineupEditorStatus.saving));
    try {
      switch (await saveDraft(id: state.id, by: user, title: title, variants: variants)) {
        case Success(:final value):
          emit(state.copyWith(status: LineupEditorStatus.saved, saved: value));
        case Failure(:final error):
          emit(state.copyWith(status: LineupEditorStatus.editing, error: error));
      }
    } on Exception {
      emit(state.copyWith(status: LineupEditorStatus.failed));
    }
  }

  Future<void> _onDeleted(LineupEditorDeleted event, Emitter<LineupEditorState> emit) async {
    final id = state.id;
    if (id == null || state.status == LineupEditorStatus.saving) return;
    emit(state.copyWith(status: LineupEditorStatus.saving));
    try {
      switch (await deleteDraft(id, by: user)) {
        case Success():
          emit(state.copyWith(status: LineupEditorStatus.deleted));
        case Failure(:final error):
          emit(state.copyWith(status: LineupEditorStatus.editing, error: error));
      }
    } on Exception {
      emit(state.copyWith(status: LineupEditorStatus.failed));
    }
  }
}
