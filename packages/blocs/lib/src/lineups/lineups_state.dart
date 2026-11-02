part of 'lineups_bloc.dart';

sealed class LineupsState extends Equatable {
  const LineupsState();

  @override
  List<Object?> get props => const [];

  @override
  String toString() => '$runtimeType';
}

final class LineupsLoading extends LineupsState {
  const LineupsLoading();
}

final class LineupsFailure extends LineupsState {
  const LineupsFailure(this.cause);

  final Object cause;

  @override
  List<Object?> get props => [cause];

  @override
  String toString() => 'LineupsFailure($cause)';
}

final class LineupsLoaded extends LineupsState {
  const LineupsLoaded(this.lineups);

  final List<PersonalLineup> lineups;

  @override
  List<Object?> get props => [lineups];

  @override
  String toString() => 'LineupsLoaded(${lineups.length} lineups)';
}
