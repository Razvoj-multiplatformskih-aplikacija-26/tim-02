import 'package:api_contract/api_contract.dart';
import 'package:api_mapping/api_mapping.dart';
import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'api_client.dart';

final class HttpTacticRepository implements TacticRepository {
  const HttpTacticRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<Tactic>> all() async {
    final answer = await _api.get(ApiPaths.tactics);
    return accepted(answer, (json) => [for (final item in objects(json)) _tactic(item)]);
  }

  @override
  Future<TierList> currentTierList() async => accepted(await _api.get(ApiPaths.tierList), _tierList);

  @override
  Future<Tactic?> find(TacticId id) async {
    final answer = await _api.get(ApiPaths.tactic(id.value));
    if (answer case ApiRejected(error: NotFound())) return null;
    return accepted(answer, _tactic);
  }

  @override
  Future<Result<Tactic>> create(Tactic draft) async {
    final body = NewTacticDto(title: draft.title, variants: [for (final variant in draft.variants) variant.toDto()]);
    return resultOf(await _api.post(ApiPaths.tactics, body: body.toJson()), _tactic);
  }

  @override
  Future<Result<Tactic>> save(Tactic tactic, {required TacticStatus from}) async {
    final id = tactic.id.value;
    final answer = await switch ((from, tactic.status)) {
      _ when from.kind == tactic.status.kind => _api.put(ApiPaths.tactic(id), body: _changes(tactic).toJson()),
      (Hidden(), Published()) => _api.post(ApiPaths.restoration(id)),
      (_, Published()) => _api.post(ApiPaths.publication(id)),
      (_, Hidden(:final reason)) => _api.post(ApiPaths.hiding(id), body: HideDto(reason: reason.text).toJson()),
      (_, Archived()) => _api.post(ApiPaths.archive(id)),
      (_, Draft()) => throw ArgumentError.value(tactic, 'tactic', 'A tactic never goes back to a draft'),
    };
    return resultOf(answer, _tactic);
  }

  @override
  Future<Result<TacticId>> delete(TacticId id) async =>
      resultOf(await _api.delete(ApiPaths.tactic(id.value)), (_) => id);

  @override
  Future<Result<TierList>> place(Tactic tactic, Tier? tier, {required User by}) async {
    final body = TierChangeDto(tier: tier?.name);
    return resultOf(await _api.put(ApiPaths.tierPlacement(tactic.id.value), body: body.toJson()), _tierList);
  }

  TacticChangesDto _changes(Tactic tactic) => TacticChangesDto(
    title: tactic.title,
    description: tactic.description,
    variants: [for (final variant in tactic.variants) variant.toDto()],
  );

  Tactic _tactic(Object? json) => TacticDto.fromJson(object(json)).toDomain();

  TierList _tierList(Object? json) => TierListDto.fromJson(object(json)).toDomain();
}
