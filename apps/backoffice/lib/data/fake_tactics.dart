import 'package:demo_data/demo_data.dart';
import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

final class FakeTactics implements TacticRepository, CatalogRepository {
  FakeTactics({required Clock clock, this.latency = const Duration(milliseconds: 700)})
    : _tactics = seedTactics(clock.now());

  final Duration latency;
  final List<Tactic> _tactics;
  TierList _tierList = seedTierList;
  int failingRequests = 0;
  int emptyResponses = 0;

  Future<void> _roundTrip() async {
    await Future<void>.delayed(latency);
    if (failingRequests > 0) {
      failingRequests--;
      throw const RepositoryException('Simulated outage');
    }
  }

  @override
  Future<List<Tactic>> all() async {
    await _roundTrip();
    if (emptyResponses > 0) {
      emptyResponses--;
      return const [];
    }
    return List.of(_tactics);
  }

  @override
  Future<TierList> currentTierList() async {
    await _roundTrip();
    return _tierList;
  }

  @override
  Future<Tactic?> find(TacticId id) async {
    await _roundTrip();
    return _tactics.where((t) => t.id == id).firstOrNull;
  }

  @override
  Future<Result<Tactic>> create(Tactic draft) async {
    await _roundTrip();
    _tactics.insert(0, draft);
    return Success(draft);
  }

  @override
  Future<Result<Tactic>> save(Tactic tactic, {required TacticStatus from}) async {
    await _roundTrip();
    final index = _tactics.indexWhere((t) => t.id == tactic.id);
    if (index < 0) return const Failure(NotFound());
    final stored = _tactics[index];
    if (stored.status != from) return Failure(InvalidTransition(from: stored.status, to: tactic.status));
    _tactics[index] = tactic;
    return Success(tactic);
  }

  @override
  Future<Result<TacticId>> delete(TacticId id) async {
    await _roundTrip();
    final index = _tactics.indexWhere((t) => t.id == id);
    if (index < 0) return const Failure(NotFound());
    if (_tactics[index].status is! Draft) return const Failure(NotAllowed());
    _tactics.removeAt(index);
    return Success(id);
  }

  @override
  Future<TierList> saveTierList(TierList tierList) async {
    await _roundTrip();
    return _tierList = tierList;
  }

  @override
  Future<Catalog> catalog() async {
    await _roundTrip();
    return seedCatalog;
  }
}
