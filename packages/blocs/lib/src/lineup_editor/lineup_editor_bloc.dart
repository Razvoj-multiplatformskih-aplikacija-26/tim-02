import 'package:bloc/bloc.dart';
import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:use_cases/use_cases.dart';

part 'lineup_editor_event.dart';
part 'lineup_editor_state.dart';

final class LineupEditorBloc extends Bloc<LineupEditorEvent, LineupEditorState> {
  LineupEditorBloc({
    required this.saveLineup,
    required this.deleteLineup,
    LineupEditorState initial = const LineupEditorState(),
  }) : super(initial) {
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

  final SaveLineup saveLineup;
  final DeleteLineup deleteLineup;

  Future<void> _onSubmitted(LineupEditorSubmitted event, Emitter<LineupEditorState> emit) async {
    if (state.status == LineupEditorStatus.saving) return;
    switch (LineupName.parse(state.name ?? '')) {
      case Failure():
        emit(state.copyWith(name: state.name ?? ''));
      case Success(value: final name):
        emit(state.copyWith(status: LineupEditorStatus.saving));
        try {
          final saved = await saveLineup(id: state.id, name: name, lineup: state.lineup, basedOn: state.basedOn);
          emit(state.copyWith(status: LineupEditorStatus.saved, saved: saved));
        } on Exception {
          emit(state.copyWith(status: LineupEditorStatus.failed));
        }
    }
  }

  Future<void> _onDeleted(LineupEditorDeleted event, Emitter<LineupEditorState> emit) async {
    final id = state.id;
    if (id == null || state.status == LineupEditorStatus.saving) return;
    emit(state.copyWith(status: LineupEditorStatus.saving));
    try {
      await deleteLineup(id);
      emit(state.copyWith(status: LineupEditorStatus.deleted));
    } on Exception {
      emit(state.copyWith(status: LineupEditorStatus.failed));
    }
  }
}
