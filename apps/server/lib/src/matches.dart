import 'dart:convert';

import 'package:postgres/postgres.dart' show Pool, Sql;
import 'package:use_cases/use_cases.dart';

const recentMatchCount = 20;

Future<void> importMatches(Pool<void> database, MatchSource source) async {
  final stored = await database.execute('SELECT count(*) FROM matches');
  if (stored.single[0] != 0) return;
  final matches = await source.recentMatches(count: recentMatchCount);
  await database.runTx((session) async {
    for (final match in matches) {
      await session.execute(
        Sql.named('INSERT INTO matches (id, patch, played_at, data) VALUES (@id, @patch, @playedAt, @data::jsonb)'),
        parameters: {
          'id': match.id.value,
          'patch': match.patch.value,
          'playedAt': match.playedAt,
          'data': jsonEncode({
            'boards': [
              for (final board in match.boards)
                {
                  'placement': board.placement,
                  'champions': [for (final champion in board.champions) champion.value],
                },
            ],
          }),
        },
      );
    }
  });
}
