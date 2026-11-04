import 'package:domain/domain.dart';

import 'ports/catalog_repository.dart';

final class GetCatalog {
  const GetCatalog({required this.catalog});

  final CatalogRepository catalog;

  Future<Catalog> call() => catalog.catalog();
}
