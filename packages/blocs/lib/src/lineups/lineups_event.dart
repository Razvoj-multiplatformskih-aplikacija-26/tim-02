part of 'lineups_bloc.dart';

sealed class LineupsEvent {
  const LineupsEvent();
}

final class LineupsRequested extends LineupsEvent {
  const LineupsRequested();
}
