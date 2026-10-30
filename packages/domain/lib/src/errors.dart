import 'package:equatable/equatable.dart';

import 'lineup/lineup.dart';

sealed class DomainError extends Equatable {
  const DomainError();

  @override
  List<Object?> get props => const [];
}

final class HideReasonTooShort extends DomainError {
  const HideReasonTooShort(this.length);

  final int length;

  @override
  List<Object?> get props => [length];
}

final class InvalidPosition extends DomainError {
  const InvalidPosition();
}

final class TooManyItems extends DomainError {
  const TooManyItems(this.count);

  final int count;

  @override
  List<Object?> get props => [count];
}

final class HexOccupied extends DomainError {
  const HexOccupied(this.position);

  final HexPosition position;

  @override
  List<Object?> get props => [position];
}
