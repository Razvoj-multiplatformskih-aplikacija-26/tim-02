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
  Future<Tactic> save(Tactic tactic) async {
    tactics[tactics.indexWhere((t) => t.id == tactic.id)] = tactic;
    return tactic;
  }

  @override
  Future<TierList> saveTierList(TierList tierList) async => this.tierList = tierList;

  @override
  Future<Catalog> catalog() async => const Catalog(champions: [], items: []);
}
