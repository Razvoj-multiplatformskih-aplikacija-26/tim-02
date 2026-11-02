import 'package:domain/domain.dart';

abstract interface class TacticRepository {
  Future<List<Tactic>> all();

  Future<TierList> currentTierList();

  Future<Tactic?> find(TacticId id);

  Future<Tactic> save(Tactic tactic);
}
