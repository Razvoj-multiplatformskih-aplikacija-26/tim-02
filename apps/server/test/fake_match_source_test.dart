import 'dart:io';

import 'package:demo_data/demo_data.dart';
import 'package:domain/domain.dart';
import 'package:server/server.dart';
import 'package:test/test.dart';

void main() {
  final source = FakeMatchSource(File('fixtures/matches.json'));

  test('gives the newest matches first, as many as asked for', () async {
    final matches = await source.recentMatches(count: 2);

    expect(matches.map((match) => match.id), const [MatchId('EUN1_3810452291'), MatchId('EUN1_3810398874')]);
    expect(matches.first.playedAt, DateTime.utc(2026, 11, 20, 21, 14));
  });

  test('every match has eight boards placed 1 to 8, made of champions from the catalog', () async {
    final champions = {for (final champion in seedCatalog.champions) champion.id};

    for (final match in await source.recentMatches(count: recentMatchCount)) {
      expect(match.boards.map((board) => board.placement), [1, 2, 3, 4, 5, 6, 7, 8]);
      expect(match.boards.expand((board) => board.champions).every(champions.contains), isTrue);
    }
  });
}
