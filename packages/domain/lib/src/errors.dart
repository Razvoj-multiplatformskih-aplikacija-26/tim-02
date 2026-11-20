import 'package:equatable/equatable.dart';

import 'lineup/lineup.dart';
import 'tactic/tactic_status.dart';

sealed class DomainError extends Equatable {
  const DomainError();

  @override
  List<Object?> get props => const [];
}

final class HideReasonTooShort extends DomainError {
  const HideReasonTooShort(this.length, {required this.min});

  final int length;
  final int min;

  @override
  List<Object?> get props => [length, min];
}

final class InvalidPosition extends DomainError {
  const InvalidPosition();
}

final class TooManyItems extends DomainError {
  const TooManyItems(this.count, {required this.max});

  final int count;
  final int max;

  @override
  List<Object?> get props => [count, max];
}

final class HexOccupied extends DomainError {
  const HexOccupied(this.position);

  final HexPosition position;

  @override
  List<Object?> get props => [position];
}

final class NotAllowed extends DomainError {
  const NotAllowed();
}

final class HiddenByAdmin extends DomainError {
  const HiddenByAdmin();
}

final class TacticArchived extends DomainError {
  const TacticArchived();
}

final class EmptyBoard extends DomainError {
  const EmptyBoard();
}

final class InvalidTacticTitle extends DomainError {
  const InvalidTacticTitle(this.length, {required this.max});

  final int length;
  final int max;

  @override
  List<Object?> get props => [length, max];
}

final class NotPlaceable extends DomainError {
  const NotPlaceable();
}

final class InvalidTransition extends DomainError {
  const InvalidTransition({required this.from, required this.to});

  final TacticStatus from;
  final TacticStatus to;

  @override
  List<Object?> get props => [from, to];
}

final class NotFound extends DomainError {
  const NotFound();
}
