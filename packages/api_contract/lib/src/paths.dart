abstract final class ApiPaths {
  static const health = '/health';
  static const catalog = '/api/v1/catalog';
  static const tierList = '/api/v1/tier-list';
  static const tactics = '/api/v1/tactics';

  static String tactic(String id) => '$tactics/$id';
}
