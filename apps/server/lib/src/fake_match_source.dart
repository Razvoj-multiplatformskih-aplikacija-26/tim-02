import 'dart:convert';
import 'dart:io';

import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

final class FakeMatchSource implements MatchSource {
  const FakeMatchSource(this.file);

  final File file;

  @override
  Future<List<MatchRecord>> recentMatches({required int count}) async {
    final matches = jsonDecode(await file.readAsString()) as List<Object?>;
    return [for (final match in matches.take(count)) _match(match! as Map<String, Object?>)];
  }
}

MatchRecord _match(Map<String, Object?> json) => MatchRecord(
  id: MatchId(json['id']! as String),
  patch: PatchId(json['patch']! as String),
  playedAt: DateTime.parse(json['playedAt']! as String),
  boards: [
    for (final board in json['boards']! as List<Object?>)
      if (board case {'placement': final int placement, 'champions': final List<Object?> champions})
        MatchBoard(placement: placement, champions: [for (final id in champions) ChampionId(id! as String)]),
  ],
);
