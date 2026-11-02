import 'package:domain/domain.dart';

extension DomainErrorMessage on DomainError {
  String get message => switch (this) {
    HideReasonTooShort() => 'Obrazloženje mora imati bar ${HideReason.minLength} znakova.',
    InvalidPosition() => 'Polje ne postoji na tabli.',
    TooManyItems() => 'Šampion može nositi najviše ${Unit.maxItems} predmeta.',
    HexOccupied() => 'Na ovom polju već stoji šampion.',
    NotAllowed() => 'Nemate pravo na ovu radnju.',
    InvalidTransition() => 'Ova promena stanja nije moguća.',
    NotFound() => 'Taktika nije pronađena.',
  };
}
