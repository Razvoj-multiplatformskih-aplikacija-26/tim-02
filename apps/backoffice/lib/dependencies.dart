import 'package:api_client/api_client.dart';
import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'data/fake_sessions.dart';
import 'data/fake_tactics.dart';

final class BackofficeDependencies {
  BackofficeDependencies({
    required this.clock,
    required TacticRepository tactics,
    required CatalogRepository catalog,
    required SessionRepository sessions,
    this.fakeTactics,
    this.fakeSessions,
  }) : getTactics = GetTactics(tactics: tactics),
       getTierList = GetTierList(tactics: tactics),
       changeTacticStatus = ChangeTacticStatus(tactics: tactics, clock: clock),
       placeTactic = PlaceTactic(tactics: tactics),
       editTactic = EditTactic(tactics: tactics, clock: clock),
       getCatalog = GetCatalog(catalog: catalog),
       logIn = LogIn(sessions: sessions),
       restoreSession = RestoreSession(sessions: sessions),
       logOut = LogOut(sessions: sessions),
       sessionExpirations = sessions.expirations;

  factory BackofficeDependencies.server({
    required Uri baseUri,
    required TokenStore tokens,
    Clock clock = const SystemClock(),
  }) {
    final api = ApiClient(baseUri: baseUri, tokens: tokens);
    return BackofficeDependencies(
      clock: clock,
      tactics: HttpTacticRepository(api),
      catalog: HttpCatalogRepository(api),
      sessions: HttpSessionRepository(api),
    );
  }

  factory BackofficeDependencies.fake({
    Clock clock = const SystemClock(),
    Duration? latency,
    User user = ana,
    bool signedIn = true,
  }) {
    final tactics = latency == null ? FakeTactics(clock: clock) : FakeTactics(clock: clock, latency: latency);
    final sessions = FakeSessions(user, signedIn: signedIn);
    return BackofficeDependencies(
      clock: clock,
      tactics: tactics,
      catalog: tactics,
      sessions: sessions,
      fakeTactics: tactics,
      fakeSessions: sessions,
    );
  }

  static const ana = User(id: UserId('u-ana'), name: 'Ana', role: Role.admin);

  final Clock clock;
  final GetTactics getTactics;
  final GetTierList getTierList;
  final ChangeTacticStatus changeTacticStatus;
  final PlaceTactic placeTactic;
  final EditTactic editTactic;
  final GetCatalog getCatalog;
  final LogIn logIn;
  final RestoreSession restoreSession;
  final LogOut logOut;
  final Stream<void> sessionExpirations;
  final FakeTactics? fakeTactics;
  final FakeSessions? fakeSessions;
}
