import 'package:bloc_test/bloc_test.dart';
import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:test/test.dart';
import 'package:use_cases/use_cases.dart';

import 'fake_tactics.dart';

void main() {
  final now = DateTime.utc(2026, 10, 28, 12);
  const ahri = Champion(id: ChampionId('ahri'), name: 'Ahri', cost: 4);

  Tactic tactic(String id, User author, TacticStatus status) => Tactic(
    id: TacticId(id),
    authorId: author.id,
    authorName: author.name,
    title: id,
    description: '',
    carry: ahri,
    status: status,
    updatedAt: now,
  );

  TacticsBloc blocWith(FakeTactics tactics, {User user = marko}) => TacticsBloc(
    getTactics: GetTactics(tactics: tactics),
    getTierList: GetTierList(tactics: tactics),
    changeStatus: ChangeTacticStatus(tactics: tactics, clock: FixedClock(now)),
    clock: FixedClock(now),
    user: user,
  );

  blocTest<TacticsBloc, TacticsState>(
    'TacticsBloc builds the comps from everyone and my tactics from mine',
    build: () => blocWith(
      FakeTactics(
        tactics: [
          tactic('t-1', marko, const Draft()),
          tactic('t-2', luka, Published(at: now)),
          tactic('t-3', luka, const Draft()),
        ],
        tierList: const TierList(
          patch: PatchId('18.5c'),
          placements: [TierPlacement(tactic: TacticId('t-2'), tier: Tier.s)],
        ),
      ),
    ),
    act: (bloc) => bloc.add(const TacticsRequested()),
    expect: () => [
      const TacticsLoading(),
      isA<TacticsLoaded>()
          .having((s) => s.mine.single.id, 'mine', const TacticId('t-1'))
          .having((s) => s.comps[Tier.s]!.single.id, 'comps', const TacticId('t-2')),
    ],
  );

  blocTest<TacticsBloc, TacticsState>(
    'TacticsBloc reports an empty answer',
    build: () => blocWith(FakeTactics()),
    act: (bloc) => bloc.add(const TacticsRequested()),
    expect: () => [const TacticsLoading(), const TacticsEmpty()],
  );

  late FakeTactics source;
  blocTest<TacticsBloc, TacticsState>(
    'TacticsBloc refreshes without the loader and finishes the pull',
    build: () => blocWith(source = FakeTactics()),
    act: (bloc) async {
      bloc.add(const TacticsRequested());
      await bloc.stream.firstWhere((s) => s is TacticsEmpty);
      source.tactics.add(tactic('t-1', marko, const Draft()));
      final refresh = TacticsRefreshed();
      bloc.add(refresh);
      await refresh.handled;
    },
    expect: () => [const TacticsLoading(), const TacticsEmpty(), isA<TacticsLoaded>()],
  );

  blocTest<TacticsBloc, TacticsState>(
    'TacticsBloc reports a failed request',
    build: () => blocWith(FakeTactics(failing: true)),
    act: (bloc) => bloc.add(const TacticsRequested()),
    expect: () => [const TacticsLoading(), isA<TacticsFailure>()],
  );

  blocTest<TacticsBloc, TacticsState>(
    'TacticsBloc marks my tactic in flight, archives it and reports it in the reloaded state',
    build: () => blocWith(FakeTactics(tactics: [tactic('t-1', marko, const Draft())])),
    act: (bloc) async {
      bloc.add(const TacticsRequested());
      await bloc.stream.firstWhere((s) => s is TacticsLoaded);
      bloc.add(const TacticActionRequested(TacticId('t-1'), TacticAction.archive));
    },
    skip: 2,
    expect: () => [
      isA<TacticsLoaded>().having((s) => s.inFlightId, 'in flight', const TacticId('t-1')),
      isA<TacticsLoaded>()
          .having((s) => s.mine.single.status, 'status', Archived(at: now))
          .having((s) => s.notice, 'notice', isA<TacticChanged>())
          .having((s) => s.actionsFor(const TacticId('t-1')), 'actions', isEmpty)
          .having((s) => s.isBusy, 'busy', isFalse),
    ],
  );

  blocTest<TacticsBloc, TacticsState>(
    'TacticsBloc leaves only hidden tactics visible under the Hidden filter',
    build: () => blocWith(
      FakeTactics(
        tactics: [
          tactic('t-1', marko, const Draft()),
          tactic('t-2', luka, Published(at: now)),
          tactic(
            't-3',
            marko,
            Hidden(reason: HideReason.parse('Kopija tuđe taktike').valueOrNull!, by: const UserId('u-ana'), at: now),
          ),
        ],
      ),
    ),
    act: (bloc) async {
      bloc.add(const TacticsRequested());
      await bloc.stream.firstWhere((s) => s is TacticsLoaded);
      bloc.add(const TacticsFilterChanged(TacticStatusKind.hidden));
    },
    skip: 2,
    expect: () => [
      isA<TacticsLoaded>().having((s) => s.visible.map((t) => t.id), 'visible', [const TacticId('t-3')]),
    ],
  );

  blocTest<TacticsBloc, TacticsState>(
    'TacticsBloc lets an admin hide a published tactic with a reason',
    build: () => blocWith(
      FakeTactics(tactics: [tactic('t-1', luka, Published(at: now))]),
      user: ana,
    ),
    act: (bloc) async {
      bloc.add(const TacticsRequested());
      await bloc.stream.firstWhere((s) => s is TacticsLoaded);
      bloc.add(
        TacticActionRequested(
          const TacticId('t-1'),
          TacticAction.hide,
          reason: HideReason.parse('Kopija tuđe taktike').valueOrNull,
        ),
      );
    },
    skip: 3,
    expect: () => [
      isA<TacticsLoaded>()
          .having((s) => s.tactics.single.status, 'status', isA<Hidden>())
          .having((s) => s.notice, 'notice', isA<TacticChanged>())
          .having((s) => s.actionsFor(const TacticId('t-1')), 'actions', {TacticAction.restore}),
    ],
  );

  blocTest<TacticsBloc, TacticsState>(
    'TacticsBloc matches the search against the title and the author and keeps it across a reload',
    build: () => blocWith(
      FakeTactics(
        tactics: [
          tactic('t-1', marko, const Draft()),
          tactic('t-2', luka, Published(at: now)),
        ],
      ),
    ),
    act: (bloc) async {
      bloc.add(const TacticsRequested());
      await bloc.stream.firstWhere((s) => s is TacticsLoaded);
      bloc.add(const TacticsSearchChanged(' LUKA'));
      await bloc.stream.firstWhere((s) => s is TacticsLoaded && s.search.isNotEmpty);
      final refresh = TacticsRefreshed();
      bloc.add(refresh);
      await refresh.handled;
    },
    verify: (bloc) => expect((bloc.state as TacticsLoaded).visible.map((t) => t.id), [const TacticId('t-2')]),
  );
}
