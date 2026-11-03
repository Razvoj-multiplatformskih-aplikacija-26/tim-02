part of 'tactics_bloc.dart';

sealed class TacticsState extends Equatable {
  const TacticsState();

  @override
  List<Object?> get props => const [];

  @override
  String toString() => '$runtimeType';
}

final class TacticsLoading extends TacticsState {
  const TacticsLoading();
}

final class TacticsFailure extends TacticsState {
  const TacticsFailure(this.cause);

  final Object cause;

  @override
  List<Object?> get props => [cause];

  @override
  String toString() => 'TacticsFailure($cause)';
}

final class TacticsEmpty extends TacticsState {
  const TacticsEmpty();
}

final class TacticsLoaded extends TacticsState {
  const TacticsLoaded({
    required this.user,
    required this.tactics,
    required this.tierList,
    this.actions = const {},
    this.filter,
    this.search = '',
    this.inFlightId,
    this.notice,
  });

  final User user;
  final List<Tactic> tactics;
  final TierList tierList;
  final Map<TacticId, Set<TacticAction>> actions;
  final TacticStatusKind? filter;
  final String search;
  final TacticId? inFlightId;
  final TacticsNotice? notice;

  @override
  List<Object?> get props => [user, tactics, tierList, actions, filter, search, inFlightId, notice];

  @override
  String toString() => [
    'TacticsLoaded(${tactics.length} tactics, patch ${tierList.patch.value}',
    if (filter case final filter?) ', only ${filter.name}',
    if (search.isNotEmpty) ', matching "$search"',
    if (inFlightId case final id?) ', in flight ${id.value}',
    if (notice case final notice?) ', ${notice.runtimeType}',
    ')',
  ].join();

  List<Tactic> get visible {
    final words = search.trim().toLowerCase();
    return [
      for (final t in tactics)
        if ((filter == null || t.status.kind == filter) &&
            (t.title.toLowerCase().contains(words) || t.authorName.toLowerCase().contains(words)))
          t,
    ];
  }

  List<Tactic> get mine => tactics.where((t) => t.authorId == user.id).toList();

  Map<Tier, List<Tactic>> get comps => tierList.comps(tactics);

  bool get isBusy => inFlightId != null;

  Tactic? tactic(TacticId id) => tactics.where((t) => t.id == id).firstOrNull;

  Set<TacticAction> actionsFor(TacticId id) => actions[id] ?? const {};

  TacticsLoaded withFilter(TacticStatusKind? filter) =>
      TacticsLoaded(user: user, tactics: tactics, tierList: tierList, actions: actions, filter: filter, search: search);

  TacticsLoaded withSearch(String search) =>
      TacticsLoaded(user: user, tactics: tactics, tierList: tierList, actions: actions, filter: filter, search: search);

  TacticsLoaded withInFlight(TacticId id) => TacticsLoaded(
    user: user,
    tactics: tactics,
    tierList: tierList,
    actions: actions,
    filter: filter,
    search: search,
    inFlightId: id,
  );

  TacticsLoaded withNotice(TacticsNotice? notice) => TacticsLoaded(
    user: user,
    tactics: tactics,
    tierList: tierList,
    actions: actions,
    filter: filter,
    search: search,
    notice: notice,
  );
}

sealed class TacticsNotice extends Equatable {
  const TacticsNotice();

  @override
  List<Object?> get props => const [];
}

final class TacticChanged extends TacticsNotice {
  const TacticChanged(this.action, this.tactic);

  final TacticAction action;
  final Tactic tactic;

  @override
  List<Object?> get props => [action, tactic];
}

final class TacticRejected extends TacticsNotice {
  const TacticRejected(this.error);

  final DomainError error;

  @override
  List<Object?> get props => [error];
}

final class TacticRequestFailed extends TacticsNotice {
  const TacticRequestFailed(this.cause);

  final Object cause;

  @override
  List<Object?> get props => [cause];
}
