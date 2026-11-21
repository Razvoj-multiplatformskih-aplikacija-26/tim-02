abstract final class ApiPaths {
  static const health = '/health';
  static const catalog = '/api/v1/catalog';
  static const tierList = '/api/v1/tier-list';
  static const tactics = '/api/v1/tactics';
  static const sessions = '/api/v1/sessions';
  static const currentSession = '/api/v1/sessions/current';

  static String tactic(String id) => '$tactics/$id';
}

abstract final class ApiCookies {
  static const session = 'tft_insights_session';
}
