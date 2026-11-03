import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:use_cases/use_cases.dart';

part 'tactics_event.dart';
part 'tactics_state.dart';

final class TacticsBloc extends Bloc<TacticsEvent, TacticsState> {
  TacticsBloc({
    required this.getTactics,
    required this.getTierList,
    required this.changeStatus,
    required this.clock,
    required this.user,
  }) : super(const TacticsLoading()) {
    on<TacticsRequested>((event, emit) async {
      emit(const TacticsLoading());
      await _reload(emit);
    });
    on<TacticsRefreshed>((event, emit) async {
      try {
        await _reload(emit);
      } finally {
        event._handled.complete();
      }
    });
    on<TacticsFilterChanged>((event, emit) {
      final current = state;
      if (current is TacticsLoaded) emit(current.withFilter(event.filter));
    });
    on<TacticsSearchChanged>((event, emit) {
      final current = state;
      if (current is TacticsLoaded) emit(current.withSearch(event.search));
    });
    on<TacticSelected>((event, emit) {
      final current = state;
      if (current is TacticsLoaded) emit(current.withSelection(event.id));
    });
    on<TacticActionRequested>(_onActionRequested);
    on<TacticsNoticeAcknowledged>((event, emit) {
      final current = state;
      if (current is TacticsLoaded && current.notice != null) emit(current.withNotice(null));
    });
  }

  final GetTactics getTactics;
  final GetTierList getTierList;
  final ChangeTacticStatus changeStatus;
  final Clock clock;
  final User user;

  Future<void> _onActionRequested(TacticActionRequested event, Emitter<TacticsState> emit) async {
    final current = state;
    if (current is! TacticsLoaded || current.isBusy) return;
    emit(current.withInFlight(event.id));
    final Result<Tactic> result;
    try {
      result = await changeStatus(id: event.id, action: event.action, by: user);
    } on Exception catch (cause) {
      emit(current.withNotice(TacticRequestFailed(cause)));
      return;
    }
    switch (result) {
      case Success(:final value):
        await _reload(emit, notice: TacticChanged(event.action, value));
      case Failure(:final error):
        emit(current.withNotice(TacticRejected(error)));
    }
  }

  Future<void> _reload(Emitter<TacticsState> emit, {TacticsNotice? notice}) async {
    final previous = state;
    final filter = previous is TacticsLoaded ? previous.filter : null;
    final search = previous is TacticsLoaded ? previous.search : '';
    final selectedId = previous is TacticsLoaded ? previous.selectedId : null;
    try {
      final tactics = await getTactics(user);
      if (tactics.isEmpty) {
        emit(const TacticsEmpty());
        return;
      }
      final now = clock.now();
      emit(
        TacticsLoaded(
          user: user,
          tactics: tactics,
          tierList: await getTierList(),
          actions: {for (final t in tactics) t.id: allowedActions(t, user, now: now)},
          filter: filter,
          search: search,
          selectedId: selectedId,
          notice: notice,
        ),
      );
    } on Exception catch (cause) {
      emit(TacticsFailure(cause));
    }
  }
}
