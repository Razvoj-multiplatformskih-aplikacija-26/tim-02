part of 'tactics_bloc.dart';

sealed class TacticsEvent {
  const TacticsEvent();
}

final class TacticsRequested extends TacticsEvent {
  const TacticsRequested();
}

final class TacticsRefreshed extends TacticsEvent {
  TacticsRefreshed();

  final _handled = Completer<void>();

  Future<void> get handled => _handled.future;
}

final class TacticsFilterChanged extends TacticsEvent {
  const TacticsFilterChanged(this.filter);

  final TacticStatusKind? filter;
}

final class TacticsSearchChanged extends TacticsEvent {
  const TacticsSearchChanged(this.search);

  final String search;
}

final class TacticSelected extends TacticsEvent {
  const TacticSelected(this.id);

  final TacticId? id;
}

final class TacticActionRequested extends TacticsEvent {
  const TacticActionRequested(this.id, this.action, {this.reason});

  final TacticId id;
  final TacticAction action;
  final HideReason? reason;
}

final class TacticsNoticeAcknowledged extends TacticsEvent {
  const TacticsNoticeAcknowledged();
}
