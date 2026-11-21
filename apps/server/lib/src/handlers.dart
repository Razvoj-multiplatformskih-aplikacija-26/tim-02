import 'package:api_mapping/api_mapping.dart';
import 'package:domain/domain.dart';
import 'package:relic/relic.dart' hide Result;
import 'package:use_cases/use_cases.dart';

import 'http.dart';
import 'postgres_tactics.dart';

final class TacticHandlers {
  TacticHandlers({required PostgresTactics tactics})
    : _tactics = tactics,
      _getTactics = GetTactics(tactics: tactics),
      _getTierList = GetTierList(tactics: tactics),
      _getCatalog = GetCatalog(catalog: tactics);

  final PostgresTactics _tactics;
  final GetTactics _getTactics;
  final GetTierList _getTierList;
  final GetCatalog _getCatalog;

  Future<Response> catalog(Request request) async => json(200, (await _getCatalog()).toDto().toJson());

  Future<Response> tierList(Request request) async => json(200, (await _getTierList()).toDto().toJson());

  Future<Response> list(Request request) async =>
      json(200, [for (final tactic in await _getTactics(null)) tactic.toDto().toJson()]);

  Future<Response> find(Request request) async {
    final tactic = await _tactics.find(TacticId(request.rawPathParameters[#id]!));
    if (tactic == null || visibleTactics([tactic], null).isEmpty) return problem(const NotFound());
    return json(200, tactic.toDto().toJson());
  }
}
