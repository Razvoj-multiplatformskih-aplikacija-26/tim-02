part of 'tactics_bloc.dart';

sealed class TacticsEvent {
  const TacticsEvent();
}

final class TacticsRequested extends TacticsEvent {
  const TacticsRequested();
}

final class TacticActionRequested extends TacticsEvent {
  const TacticActionRequested(this.id, this.action);

  final TacticId id;
  final TacticAction action;
}

final class TacticsNoticeAcknowledged extends TacticsEvent {
  const TacticsNoticeAcknowledged();
}
