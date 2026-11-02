import 'package:bloc/bloc.dart';
import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:use_cases/use_cases.dart';

part 'lineups_event.dart';
part 'lineups_state.dart';

final class LineupsBloc extends Bloc<LineupsEvent, LineupsState> {
  LineupsBloc({required this.getLineups}) : super(const LineupsLoading()) {
    on<LineupsRequested>((event, emit) async {
      emit(const LineupsLoading());
      try {
        emit(LineupsLoaded(await getLineups()));
      } on Exception catch (cause) {
        emit(LineupsFailure(cause));
      }
    });
  }

  final GetLineups getLineups;
}
