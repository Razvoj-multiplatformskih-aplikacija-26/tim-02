import 'package:domain/domain.dart';

abstract interface class TacticRepository {
  Future<List<Tactic>> all();

  Future<TierList> currentTierList();
}
