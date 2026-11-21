import 'package:api_contract/api_contract.dart';
import 'package:domain/domain.dart';

import 'tactic_mapping.dart';

extension DomainErrorMapping on DomainError {
  ProblemDto toProblem() => switch (this) {
    HideReasonTooShort(:final length, :final min) => ProblemDto(
      status: 422,
      code: ErrorCodes.hideReasonTooShort,
      title: 'Hide reason too short',
      value: length,
      min: min,
    ),
    InvalidPosition() => const ProblemDto(status: 422, code: ErrorCodes.invalidPosition, title: 'Invalid position'),
    TooManyItems(:final count, :final max) => ProblemDto(
      status: 422,
      code: ErrorCodes.tooManyItems,
      title: 'Too many items',
      value: count,
      max: max,
    ),
    HexOccupied(:final position) => ProblemDto(
      status: 422,
      code: ErrorCodes.hexOccupied,
      title: 'Hex occupied',
      row: position.row,
      column: position.column,
    ),
    InvalidTacticTitle(:final length, :final max) => ProblemDto(
      status: 422,
      code: ErrorCodes.invalidTacticTitle,
      title: 'Invalid tactic title',
      value: length,
      max: max,
    ),
    TacticArchived() => const ProblemDto(status: 409, code: ErrorCodes.tacticArchived, title: 'Tactic archived'),
    EmptyBoard() => const ProblemDto(status: 422, code: ErrorCodes.emptyBoard, title: 'Empty board'),
    NotPlaceable() => const ProblemDto(status: 409, code: ErrorCodes.notPlaceable, title: 'Not placeable'),
    NotAllowed() => const ProblemDto(status: 403, code: ErrorCodes.notAllowed, title: 'Not allowed'),
    HiddenByAdmin() => const ProblemDto(status: 409, code: ErrorCodes.hiddenByAdmin, title: 'Hidden by an admin'),
    InvalidTransition(:final from, :final to) => ProblemDto(
      status: 409,
      code: ErrorCodes.invalidTransition,
      title: 'Invalid transition',
      from: from.toDto(),
      to: to.toDto(),
    ),
    NotFound() => const ProblemDto(status: 404, code: ErrorCodes.notFound, title: 'Not found'),
  };
}

extension ProblemMapping on ProblemDto {
  DomainError? toDomainError() => switch (this) {
    ProblemDto(code: ErrorCodes.hideReasonTooShort, :final value?, :final min?) => HideReasonTooShort(value, min: min),
    ProblemDto(code: ErrorCodes.invalidPosition) => const InvalidPosition(),
    ProblemDto(code: ErrorCodes.tooManyItems, :final value?, :final max?) => TooManyItems(value, max: max),
    ProblemDto(code: ErrorCodes.hexOccupied, :final row?, :final column?) => switch (HexPosition.parse(row, column)) {
      Success(:final value) => HexOccupied(value),
      Failure() => null,
    },
    ProblemDto(code: ErrorCodes.invalidTacticTitle, :final value?, :final max?) => InvalidTacticTitle(value, max: max),
    ProblemDto(code: ErrorCodes.tacticArchived) => const TacticArchived(),
    ProblemDto(code: ErrorCodes.emptyBoard) => const EmptyBoard(),
    ProblemDto(code: ErrorCodes.notPlaceable) => const NotPlaceable(),
    ProblemDto(code: ErrorCodes.notAllowed) => const NotAllowed(),
    ProblemDto(code: ErrorCodes.hiddenByAdmin) => const HiddenByAdmin(),
    ProblemDto(code: ErrorCodes.invalidTransition, :final from?, :final to?) => InvalidTransition(
      from: from.toDomain(),
      to: to.toDomain(),
    ),
    ProblemDto(code: ErrorCodes.notFound) => const NotFound(),
    _ => null,
  };
}
