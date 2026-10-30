import 'package:equatable/equatable.dart';

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
