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
  const LineupsLoaded(this.lineups, this.catalog);

  final List<PersonalLineup> lineups;
  final Catalog catalog;

  @override
  List<Object?> get props => [lineups, catalog];

  @override
  String toString() => 'LineupsLoaded(${lineups.length} lineups)';
}
