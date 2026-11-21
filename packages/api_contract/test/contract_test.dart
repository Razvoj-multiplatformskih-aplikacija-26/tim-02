import 'dart:convert';

import 'package:api_contract/api_contract.dart';
import 'package:test/test.dart';

Map<String, Object?> throughJson(Map<String, Object?> json) => jsonDecode(jsonEncode(json)) as Map<String, Object?>;

const ahri = ChampionDto(id: 'DA_18_Ahri', name: 'Ahri', cost: 4);
const shojin = ItemDto(id: 'TFT_Item_SpearOfShojin', name: 'Spear of Shojin');

final tactic = TacticDto(
  id: 't-01',
  authorId: 'u-marko',
  authorName: 'Marko',
  title: 'Ahri na nivou 8',
  description: 'Brzi nivo 8.',
  carry: ahri,
  status: TacticStatusDto(
    kind: TacticStatusDto.hidden,
    at: DateTime.utc(2026, 11, 20, 18),
    reason: 'Zastarela postava.',
    by: 'u-ana',
  ),
  updatedAt: DateTime.utc(2026, 11, 20, 18),
  variants: const [
    TacticVariantDto(
      name: 'Osnovna',
      playstyle: 'fast8',
      difficulty: 'medium',
      early: [
        PlacementDto(
          row: 3,
          column: 3,
          unit: UnitDto(champion: ahri, stars: 1, items: []),
        ),
      ],
      lineup: [
        PlacementDto(
          row: 3,
          column: 3,
          unit: UnitDto(champion: ahri, stars: 2, items: [shojin]),
        ),
      ],
      flex: [UnitDto(champion: ahri, stars: 1, items: [])],
      itemPriority: [shojin],
      tip: 'Čuvaj niz.',
      stageTips: {2: 'Ekonomija.', 4: 'Nivo 8.'},
    ),
  ],
);

void main() {
  test('carries a tactic with its status and variants through JSON', () {
    final json = throughJson(tactic.toJson());

    expect(TacticDto.fromJson(json).toJson(), tactic.toJson());
    expect(json['updatedAt'], '2026-11-20T18:00:00.000Z');
    expect((json['variants']! as List<Object?>).single, containsPair('stageTips', {'2': 'Ekonomija.', '4': 'Nivo 8.'}));
  });

  test('carries a problem with the limits of its rule', () {
    const problem = ProblemDto(status: 422, code: ErrorCodes.tooManyItems, title: 'Too many items', value: 4, max: 3);

    final json = throughJson(problem.toJson());

    expect(ProblemDto.fromJson(json).toJson(), problem.toJson());
    expect(json, containsPair('type', 'tag:raf.rs,2026:tft-insights/problem/too-many-items'));
  });

  test('carries the bodies of the calls that change a tactic or the tier list through JSON', () {
    final changes = TacticChangesDto(title: tactic.title, description: tactic.description, variants: tactic.variants);
    final draft = NewTacticDto(title: tactic.title, variants: tactic.variants);

    expect(TacticChangesDto.fromJson(throughJson(changes.toJson())).toJson(), changes.toJson());
    expect(NewTacticDto.fromJson(throughJson(draft.toJson())).toJson(), draft.toJson());
    expect(
      HideDto.fromJson(throughJson(const HideDto(reason: 'Zastarela postava.').toJson())).reason,
      'Zastarela postava.',
    );
    expect(TierChangeDto.fromJson(throughJson(const TierChangeDto(tier: 's').toJson())).tier, 's');
    expect(TierChangeDto.fromJson(throughJson(const TierChangeDto(tier: null).toJson())).tier, isNull);
  });

  test('ignores fields it does not know', () {
    final json = throughJson({...tactic.toJson(), 'likes': 12});

    expect(TacticDto.fromJson(json).toJson(), tactic.toJson());
  });

  test('carries a login and the session it opens through JSON', () {
    const login = LoginDto(username: 'marko', password: 'tft-demo', cookie: true);
    final session = SessionDto(
      user: const UserDto(id: 'u-marko', name: 'Marko', role: 'creator'),
      expiresAt: DateTime.utc(2026, 11, 21, 9),
      token: 'header.payload.signature',
    );

    expect(LoginDto.fromJson(throughJson(login.toJson())).toJson(), login.toJson());
    expect(SessionDto.fromJson(throughJson(session.toJson())).toJson(), session.toJson());
  });

  test('refuses an instant without a time zone', () {
    final json = throughJson({...tactic.toJson(), 'updatedAt': '2026-11-20T18:00:00'});

    expect(() => TacticDto.fromJson(json), throwsFormatException);
  });
}
