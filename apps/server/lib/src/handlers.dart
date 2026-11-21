import 'package:api_contract/api_contract.dart';
import 'package:api_mapping/api_mapping.dart';
import 'package:domain/domain.dart';
import 'package:relic/relic.dart' hide Result;
import 'package:use_cases/use_cases.dart';

import 'http.dart';
import 'postgres_tactics.dart';
import 'sessions.dart';

final class TacticHandlers {
  TacticHandlers({required PostgresTactics tactics, required Clock clock})
    : _tactics = tactics,
      _getTactics = GetTactics(tactics: tactics),
      _getTierList = GetTierList(tactics: tactics),
      _getCatalog = GetCatalog(catalog: tactics),
      _saveDraft = SaveDraft(tactics: tactics, clock: clock),
      _editTactic = EditTactic(tactics: tactics, clock: clock),
      _deleteDraft = DeleteDraft(tactics: tactics),
      _changeStatus = ChangeTacticStatus(tactics: tactics, clock: clock),
      _placeTactic = PlaceTactic(tactics: tactics);

  final PostgresTactics _tactics;
  final GetTactics _getTactics;
  final GetTierList _getTierList;
  final GetCatalog _getCatalog;
  final SaveDraft _saveDraft;
  final EditTactic _editTactic;
  final DeleteDraft _deleteDraft;
  final ChangeTacticStatus _changeStatus;
  final PlaceTactic _placeTactic;

  Future<Response> catalog(Request request) async => json(200, (await _getCatalog()).toDto().toJson());

  Future<Response> tierList(Request request) async => json(200, (await _getTierList()).toDto().toJson());

  Future<Response> list(Request request) async =>
      json(200, [for (final tactic in await _getTactics(_actor(request))) tactic.toDto().toJson()]);

  Future<Response> find(Request request) async {
    final tactic = await _tactics.find(TacticId(request.rawPathParameters[#id]!));
    if (tactic == null || visibleTactics([tactic], _actor(request)).isEmpty) return problem(const NotFound());
    return json(200, tactic.toDto().toJson());
  }

  Future<Response> create(Request request) async {
    final body = NewTacticDto.fromJson(await readObject(request));
    return switch (_variants(body.variants, await _getCatalog())) {
      Failure(:final error) => problem(error),
      Success(value: final variants) => respond(
        await _saveDraft(by: _signedIn(request), title: body.title, variants: variants),
        _tacticJson,
        status: 201,
      ),
    };
  }

  Future<Response> edit(Request request) => _change(request, (id, actor) async {
    final body = TacticChangesDto.fromJson(await readObject(request));
    return switch (_variants(body.variants, await _getCatalog())) {
      Failure(:final error) => problem(error),
      Success(value: final variants) => respond(
        await _editTactic(id: id, by: actor, title: body.title, description: body.description, variants: variants),
        _tacticJson,
      ),
    };
  });

  Future<Response> delete(Request request) => _change(
    request,
    (id, actor) async => switch (await _deleteDraft(id, by: actor)) {
      Failure(:final error) => problem(error),
      Success() => Response.noContent(),
    },
  );

  Future<Response> publish(Request request) => _status(request, TacticAction.publish);

  Future<Response> restore(Request request) => _status(request, TacticAction.restore);

  Future<Response> archive(Request request) => _status(request, TacticAction.archive);

  Future<Response> hide(Request request) => _change(request, (id, actor) async {
    final body = HideDto.fromJson(await readObject(request));
    return switch (HideReason.parse(body.reason)) {
      Failure(:final error) => problem(error),
      Success(value: final reason) => respond(
        await _changeStatus(id: id, action: TacticAction.hide, by: actor, reason: reason),
        _tacticJson,
      ),
    };
  });

  Future<Response> place(Request request) => _change(request, (id, actor) async {
    final body = TierChangeDto.fromJson(await readObject(request));
    final tier = switch (body.tier) {
      null => null,
      final name => Tier.values.asNameMap()[name] ?? (throw FormatException('Unknown tier', name)),
    };
    return respond(await _placeTactic(id: id, tier: tier, by: actor), (tierList) => tierList.toDto().toJson());
  });

  Future<Response> _status(Request request, TacticAction action) => _change(
    request,
    (id, actor) async => respond(await _changeStatus(id: id, action: action, by: actor), _tacticJson),
  );

  Future<Response> _change(Request request, Future<Response> Function(TacticId id, User actor) change) async {
    final id = TacticId(request.rawPathParameters[#id]!);
    final actor = _signedIn(request);
    final tactic = await _tactics.find(id);
    if (tactic == null || !AccessPolicy.canView(actor, tactic)) return problem(const NotFound());
    return change(id, actor);
  }

  User? _actor(Request request) => currentSession[request]?.user;

  User _signedIn(Request request) => currentSession.get(request).user;
}

Object? _tacticJson(Tactic tactic) => tactic.toDto().toJson();

Result<List<TacticVariant>> _variants(List<TacticVariantDto> dtos, Catalog catalog) {
  final variants = <TacticVariant>[];
  for (final dto in dtos) {
    switch (dto.toDomain()) {
      case Failure(:final error):
        return Failure(error);
      case Success(:final value):
        _requireCatalog(value, catalog);
        variants.add(value);
    }
  }
  return Success(variants);
}

void _requireCatalog(TacticVariant variant, Catalog catalog) {
  final units = [
    for (final placement in [...variant.early.placements, ...variant.lineup.placements]) placement.unit,
    ...variant.flex,
  ];
  for (final unit in units) {
    if (!catalog.champions.contains(unit.champion)) throw FormatException('Unknown champion', unit.champion.id.value);
  }
  for (final item in [...units.expand((unit) => unit.items), ...variant.itemPriority]) {
    if (!catalog.items.contains(item)) throw FormatException('Unknown item', item.id.value);
  }
}
