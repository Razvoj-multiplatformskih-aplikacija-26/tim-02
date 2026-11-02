import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'catalog.dart';
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

  @override
  Future<PersonalLineup> save(PersonalLineup lineup) async {
    await Future<void>.delayed(latency);
    _lineups.add(lineup);
    return lineup;
  }

  @override
  Future<Catalog> catalog() async {
    await Future<void>.delayed(latency);
    return seedCatalog;
  }
}
