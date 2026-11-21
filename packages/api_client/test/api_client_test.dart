import 'dart:convert';

import 'package:api_client/api_client.dart';
import 'package:api_contract/api_contract.dart';
import 'package:api_mapping/api_mapping.dart';
import 'package:domain/domain.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:use_cases/use_cases.dart';

const ana = User(id: UserId('u-ana'), name: 'Ana', role: Role.admin);
const ahri = Champion(id: ChampionId('DA_18_Ahri'), name: 'Ahri', cost: 4);

final published = Tactic(
  id: const TacticId('t-05'),
  authorId: const UserId('u-marko'),
  authorName: 'Marko',
  title: 'Elderwood Ezreal',
  description: '',
  carry: ahri,
  status: Published(at: DateTime.utc(2026, 11, 20)),
  updatedAt: DateTime.utc(2026, 11, 20),
);

ApiClient apiOver(MockClient server, {TokenStore? tokens}) => ApiClient(
  baseUri: Uri.parse('http://localhost:8080'),
  tokens: tokens,
  httpClient: server,
  keepsSessionInCookie: false,
);

http.Response problem(ProblemDto problem) =>
    http.Response(jsonEncode(problem.toJson()), problem.status, headers: {'content-type': ProblemDto.mediaType});

void main() {
  test('the server filling tier S first reaches the client as TierFull, sent with the token', () async {
    final tokens = MemoryTokenStore();
    await tokens.write('token-of-ana');
    final server = MockClient((request) async {
      expect(request.method, 'PUT');
      expect(request.url.path, ApiPaths.tierPlacement('t-05'));
      expect(request.headers['Authorization'], 'Bearer token-of-ana');
      expect(jsonDecode(request.body), {'tier': 's'});
      return problem(const ProblemDto(status: 409, code: ErrorCodes.tierFull, title: 'Tier full', tier: 's', max: 2));
    });

    final result = await HttpTacticRepository(apiOver(server, tokens: tokens)).place(published, Tier.s, by: ana);

    expect(result, const Failure<TierList>(TierFull(Tier.s, max: 2)));
  });

  test('a change of status goes to the call for that change, and an edit to the tactic itself', () async {
    final calls = <String>[];
    final server = MockClient((request) async {
      calls.add('${request.method} ${request.url.path}');
      return http.Response(jsonEncode(published.toDto().toJson()), 200, headers: {'content-type': 'application/json'});
    });
    final tactics = HttpTacticRepository(apiOver(server));
    final hidden = Hidden(
      reason: HideReason.parse('Zastarela postava.').valueOrNull!,
      by: ana.id,
      at: DateTime.utc(2026, 11, 21),
    );

    await tactics.save(published.copyWith(status: hidden), from: published.status);
    await tactics.save(published, from: hidden);
    await tactics.save(published.copyWith(title: 'Ezreal 8'), from: published.status);

    expect(calls, [
      'POST ${ApiPaths.hiding('t-05')}',
      'POST ${ApiPaths.restoration('t-05')}',
      'PUT ${ApiPaths.tactic('t-05')}',
    ]);
  });

  test('a server that cannot be reached becomes a RepositoryException the screens can explain', () async {
    final server = MockClient((request) async => throw http.ClientException('Connection refused', request.url));

    expect(
      HttpTacticRepository(apiOver(server)).all(),
      throwsA(isA<RepositoryException>().having((e) => e.failure, 'failure', RepositoryFailure.unreachable)),
    );
  });

  test('a code the client does not know is a refused call, not a crash', () async {
    final server = MockClient(
      (request) async => problem(const ProblemDto(status: 409, code: 'patch-closed', title: 'Patch closed')),
    );

    expect(
      HttpTacticRepository(apiOver(server)).place(published, Tier.a, by: ana),
      throwsA(isA<RepositoryException>().having((e) => e.failure, 'failure', RepositoryFailure.refused)),
    );
  });

  test('an expired session is announced so the app can ask for a new login', () async {
    final server = MockClient(
      (request) async =>
          problem(const ProblemDto(status: 401, code: ErrorCodes.sessionExpired, title: 'Session expired')),
    );
    final api = apiOver(server);
    final expired = expectLater(api.expirations, emits(null));

    await expectLater(
      HttpTacticRepository(api).all(),
      throwsA(isA<RepositoryException>().having((e) => e.failure, 'failure', RepositoryFailure.sessionExpired)),
    );
    await expired;
  });

  test('a wrong password is no session, and a good one keeps the token for the next calls', () async {
    final tokens = MemoryTokenStore();
    final server = MockClient((request) async {
      final login = LoginDto.fromJson(jsonDecode(request.body) as Map<String, Object?>);
      if (login.password != 'tft-demo') {
        return problem(
          const ProblemDto(status: 401, code: ErrorCodes.invalidCredentials, title: 'Invalid credentials'),
        );
      }
      final session = SessionDto(
        user: const UserDto(id: 'u-ana', name: 'Ana', role: 'admin'),
        expiresAt: DateTime.utc(2026, 11, 21, 20),
        token: 'token-of-ana',
      );
      return http.Response(jsonEncode(session.toJson()), 201, headers: {'content-type': 'application/json'});
    });
    final sessions = HttpSessionRepository(apiOver(server, tokens: tokens));

    expect(await sessions.logIn(username: 'ana', password: 'pogresna'), isNull);
    expect(await sessions.logIn(username: 'ana', password: 'tft-demo'), ana);
    expect(await tokens.read(), 'token-of-ana');
  });
}
