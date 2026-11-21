import 'package:domain/domain.dart';
import 'package:postgres/postgres.dart' show Pool;
import 'package:use_cases/use_cases.dart';

import 'tactic_store.dart';

final class PostgresTactics implements TacticRepository, CatalogRepository {
  PostgresTactics(this._database);

  final Pool<void> _database;

  TacticStore get _store => TacticStore(_database);

  @override
  Future<Catalog> catalog() => _store.catalog();

  @override
  Future<List<Tactic>> all() => _store.tactics();

  @override
  Future<TierList> currentTierList() => _store.tierList();

  @override
  Future<Tactic?> find(TacticId id) => _store.tactic(id);

  @override
  Future<Result<Tactic>> create(Tactic draft) async {
    final id = await _store.insert(draft, newId: true);
    return Success((await _store.tactic(id))!);
  }

  @override
  Future<Result<Tactic>> save(Tactic tactic, {required TacticStatus from}) async {
    if (await _store.update(tactic, from: from)) return Success(tactic);
    return switch (await _store.tactic(tactic.id)) {
      null => const Failure(NotFound()),
      final current => Failure(InvalidTransition(from: current.status, to: tactic.status)),
    };
  }

  @override
  Future<Result<TacticId>> delete(TacticId id) async {
    if (await _store.deleteDraft(id)) return Success(id);
    return await _store.tactic(id) == null ? const Failure(NotFound()) : const Failure(NotAllowed());
  }

  @override
  Future<Result<TierList>> place(Tactic tactic, Tier? tier, {required User by}) => _database.runTx((session) async {
    final store = TacticStore(session);
    final tierList = await store.tierList(locked: true);
    final current = await store.tactic(tactic.id);
    if (current == null) return const Failure(NotFound());
    final placed = placeTactic(tierList, current, tier: tier, tactics: await store.tactics(), by: by);
    if (placed case Success(:final value)) await store.replacePlacements(value);
    return placed;
  });
}
