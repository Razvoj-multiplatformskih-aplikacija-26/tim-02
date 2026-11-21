import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

const marko = User(id: UserId('u-marko'), name: 'Marko', role: Role.creator);
const luka = User(id: UserId('u-luka'), name: 'Luka', role: Role.creator);
const ana = User(id: UserId('u-ana'), name: 'Ana', role: Role.admin);

final class FakeTactics implements TacticRepository, CatalogRepository {
  FakeTactics({
    List<Tactic> tactics = const [],
    this.tierList = const TierList(patch: PatchId('18.5c'), placements: []),
    this.failing = false,
  }) : tactics = List.of(tactics);

  final List<Tactic> tactics;
  TierList tierList;
  bool failing;

  @override
  Future<List<Tactic>> all() async {
    if (failing) throw const RepositoryException('simulated outage');
    return List.of(tactics);
  }

  @override
  Future<TierList> currentTierList() async => tierList;

  @override
  Future<Tactic?> find(TacticId id) async {
    if (failing) throw const RepositoryException('simulated outage');
    return tactics.where((t) => t.id == id).firstOrNull;
  }

  @override
  Future<Result<Tactic>> create(Tactic draft) async {
    tactics.insert(0, draft);
    return Success(draft);
  }

  @override
  Future<Result<Tactic>> save(Tactic tactic, {required TacticStatus from}) async {
    final index = tactics.indexWhere((t) => t.id == tactic.id);
    final stored = tactics[index];
    if (stored.status != from) return Failure(InvalidTransition(from: stored.status, to: tactic.status));
    tactics[index] = tactic;
    return Success(tactic);
  }

  @override
  Future<Result<TacticId>> delete(TacticId id) async {
    tactics.removeWhere((t) => t.id == id);
    return Success(id);
  }

  @override
  Future<Result<TierList>> place(Tactic tactic, Tier? tier, {required User by}) async {
    final placed = placeTactic(tierList, tactic, tier: tier, tactics: tactics, by: by);
    if (placed case Success(:final value)) tierList = value;
    return placed;
  }

  @override
  Future<Catalog> catalog() async => const Catalog(champions: [], items: []);
}
