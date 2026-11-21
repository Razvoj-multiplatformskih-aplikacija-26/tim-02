import 'package:domain/domain.dart';
import 'package:test/test.dart';

void main() {
  final now = DateTime.utc(2026, 11, 3, 20);
  const marko = User(id: UserId('u-marko'), name: 'Marko', role: Role.creator);
  const luka = User(id: UserId('u-luka'), name: 'Luka', role: Role.creator);
  const ana = User(id: UserId('u-ana'), name: 'Ana', role: Role.admin);
  const ahri = Champion(id: ChampionId('ahri'), name: 'Ahri', cost: 4);
  TacticVariant variant(Lineup lineup) => TacticVariant(
    name: 'Ahri 8',
    playstyle: Playstyle.fast8,
    difficulty: Difficulty.medium,
    early: const Lineup.empty(),
    lineup: lineup,
    flex: const [],
    itemPriority: const [],
    tip: '',
    stageTips: const {},
  );
  final board = const Lineup.empty()
      .place(Placement(unit: Unit.parse(ahri).valueOrNull!, position: HexPosition.parse(0, 3).valueOrNull!))
      .valueOrNull!;

  Tactic tactic(String id, TacticStatus status) => Tactic(
    id: TacticId(id),
    authorId: marko.id,
    authorName: marko.name,
    title: id,
    description: '',
    carry: ahri,
    status: status,
    updatedAt: now.subtract(const Duration(days: 1)),
  );

  Result<Tactic> edit(Tactic tactic, User by, {String title = 'Ahri reroll', List<TacticVariant>? variants}) =>
      editTactic(tactic, by: by, title: title, description: ' Opis ', variants: variants ?? [variant(board)], now: now);

  group('editTactic', () {
    test('lets the author and an admin edit, and records when', () {
      final edited = edit(tactic('t-1', const Draft()), marko).valueOrNull;
      expect(edited?.title, 'Ahri reroll');
      expect(edited?.description, 'Opis');
      expect(edited?.updatedAt, now);
      expect(edit(tactic('t-1', Published(at: now)), ana).isSuccess, isTrue);
    });

    test('refuses another creator and an archived tactic', () {
      expect(edit(tactic('t-1', const Draft()), luka), const Failure<Tactic>(NotAllowed()));
      expect(edit(tactic('t-1', Archived(at: now)), ana), const Failure<Tactic>(TacticArchived()));
      expect(mayEdit(tactic('t-1', Archived(at: now)), ana), isFalse);
    });

    test('needs a title of 1 to ${Tactic.maxTitleLength} characters', () {
      expect(
        edit(tactic('t-1', const Draft()), marko, title: '   '),
        const Failure<Tactic>(InvalidTacticTitle(0, max: 60)),
      );
      expect(
        edit(tactic('t-1', const Draft()), marko, title: 'a' * 61),
        const Failure<Tactic>(InvalidTacticTitle(61, max: 60)),
      );
    });

    test('needs champions on the final board of every variant', () {
      expect(edit(tactic('t-1', const Draft()), marko, variants: const []), const Failure<Tactic>(EmptyBoard()));
      expect(
        edit(tactic('t-1', const Draft()), marko, variants: [variant(board), variant(const Lineup.empty())]),
        const Failure<Tactic>(EmptyBoard()),
      );
    });
  });

  group('draftTactic', () {
    Result<Tactic> draft({String title = 'Moj nacrt', List<TacticVariant>? variants}) => draftTactic(
      id: const TacticId('t-9'),
      by: marko,
      title: title,
      variants: variants ?? [variant(board)],
      now: now,
    );

    test('makes my own draft with the carry taken from its board', () {
      final made = draft(title: ' Moj nacrt ').valueOrNull;
      expect(made?.status, const Draft());
      expect(made?.authorId, marko.id);
      expect(made?.title, 'Moj nacrt');
      expect(made?.carry, ahri);
    });

    test('needs a title and champions on the final board', () {
      expect(draft(title: ''), const Failure<Tactic>(InvalidTacticTitle(0, max: 60)));
      expect(draft(variants: [variant(const Lineup.empty())]), const Failure<Tactic>(EmptyBoard()));
    });
  });

  group('deleteDraft', () {
    test('lets only the author delete, and only a draft', () {
      expect(deleteDraft(tactic('t-1', const Draft()), by: marko), const Success(TacticId('t-1')));
      expect(deleteDraft(tactic('t-1', const Draft()), by: luka), const Failure<TacticId>(NotAllowed()));
      expect(deleteDraft(tactic('t-1', Published(at: now)), by: marko), const Failure<TacticId>(NotAllowed()));
    });
  });

  group('placeTactic', () {
    const list = TierList(
      patch: PatchId('18.5c'),
      placements: [
        TierPlacement(tactic: TacticId('t-1'), tier: Tier.s),
        TierPlacement(tactic: TacticId('t-2'), tier: Tier.a),
      ],
    );

    test('lets an admin move a published tactic to the end of another tier or off the list', () {
      final published = tactic('t-1', Published(at: now));
      expect(placeTactic(list, published, tier: Tier.a, tactics: const [], by: ana).valueOrNull?.placements, const [
        TierPlacement(tactic: TacticId('t-2'), tier: Tier.a),
        TierPlacement(tactic: TacticId('t-1'), tier: Tier.a),
      ]);
      expect(placeTactic(list, published, tier: null, tactics: const [], by: ana).valueOrNull?.placements, const [
        TierPlacement(tactic: TacticId('t-2'), tier: Tier.a),
      ]);
    });

    test('refuses a creator and a tactic that is not published', () {
      expect(
        placeTactic(
          list,
          tactic('t-1', Published(at: now)),
          tier: Tier.b,
          tactics: const [],
          by: marko,
        ),
        const Failure<TierList>(NotAllowed()),
      );
      expect(
        placeTactic(list, tactic('t-3', const Draft()), tier: Tier.b, tactics: const [], by: ana),
        const Failure<TierList>(NotPlaceable()),
      );
    });

    group('tier S holds at most ${TierList.sCapacity} comps', () {
      const full = TierList(
        patch: PatchId('18.5c'),
        placements: [
          TierPlacement(tactic: TacticId('t-1'), tier: Tier.s),
          TierPlacement(tactic: TacticId('t-2'), tier: Tier.s),
          TierPlacement(tactic: TacticId('t-3'), tier: Tier.s),
          TierPlacement(tactic: TacticId('t-4'), tier: Tier.a),
        ],
      );
      final fourth = tactic('t-4', Published(at: now));

      test('refuses a fourth comp and offers every other tier', () {
        expect(
          placeTactic(full, fourth, tier: Tier.s, tactics: const [], by: ana),
          const Failure<TierList>(TierFull(Tier.s, max: 3)),
        );
        expect(placeableTiers(full, fourth, const [], ana), {Tier.a, Tier.b, Tier.c, Tier.situational, null});
      });

      test('counts a hidden comp, so restoring it never overfills the tier', () {
        final tactics = [
          tactic('t-2', Hidden(reason: HideReason.parse('Zastarela taktika').valueOrNull!, by: ana.id, at: now)),
        ];
        expect(placeTactic(full, fourth, tier: Tier.s, tactics: tactics, by: ana).isSuccess, isFalse);
      });

      test('does not count an archived comp', () {
        final tactics = [tactic('t-2', Archived(at: now))];
        expect(placeTactic(full, fourth, tier: Tier.s, tactics: tactics, by: ana).isSuccess, isTrue);
      });

      test('lets a comp already in S stay there, and moving one out frees a place', () {
        expect(
          placeTactic(
            full,
            tactic('t-1', Published(at: now)),
            tier: Tier.s,
            tactics: const [],
            by: ana,
          ).isSuccess,
          isTrue,
        );
        final freed = placeTactic(
          full,
          tactic('t-1', Published(at: now)),
          tier: Tier.a,
          tactics: const [],
          by: ana,
        );
        expect(placeTactic(freed.valueOrNull!, fourth, tier: Tier.s, tactics: const [], by: ana).isSuccess, isTrue);
      });
    });
  });
}
