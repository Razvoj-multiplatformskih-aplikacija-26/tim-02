import 'package:domain/domain.dart';

abstract interface class MatchSource {
  Future<List<MatchRecord>> recentMatches({required int count});
}
