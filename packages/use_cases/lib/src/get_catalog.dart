import 'package:domain/domain.dart';

import 'ports/lineup_repository.dart';

final class GetCatalog {
  const GetCatalog({required this.lineups});

  final LineupRepository lineups;

  Future<Catalog> call() => lineups.catalog();
}
