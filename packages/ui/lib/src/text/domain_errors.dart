import 'package:domain/domain.dart';

import 'serbian.dart';

extension DomainErrorMessage on DomainError {
  String get message => switch (this) {
    HideReasonTooShort(:final min) => 'Obrazloženje mora imati bar $min znakova.',
    InvalidPosition() => 'Polje ne postoji na tabli.',
    TooManyItems(:final max) => 'Šampion može nositi najviše $max predmeta.',
    HexOccupied() => 'Na ovom polju već stoji šampion.',
    InvalidTacticTitle(:final max) => 'Naslov mora imati od 1 do $max znakova.',
    TacticArchived() => 'Arhivirana taktika ne može da se menja.',
    EmptyBoard() => 'Svaka varijanta mora imati šampione na tabli za kasnu igru.',
    NotPlaceable() => 'Na listu može samo objavljena taktika.',
    NotAllowed() => 'Nemate pravo na ovu radnju.',
    HiddenByAdmin() => 'Taktiku je sakrio administrator; samo on može da je vrati.',
    TierFull(:final tier, :final max) => 'Tier ${tier.label} je pun (najviše $max kompozicije).',
    InvalidTransition() => 'Taktiku je u međuvremenu promenio drugi korisnik.',
    NotFound() => 'Taktika nije pronađena.',
  };
}
