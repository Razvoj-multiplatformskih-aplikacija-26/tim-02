import 'package:bloc/bloc.dart';
import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:use_cases/use_cases.dart';

part 'draft_editor_event.dart';
part 'draft_editor_state.dart';

final class DraftEditorBloc extends Bloc<DraftEditorEvent, DraftEditorState> {
  DraftEditorBloc({
    required this.saveDraft,
    required this.deleteDraft,
    required this.getCatalog,
    required this.user,
    DraftEditorState initial = const DraftEditorState(),
  }) : super(initial) {
    on<DraftEditorStarted>((event, emit) async {
      emit(state.copyWith(status: DraftEditorStatus.editing));
      try {
        emit(state.copyWith(catalog: await getCatalog()));
      } on Exception {
        emit(state.copyWith(status: DraftEditorStatus.failed));
      }
    });
    on<DraftTitleChanged>((event, emit) => emit(state.copyWith(title: event.text)));
    on<DraftHexChosen>((event, emit) => emit(state.selecting(event.position)));
    on<DraftUnitChanged>((event, emit) => emit(state.copyWith(champion: event.champion, stars: event.stars)));
    on<DraftItemAdded>((event, emit) => emit(state.copyWith(items: [...state.items, event.item])));
    on<DraftItemRemoved>((event, emit) => emit(state.copyWith(items: [...state.items]..removeAt(event.index))));
    on<DraftChampionPlaced>((event, emit) {
      if (state.placed case Success(value: final lineup)) emit(state.copyWith(lineup: lineup));
    });
    on<DraftChampionRemoved>((event, emit) {
      final removed = state.copyWith(lineup: state.lineup.remove(event.position));
      emit(event.position == state.hex ? removed.withUnit(hex: state.hex) : removed);
    });
    on<DraftChampionMoved>(
      (event, emit) => emit(state.copyWith(lineup: state.lineup.move(event.from, event.to)).selecting(event.to)),
    );
    on<DraftChampionRestored>((event, emit) {
      if (state.lineup.place(event.placement) case Success(value: final lineup)) emit(state.copyWith(lineup: lineup));
    });
    on<DraftEditorSubmitted>(_onSubmitted);
    on<DraftEditorDeleted>(_onDeleted);
  }

  final SaveDraft saveDraft;
  final DeleteDraft deleteDraft;
  final GetCatalog getCatalog;
  final User user;

  Future<void> _onSubmitted(DraftEditorSubmitted event, Emitter<DraftEditorState> emit) async {
    if (state.status == DraftEditorStatus.saving) return;
    final title = state.title ?? '';
    if (Tactic.parseTitle(title) is Failure) {
      emit(state.copyWith(title: title));
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
    emit(state.copyWith(status: DraftEditorStatus.saving));
    try {
      switch (await saveDraft(id: state.id, by: user, title: title, variants: variants)) {
        case Success(:final value):
          emit(state.copyWith(status: DraftEditorStatus.saved, saved: value));
        case Failure(:final error):
          emit(state.copyWith(status: DraftEditorStatus.editing, error: error));
      }
    } on Exception {
      emit(state.copyWith(status: DraftEditorStatus.failed));
    }
  }

  Future<void> _onDeleted(DraftEditorDeleted event, Emitter<DraftEditorState> emit) async {
    final id = state.id;
    if (id == null || state.status == DraftEditorStatus.saving) return;
    emit(state.copyWith(status: DraftEditorStatus.saving));
    try {
      switch (await deleteDraft(id, by: user)) {
        case Success():
          emit(state.copyWith(status: DraftEditorStatus.deleted));
        case Failure(:final error):
          emit(state.copyWith(status: DraftEditorStatus.editing, error: error));
      }
    } on Exception {
      emit(state.copyWith(status: DraftEditorStatus.failed));
    }
  }
}
