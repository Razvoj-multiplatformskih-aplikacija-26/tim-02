import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'seed.dart';

final class FakeLineups implements LineupRepository {
  FakeLineups({this.latency = const Duration(milliseconds: 700)}) : _lineups = seedLineups();

  final Duration latency;
  final List<PersonalLineup> _lineups;

  @override
  Future<List<PersonalLineup>> all() async {
    await Future<void>.delayed(latency);
    return List.of(_lineups);
  }
}
