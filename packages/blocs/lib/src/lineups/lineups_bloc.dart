import 'package:bloc/bloc.dart';
import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:use_cases/use_cases.dart';

part 'lineups_event.dart';
part 'lineups_state.dart';

final class LineupsBloc extends Bloc<LineupsEvent, LineupsState> {
  LineupsBloc({required this.getLineups, required this.getCatalog}) : super(const LineupsLoading()) {
    on<LineupsRequested>((event, emit) async {
      emit(const LineupsLoading());
      try {
        emit(LineupsLoaded(await getLineups(), await getCatalog()));
      } on Exception catch (cause) {
        emit(LineupsFailure(cause));
      }
    });
    on<LineupSaved>((event, emit) {
      if (state case LineupsLoaded(:final lineups, :final catalog)) {
        emit(LineupsLoaded([...lineups, event.lineup], catalog));
      }
    });
  }

  final GetLineups getLineups;
  final GetCatalog getCatalog;
}
