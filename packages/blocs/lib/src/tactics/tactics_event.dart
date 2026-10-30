part of 'tactics_bloc.dart';

sealed class TacticsEvent {
  const TacticsEvent();
}

final class TacticsRequested extends TacticsEvent {
  const TacticsRequested();
}
