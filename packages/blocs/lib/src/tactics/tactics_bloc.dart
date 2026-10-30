import 'package:bloc/bloc.dart';
import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:use_cases/use_cases.dart';

part 'tactics_event.dart';
part 'tactics_state.dart';

final class TacticsBloc extends Bloc<TacticsEvent, TacticsState> {
  TacticsBloc({required this.getTactics, required this.getTierList, required this.user})
    : super(const TacticsLoading()) {
    on<TacticsRequested>((event, emit) async {
      emit(const TacticsLoading());
      await _reload(emit);
    });
  }

  final GetTactics getTactics;
  final GetTierList getTierList;
  final User user;

  Future<void> _reload(Emitter<TacticsState> emit) async {
    try {
      final tactics = await getTactics(user);
      if (tactics.isEmpty) {
        emit(const TacticsEmpty());
        return;
      }
      emit(TacticsLoaded(user: user, tactics: tactics, tierList: await getTierList()));
    } on Exception catch (cause) {
      emit(TacticsFailure(cause));
    }
  }
}
