import 'package:domain/domain.dart';

extension DomainErrorMessage on DomainError {
  String get message => switch (this) {
    HideReasonTooShort() => 'Obrazloženje mora imati bar ${HideReason.minLength} znakova.',
    InvalidPosition() => 'Polje ne postoji na tabli.',
    TooManyItems() => 'Šampion može nositi najviše ${Unit.maxItems} predmeta.',
    HexOccupied() => 'Na ovom polju već stoji šampion.',
    InvalidLineupName() => 'Naziv postave mora imati od 1 do ${LineupName.maxLength} znakova.',
    NotAllowed() => 'Nemate pravo na ovu radnju.',
    HiddenByAdmin() => 'Taktiku je sakrio administrator; samo on može da je vrati.',
    InvalidTransition() => 'Ova promena stanja nije moguća.',
    NotFound() => 'Taktika nije pronađena.',
  };
}
