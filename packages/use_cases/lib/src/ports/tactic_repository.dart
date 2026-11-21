import 'package:domain/domain.dart';

abstract interface class TacticRepository {
  Future<List<Tactic>> all();

  Future<TierList> currentTierList();

  Future<Tactic?> find(TacticId id);

  Future<Result<Tactic>> create(Tactic draft);

  Future<Result<Tactic>> save(Tactic tactic, {required TacticStatus from});

  Future<Result<TacticId>> delete(TacticId id);

  Future<Result<TierList>> place(Tactic tactic, Tier? tier, {required User by});
}
