import 'package:domain/domain.dart';

extension DomainErrorMessage on DomainError {
  String get message => switch (this) {
    HideReasonTooShort() => 'Obrazloženje mora imati bar ${HideReason.minLength} znakova.',
    InvalidPosition() => 'Polje ne postoji na tabli.',
    TooManyItems() => 'Šampion može nositi najviše ${Unit.maxItems} predmeta.',
    HexOccupied() => 'Na ovom polju već stoji šampion.',
    InvalidTacticTitle() => 'Naslov mora imati od 1 do ${Tactic.maxTitleLength} znakova.',
    TacticArchived() => 'Arhivirana taktika ne može da se menja.',
    EmptyBoard() => 'Svaka varijanta mora imati šampione na tabli za kasnu igru.',
    NotPlaceable() => 'Na listu može samo objavljena taktika.',
    NotAllowed() => 'Nemate pravo na ovu radnju.',
    HiddenByAdmin() => 'Taktiku je sakrio administrator; samo on može da je vrati.',
    InvalidTransition() => 'Ova promena stanja nije moguća.',
    NotFound() => 'Taktika nije pronađena.',
  };
}
