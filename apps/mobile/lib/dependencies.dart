import 'package:api_client/api_client.dart';
import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'data/fake_sessions.dart';
import 'data/fake_tactics.dart';

final class AppDependencies {
  AppDependencies({
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
       getCatalog = GetCatalog(catalog: catalog),
       saveDraft = SaveDraft(tactics: tactics, clock: clock),
       deleteDraft = DeleteDraft(tactics: tactics),
       logIn = LogIn(sessions: sessions),
       restoreSession = RestoreSession(sessions: sessions),
       logOut = LogOut(sessions: sessions),
       sessionExpirations = sessions.expirations;

  factory AppDependencies.server({
    required Uri baseUri,
    required TokenStore tokens,
    Clock clock = const SystemClock(),
  }) {
    final api = ApiClient(baseUri: baseUri, tokens: tokens);
    return AppDependencies(
      clock: clock,
      tactics: HttpTacticRepository(api),
      catalog: HttpCatalogRepository(api),
      sessions: HttpSessionRepository(api),
    );
  }

  factory AppDependencies.fake({Clock clock = const SystemClock(), Duration? latency, bool signedIn = true}) {
    final tactics = latency == null ? FakeTactics(clock: clock) : FakeTactics(clock: clock, latency: latency);
    final sessions = FakeSessions(marko, signedIn: signedIn);
    return AppDependencies(
      clock: clock,
      tactics: tactics,
      catalog: tactics,
      sessions: sessions,
      fakeTactics: tactics,
      fakeSessions: sessions,
    );
  }

  static const marko = User(id: UserId('u-marko'), name: 'Marko', role: Role.creator);

  final Clock clock;
  final GetTactics getTactics;
  final GetTierList getTierList;
  final ChangeTacticStatus changeTacticStatus;
  final PlaceTactic placeTactic;
  final GetCatalog getCatalog;
  final SaveDraft saveDraft;
  final DeleteDraft deleteDraft;
  final LogIn logIn;
  final RestoreSession restoreSession;
  final LogOut logOut;
  final Stream<void> sessionExpirations;
  final FakeTactics? fakeTactics;
  final FakeSessions? fakeSessions;
}
