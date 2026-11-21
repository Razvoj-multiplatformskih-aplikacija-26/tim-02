abstract final class ApiPaths {
  static const health = '/health';
  static const catalog = '/api/v1/catalog';
  static const tierList = '/api/v1/tier-list';
  static const tactics = '/api/v1/tactics';
  static const sessions = '/api/v1/sessions';
  static const currentSession = '/api/v1/sessions/current';

  static String tactic(String id) => '$tactics/$id';

  static String publication(String id) => '${tactic(id)}/publication';

  static String hiding(String id) => '${tactic(id)}/hiding';

  static String restoration(String id) => '${tactic(id)}/restoration';

  static String archive(String id) => '${tactic(id)}/archive';

  static String tierPlacement(String tacticId) => '$tierList/$tacticId';
}

abstract final class ApiCookies {
  static const session = 'tft_insights_session';
}
