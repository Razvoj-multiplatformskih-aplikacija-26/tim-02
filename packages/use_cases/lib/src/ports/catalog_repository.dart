import 'package:domain/domain.dart';

abstract interface class CatalogRepository {
  Future<Catalog> catalog();
}
