import 'package:domain/domain.dart';

abstract interface class LineupRepository {
  Future<List<PersonalLineup>> all();
}
