import 'package:domain/domain.dart';

abstract interface class LineupRepository {
  Future<List<PersonalLineup>> all();

  Future<PersonalLineup> save(PersonalLineup lineup);

  Future<Catalog> catalog();
}
