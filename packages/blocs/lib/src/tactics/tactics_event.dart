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

final class TacticSaved extends TacticsEvent {
  const TacticSaved(this.tactic);

  final Tactic tactic;
}

final class TacticsFilterChanged extends TacticsEvent {
  const TacticsFilterChanged(this.filter);

  final TacticStatusKind? filter;
}

final class TacticsSearchChanged extends TacticsEvent {
  const TacticsSearchChanged(this.search);

  final String search;
}

final class TacticsTierFilterChanged extends TacticsEvent {
  const TacticsTierFilterChanged(this.tier);

  final Tier? tier;
}

final class TacticSelected extends TacticsEvent {
  const TacticSelected(this.id);

  final TacticId? id;
}

final class TacticSelectionMoved extends TacticsEvent {
  const TacticSelectionMoved(this.delta);

  final int delta;
}

final class TacticActionRequested extends TacticsEvent {
  const TacticActionRequested(this.id, this.action, {this.reason});

  final TacticId id;
  final TacticAction action;
  final HideReason? reason;
}

final class TacticTierChanged extends TacticsEvent {
  const TacticTierChanged(this.id, this.tier);

  final TacticId id;
  final Tier? tier;
}

final class TacticsNoticeAcknowledged extends TacticsEvent {
  const TacticsNoticeAcknowledged();
}
