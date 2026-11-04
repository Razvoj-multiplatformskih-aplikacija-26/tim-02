import 'package:domain/domain.dart';

import 'catalog_repository.dart';

abstract interface class LineupRepository implements CatalogRepository {
  Future<List<PersonalLineup>> all();

  Future<PersonalLineup> save(PersonalLineup lineup);

  Future<void> delete(LineupId id);
}
