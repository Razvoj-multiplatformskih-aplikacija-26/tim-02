import 'package:bloc_test/bloc_test.dart';
import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:test/test.dart';
import 'package:use_cases/use_cases.dart';

import 'fake_tactics.dart';

void main() {
  final now = DateTime.utc(2026, 11, 3, 20);
  const ahri = Champion(id: ChampionId('ahri'), name: 'Ahri', cost: 4);
  const ezreal = Champion(id: ChampionId('ezreal'), name: 'Ezreal', cost: 4);
  const sword = Item(id: ItemId('sword'), name: 'B.F. Sword');
  final front = HexPosition.parse(0, 3).valueOrNull!;
  final back = HexPosition.parse(3, 3).valueOrNull!;
  final board = const Lineup.empty()
      .place(
        Placement(
          unit: Unit.parse(ahri, stars: 2, items: [sword]).valueOrNull!,
          position: back,
        ),
      )
      .valueOrNull!;
  final tactic = Tactic(
    id: const TacticId('t-1'),
    authorId: luka.id,
    authorName: luka.name,
    title: 'Ahri',
    description: '',
    carry: ahri,
    status: Published(at: now),
    updatedAt: now,
    variants: [
      TacticVariant(
        name: 'Ahri 8',
        playstyle: Playstyle.fast8,
        difficulty: Difficulty.medium,
        early: const Lineup.empty(),
        lineup: board,
        flex: const [],
        itemPriority: const [],
        tip: '',
        stageTips: const {},
      ),
    ],
  );

  late FakeTactics source;
  TacticEditorBloc editor() {
    source = FakeTactics(tactics: [tactic]);
    return TacticEditorBloc(
      editTactic: EditTactic(tactics: source, clock: FixedClock(now)),
      getCatalog: GetCatalog(catalog: source),
      user: ana,
      tactic: tactic,
    );
  }

  blocTest<TacticEditorBloc, TacticEditorState>(
    'TacticEditorBloc loads the chosen hex and keeps a fourth item off the board',
    build: editor,
    act: (bloc) {
      bloc.add(TacticHexChosen(back));
      for (var i = 0; i < 3; i++) {
        bloc.add(const TacticItemAdded(sword));
      }
    },
    skip: 3,
    verify: (bloc) {
      expect(bloc.state.champion, ahri);
      expect(bloc.state.stars, 2);
      expect(bloc.state.placed, const Failure<Lineup>(TooManyItems(4)));
    },
  );

  blocTest<TacticEditorBloc, TacticEditorState>(
    'TacticEditorBloc replaces the unit on the chosen hex and saves the edited tactic',
    build: editor,
    act: (bloc) async {
      bloc
        ..add(TacticHexChosen(back))
        ..add(const TacticUnitChanged(champion: ezreal))
        ..add(const TacticUnitPlaced())
        ..add(TacticHexChosen(front))
        ..add(const TacticUnitChanged(champion: ahri))
        ..add(const TacticUnitPlaced())
        ..add(const TacticTitleChanged('Ezreal i Ahri'))
        ..add(const TacticEditorSubmitted());
    },
    verify: (bloc) {
      expect(bloc.state.status, TacticEditorStatus.saved);
      final saved = source.tactics.single;
      expect(saved.title, 'Ezreal i Ahri');
      expect(saved.variants.single.lineup.placements.map((p) => (p.unit.champion, p.position)), [
        (ezreal, back),
        (ahri, front),
      ]);
    },
  );

  blocTest<TacticEditorBloc, TacticEditorState>(
    'TacticEditorBloc keeps an empty title from being saved',
    build: editor,
    act: (bloc) => bloc
      ..add(const TacticTitleChanged(' '))
      ..add(const TacticEditorSubmitted()),
    verify: (bloc) {
      expect(bloc.state.titleError, const InvalidTacticTitle(0));
      expect(bloc.state.error, const InvalidTacticTitle(0));
      expect(source.tactics.single.title, 'Ahri');
    },
  );

  blocTest<TacticEditorBloc, TacticEditorState>(
    'TacticEditorBloc keeps a variant without champions on its final board from being saved',
    build: editor,
    act: (bloc) => bloc
      ..add(TacticHexChosen(back))
      ..add(const TacticUnitRemoved())
      ..add(const TacticEditorSubmitted()),
    verify: (bloc) {
      expect(bloc.state.error, const EmptyBoard());
      expect(source.tactics.single.variants.single.lineup, board);
    },
  );

  blocTest<TacticEditorBloc, TacticEditorState>(
    'TacticEditorBloc moves a unit to another hex and selects it there',
    build: editor,
    act: (bloc) => bloc.add(TacticUnitMoved(back, front)),
    verify: (bloc) {
      expect(bloc.state.board.placements.single.position, front);
      expect(bloc.state.hex, front);
      expect(bloc.state.champion, ahri);
    },
  );

  blocTest<TacticEditorBloc, TacticEditorState>(
    'TacticEditorBloc saves the tip and the stage tips in order and drops an emptied stage',
    build: editor,
    act: (bloc) => bloc
      ..add(const TacticTipChanged('Igraj za niz pobeda.'))
      ..add(const TacticStageTipChanged(4, 'Nivo 8.'))
      ..add(const TacticStageTipChanged(2, 'Jak početak.'))
      ..add(const TacticStageTipChanged(4, ' '))
      ..add(const TacticEditorSubmitted()),
    verify: (bloc) {
      final saved = source.tactics.single.variants.single;
      expect(saved.tip, 'Igraj za niz pobeda.');
      expect(saved.stageTips, {2: 'Jak početak.'});
    },
  );
}
