@Tags(['db'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:api_contract/api_contract.dart';
import 'package:http/http.dart' as http;
import 'package:postgres/postgres.dart';
import 'package:relic/relic.dart' show IOAdapter, RelicServer;
import 'package:server/server.dart';
import 'package:test/test.dart';
import 'package:use_cases/use_cases.dart' show SystemClock;

late Pool<void> database;
late RelicServer server;
late Uri base;
late String demoPassword;

Future<String> logIn(String login) async {
  final answer = await http.post(
    base.replace(path: ApiPaths.sessions),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(LoginDto(username: login, password: demoPassword).toJson()),
  );
  return SessionDto.fromJson(jsonDecode(answer.body) as Map<String, Object?>).token!;
}

Map<String, String> as(String token) => {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};

Future<http.Response> place(String token, String id, String? tier) => http.put(
  base.replace(path: ApiPaths.tierPlacement(id)),
  headers: as(token),
  body: jsonEncode(TierChangeDto(tier: tier).toJson()),
);

Future<http.Response> hide(String token, String id) => http.post(
  base.replace(path: ApiPaths.hiding(id)),
  headers: as(token),
  body: jsonEncode(const HideDto(reason: 'Postava više ne radi na ovom patchu.').toJson()),
);

Future<TacticDto> tactic(String token, String id) async {
  final answer = await http.get(base.replace(path: ApiPaths.tactic(id)), headers: as(token));
  return TacticDto.fromJson(bodyOf(answer));
}

Future<http.Response> edit(String token, TacticDto stored, List<PlacementDto> lineup) {
  final variant = stored.variants.first;
  final changes = TacticChangesDto(
    title: stored.title,
    description: stored.description,
    variants: [
      TacticVariantDto(
        name: variant.name,
        playstyle: variant.playstyle,
        difficulty: variant.difficulty,
        early: variant.early,
        lineup: lineup,
        flex: variant.flex,
        itemPriority: variant.itemPriority,
        tip: variant.tip,
        stageTips: variant.stageTips,
      ),
    ],
  );
  return http.put(
    base.replace(path: ApiPaths.tactic(stored.id)),
    headers: as(token),
    body: jsonEncode(changes.toJson()),
  );
}

Map<String, Object?> bodyOf(http.Response response) => jsonDecode(response.body) as Map<String, Object?>;

Future<void> migrateWithDbmate(Uri databaseUrl) async {
  final insideCompose = databaseUrl.replace(host: 'db', port: 5432, path: '/tft_insights_test');
  final result = await Process.run(
    'docker',
    ['compose', 'run', '--rm', '-e', 'DATABASE_URL=$insideCompose', 'migrate'],
    workingDirectory: '../..',
    runInShell: true,
  );
  if (result.exitCode != 0) throw StateError('dbmate failed: ${result.stderr}');
}

void main() {
  setUpAll(() async {
    final config = ServerConfig.fromEnvironment(serverEnvironment());
    demoPassword = config.demoPassword!;
    final admin = Pool<void>.withUrl(config.databaseUrl);
    await admin.execute('DROP DATABASE IF EXISTS tft_insights_test WITH (FORCE)');
    await admin.execute('CREATE DATABASE tft_insights_test');
    await admin.close();
    database = Pool<void>.withUrl(Uri.parse(config.databaseUrl).replace(path: '/tft_insights_test').toString());
    await migrateWithDbmate(Uri.parse(config.databaseUrl));
    await seedDemoData(database, now: DateTime.now().toUtc(), demoPassword: demoPassword);
    final handlers = TacticHandlers(tactics: PostgresTactics(database), clock: const SystemClock());
    final sessions = SessionHandlers(
      accounts: AccountStore(database),
      secret: config.jwtSecret,
      ttl: const Duration(hours: 1),
    );
    server = RelicServer(() => IOAdapter.bind(InternetAddress.loopbackIPv4, port: 0));
    await server.mountAndStart(buildHandler(handlers, sessions, corsOrigins: const []));
    base = Uri.parse('http://localhost:${server.port}');
  });

  tearDownAll(() async {
    await server.close();
    await database.close();
  });

  test('two admins putting a comp into the last place in S at the same moment: exactly one gets it', () async {
    final ana = await logIn('ana');
    final ivana = await logIn('admin2');

    final answers = await Future.wait([place(ana, 't-05', 's'), place(ivana, 't-06', 's')]);

    expect(answers.map((answer) => answer.statusCode), unorderedEquals([200, 409]));
    final refused = bodyOf(answers.firstWhere((answer) => answer.statusCode == 409));
    expect(refused, containsPair('code', ErrorCodes.tierFull));
    expect(refused, containsPair('max', 2));
    final tierList = TierListDto.fromJson(bodyOf(await http.get(base.replace(path: ApiPaths.tierList))));
    expect(tierList.placements.where((placement) => placement.tier == 's'), hasLength(2));
  });

  test('two admins hiding the same comp at once: one wins, the other is told it already changed', () async {
    final ana = await logIn('ana');
    final ivana = await logIn('admin2');

    final answers = await Future.wait([hide(ana, 't-04'), hide(ivana, 't-04')]);

    expect(answers.map((answer) => answer.statusCode), unorderedEquals([200, 409]));
    expect(
      bodyOf(answers.firstWhere((answer) => answer.statusCode == 409)),
      containsPair('code', ErrorCodes.invalidTransition),
    );
  });

  test(
    'a player may neither hide a comp nor learn that a draft exists, and a creator may not archive the comp of another',
    () async {
      final player = await logIn('korisnik1');
      final hidden = await hide(player, 't-07');
      final placed = await place(player, 't-02', 'a');
      final archived = await http.post(base.replace(path: ApiPaths.archive('t-07')), headers: as(await logIn('luka')));

      expect([hidden.statusCode, placed.statusCode, archived.statusCode], [403, 404, 403]);
      expect(bodyOf(archived), containsPair('code', ErrorCodes.notAllowed));
    },
  );

  test('a unit with four items sent around the app is refused by the same rule as in the app', () async {
    final marko = await logIn('marko');
    final stored = await tactic(marko, 't-07');
    final [first, ...rest] = stored.variants.first.lineup;
    final overloaded = PlacementDto(
      row: first.row,
      column: first.column,
      unit: UnitDto(
        champion: first.unit.champion,
        stars: first.unit.stars,
        items: List.filled(4, stored.variants.first.itemPriority.first),
      ),
    );

    final answer = await edit(marko, stored, [overloaded, ...rest]);

    expect(answer.statusCode, 422);
    expect(bodyOf(answer), containsPair('code', ErrorCodes.tooManyItems));
    expect(bodyOf(answer), containsPair('max', 3));
  });

  test('a champion the catalog lacks or with a changed name or cost is refused; the stored board is saved', () async {
    final marko = await logIn('marko');
    final stored = await tactic(marko, 't-07');
    final [first, ...rest] = stored.variants.first.lineup;
    PlacementDto withChampion(ChampionDto champion) => PlacementDto(
      row: first.row,
      column: first.column,
      unit: UnitDto(champion: champion, stars: first.unit.stars, items: first.unit.items),
    );
    final carry = first.unit.champion;

    final unknown = await edit(marko, stored, [
      withChampion(const ChampionDto(id: 'TFT_Fake', name: 'Fake', cost: 9)),
      ...rest,
    ]);
    final renamed = await edit(marko, stored, [
      withChampion(ChampionDto(id: carry.id, name: 'Lažni', cost: 1)),
      ...rest,
    ]);
    final kept = await edit(marko, stored, stored.variants.first.lineup);

    expect([unknown.statusCode, renamed.statusCode, kept.statusCode], [400, 400, 200]);
    expect(bodyOf(unknown), containsPair('code', ErrorCodes.badRequest));
  });

  test('another creator neither sees nor deletes a draft, and its author deletes it', () async {
    final luka = await logIn('luka');
    final marko = await logIn('marko');
    final draft = base.replace(path: ApiPaths.tactic('t-01'));

    final seen = await http.get(draft, headers: as(luka));
    final deletedByLuka = await http.delete(draft, headers: as(luka));
    final deletedByMarko = await http.delete(draft, headers: as(marko));

    expect([seen.statusCode, deletedByLuka.statusCode, deletedByMarko.statusCode], [404, 404, 204]);
  });
}
