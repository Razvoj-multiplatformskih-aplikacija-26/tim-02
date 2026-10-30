import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'seed.dart';

final class FakeTactics implements TacticRepository {
  FakeTactics({required Clock clock, this.latency = const Duration(milliseconds: 700)})
    : _tactics = seedTactics(clock.now());

  final Duration latency;
  final List<Tactic> _tactics;

  Future<void> _roundTrip() async {
    await Future<void>.delayed(latency);
  }

  @override
  Future<List<Tactic>> all() async {
    await _roundTrip();
    return List.of(_tactics);
  }

  @override
  Future<TierList> currentTierList() async {
    await _roundTrip();
    return seedTierList;
  }
}
