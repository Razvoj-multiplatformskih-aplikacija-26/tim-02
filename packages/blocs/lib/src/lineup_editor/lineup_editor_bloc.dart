import 'package:bloc/bloc.dart';
import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:use_cases/use_cases.dart';

part 'lineup_editor_event.dart';
part 'lineup_editor_state.dart';

final class LineupEditorBloc extends Bloc<LineupEditorEvent, LineupEditorState> {
  LineupEditorBloc({required this.saveLineup, LineupEditorState initial = const LineupEditorState()}) : super(initial) {
    on<LineupNameChanged>((event, emit) => emit(state.copyWith(name: event.text)));
    on<LineupUnitChanged>(
      (event, emit) => emit(state.copyWith(champion: event.champion, row: event.row, column: event.column)),
    );
    on<LineupItemAdded>((event, emit) => emit(state.copyWith(items: [...state.items, event.item])));
    on<LineupItemRemoved>((event, emit) => emit(state.copyWith(items: [...state.items]..removeAt(event.index))));
    on<LineupChampionPlaced>((event, emit) {
      if (state.placed case Success(value: final lineup)) {
        emit(LineupEditorState(id: state.id, basedOn: state.basedOn, name: state.name, lineup: lineup));
      }
    });
    on<LineupChampionRemoved>((event, emit) => emit(state.copyWith(lineup: state.lineup.remove(event.position))));
    on<LineupEditorSubmitted>(_onSubmitted);
  }

  final SaveLineup saveLineup;

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
}
