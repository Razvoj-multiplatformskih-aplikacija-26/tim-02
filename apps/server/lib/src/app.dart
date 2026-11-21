import 'package:api_contract/api_contract.dart';
import 'package:relic/relic.dart';

import 'cors.dart';
import 'handlers.dart';
import 'http.dart';
import 'sessions.dart';

Handler buildHandler(TacticHandlers handlers, SessionHandlers sessions, {required List<String> corsOrigins}) {
  final signedIn = sessions.signedIn;
  final optionallySignedIn = sessions.optionallySignedIn;
  final router = RelicRouter()
    ..get(ApiPaths.health, (request) => Response.ok(body: Body.fromString('ok')))
    ..get(ApiPaths.catalog, handlers.catalog)
    ..get(ApiPaths.tierList, handlers.tierList)
    ..get(ApiPaths.tactics, optionallySignedIn(handlers.list))
    ..get(ApiPaths.tactic(':id'), optionallySignedIn(handlers.find))
    ..post(ApiPaths.sessions, sessions.logIn)
    ..get(ApiPaths.currentSession, signedIn(sessions.current))
    ..delete(ApiPaths.currentSession, signedIn(sessions.logOut))
    ..post(ApiPaths.tactics, signedIn(handlers.create))
    ..put(ApiPaths.tactic(':id'), signedIn(handlers.edit))
    ..delete(ApiPaths.tactic(':id'), signedIn(handlers.delete))
    ..post(ApiPaths.publication(':id'), signedIn(handlers.publish))
    ..post(ApiPaths.hiding(':id'), signedIn(handlers.hide))
    ..post(ApiPaths.restoration(':id'), signedIn(handlers.restore))
    ..post(ApiPaths.archive(':id'), signedIn(handlers.archive))
    ..put(ApiPaths.tierPlacement(':id'), signedIn(handlers.place))
    ..fallback = respondWith((request) => problemResponse(notFoundRoute));
  return const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(allowOrigins(corsOrigins))
      .addMiddleware(handleErrors())
      .addHandler(router.asHandler);
}

const notFoundRoute = ProblemDto(status: 404, code: ErrorCodes.notFound, title: 'No such route');
