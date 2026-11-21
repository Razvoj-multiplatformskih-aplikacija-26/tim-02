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
    required this.placeTactic,
    required this.clock,
    this._user,
  }) : super(const TacticsLoading()) {
    on<TacticsUserChanged>((event, emit) async {
      _user = event.user;
      emit(const TacticsLoading());
      await _reload(emit);
    });
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
    on<TacticSaved>((event, emit) {
      if (state case final TacticsLoaded current) {
        final saved = event.tactic;
        emit(
          TacticsLoaded(
            user: _user,
            tactics: [
              if (current.tactic(saved.id) == null) saved,
              for (final t in current.tactics) t.id == saved.id ? saved : t,
            ],
            tierList: current.tierList,
            actions: {
              ...current.actions,
              saved.id: _actionsFor(saved, clock.now()),
            },
            filter: current.filter,
            search: current.search,
            tier: current.tier,
            selectedId: current.selectedId,
          ),
        );
      }
    });
    on<TacticDeleted>((event, emit) {
      if (state case final TacticsLoaded current) {
        emit(
          TacticsLoaded(
            user: _user,
            tactics: [
              for (final t in current.tactics)
                if (t.id != event.id) t,
            ],
            tierList: current.tierList,
            actions: {...current.actions}..remove(event.id),
            filter: current.filter,
            search: current.search,
            tier: current.tier,
            selectedId: current.selectedId == event.id ? null : current.selectedId,
          ),
        );
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
    on<TacticsTierFilterChanged>((event, emit) {
      final current = state;
      if (current is TacticsLoaded) emit(current.withTier(event.tier));
    });
    on<TacticSelected>((event, emit) {
      final current = state;
      if (current is TacticsLoaded) emit(current.withSelection(event.id));
    });
    on<TacticSelectionMoved>((event, emit) {
      final current = state;
      if (current is! TacticsLoaded) return;
      final visible = current.visible;
      if (visible.isEmpty) return;
      final index = visible.indexWhere((t) => t.id == current.selectedId);
      final next = index < 0 ? (event.delta > 0 ? 0 : visible.length - 1) : index + event.delta;
      emit(current.withSelection(visible[next.clamp(0, visible.length - 1)].id));
    });
    on<TacticActionRequested>(
      (event, emit) => _act(
        emit,
        event.id,
        (by) => changeStatus(id: event.id, action: event.action, by: by, reason: event.reason),
        (tactic) => TacticChanged(event.action, tactic),
      ),
    );
    on<TacticTierChanged>(
      (event, emit) => _act(
        emit,
        event.id,
        (by) => placeTactic(id: event.id, tier: event.tier, by: by),
        (_) => TacticPlaced(event.tier),
      ),
    );
    on<TacticsNoticeAcknowledged>((event, emit) {
      final current = state;
      if (current is TacticsLoaded && current.notice != null) emit(current.withNotice(null));
    });
  }

  final GetTactics getTactics;
  final GetTierList getTierList;
  final ChangeTacticStatus changeStatus;
  final PlaceTactic placeTactic;
  final Clock clock;
  User? _user;

  Future<void> _act<T>(
    Emitter<TacticsState> emit,
    TacticId id,
    Future<Result<T>> Function(User by) request,
    TacticsNotice Function(T value) done,
  ) async {
    final current = state;
    final by = _user;
    if (current is! TacticsLoaded || current.isBusy || by == null) return;
    emit(current.withInFlight(id));
    final Result<T> result;
    try {
      result = await request(by);
    } on Exception catch (cause) {
      emit(current.withNotice(TacticRequestFailed(cause)));
      return;
    }
    switch (result) {
      case Success(:final value):
        await _reload(emit, notice: done(value));
      case Failure(:final error):
        emit(current.withNotice(TacticRejected(error)));
    }
  }

  Set<TacticAction> _actionsFor(Tactic tactic, DateTime now) => switch (_user) {
    final user? => allowedActions(tactic, user, now: now),
    null => const {},
  };

  Future<void> _reload(Emitter<TacticsState> emit, {TacticsNotice? notice}) async {
    final previous = state;
    final filter = previous is TacticsLoaded ? previous.filter : null;
    final search = previous is TacticsLoaded ? previous.search : '';
    final tier = previous is TacticsLoaded ? previous.tier : null;
    final selectedId = previous is TacticsLoaded ? previous.selectedId : null;
    final user = _user;
    try {
      final tactics = await getTactics(user);
      if (user != _user) return;
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
          actions: {for (final t in tactics) t.id: _actionsFor(t, now)},
          filter: filter,
          search: search,
          tier: tier,
          selectedId: selectedId,
          notice: notice,
        ),
      );
    } on Exception catch (cause) {
      if (user == _user) emit(TacticsFailure(cause));
    }
  }
}
