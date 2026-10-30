import 'package:domain/domain.dart';
import 'package:test/test.dart';

void main() {
  final now = DateTime.utc(2026, 10, 28, 12);
  const ahri = Champion(id: ChampionId('ahri'), name: 'Ahri', cost: 4);

  Tactic tactic(String id, TacticStatus status) => Tactic(
    id: TacticId(id),
    authorId: const UserId('u-luka'),
    authorName: 'Luka',
    title: id,
    description: '',
    carry: ahri,
    status: status,
    updatedAt: now,
  );

  final hidden = Hidden(
    reason: HideReason.parse('Opis je preuzet bez izvora.').valueOrNull!,
    by: const UserId('u-ana'),
    at: now,
  );

  Map<Tier, List<String>> ids(Map<Tier, List<Tactic>> comps) => {
    for (final MapEntry(key: tier, value: tactics) in comps.entries) tier: [for (final t in tactics) t.id.value],
  };

  group('TierList.comps', () {
    test('groups published tactics by tier in placement order', () {
      final tactics = [
        tactic('t-1', Published(at: now)),
        tactic('t-2', Published(at: now)),
        tactic('t-3', Published(at: now)),
      ];
      const list = TierList(
        patch: PatchId('18.5c'),
        placements: [
          TierPlacement(tactic: TacticId('t-3'), tier: Tier.a),
          TierPlacement(tactic: TacticId('t-1'), tier: Tier.s),
          TierPlacement(tactic: TacticId('t-2'), tier: Tier.a),
        ],
      );
      expect(ids(list.comps(tactics)), {
        Tier.s: ['t-1'],
        Tier.a: ['t-3', 't-2'],
        Tier.b: <String>[],
        Tier.c: <String>[],
        Tier.situational: <String>[],
      });
    });

    test('leaves out hidden, draft, archived and unplaced tactics', () {
      final tactics = [
        tactic('t-1', Published(at: now)),
        tactic('t-2', hidden),
        tactic('t-3', const Draft()),
        tactic('t-4', Archived(at: now)),
        tactic('t-5', Published(at: now)),
      ];
      const list = TierList(
        patch: PatchId('18.5c'),
        placements: [
          TierPlacement(tactic: TacticId('t-2'), tier: Tier.s),
          TierPlacement(tactic: TacticId('t-1'), tier: Tier.s),
          TierPlacement(tactic: TacticId('t-3'), tier: Tier.b),
          TierPlacement(tactic: TacticId('t-4'), tier: Tier.c),
        ],
      );
      expect(list.comps(tactics).values.expand((t) => t).map((t) => t.id.value), ['t-1']);
    });
  });
}
