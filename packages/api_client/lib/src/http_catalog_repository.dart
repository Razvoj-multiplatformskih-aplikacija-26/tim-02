import 'package:api_contract/api_contract.dart';
import 'package:api_mapping/api_mapping.dart';
import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'api_client.dart';

final class HttpCatalogRepository implements CatalogRepository {
  const HttpCatalogRepository(this._api);

  final ApiClient _api;

  @override
  Future<Catalog> catalog() async {
    final answer = await _api.get(ApiPaths.catalog);
    return accepted(answer, (json) => CatalogDto.fromJson(object(json)).toDomain());
  }
}
