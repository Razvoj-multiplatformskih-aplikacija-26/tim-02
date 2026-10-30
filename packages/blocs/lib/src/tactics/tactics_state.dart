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
  const TacticsLoaded({required this.user, required this.tactics, required this.tierList});

  final User user;
  final List<Tactic> tactics;
  final TierList tierList;

  @override
  List<Object?> get props => [user, tactics, tierList];

  @override
  String toString() => 'TacticsLoaded(${tactics.length} tactics, patch ${tierList.patch.value})';

  List<Tactic> get mine => tactics.where((t) => t.authorId == user.id).toList();

  Map<Tier, List<Tactic>> get comps => tierList.comps(tactics);
}
