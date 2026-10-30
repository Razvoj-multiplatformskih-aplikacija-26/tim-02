import 'package:domain/domain.dart';
import 'package:test/test.dart';

void main() {
  final now = DateTime.utc(2026, 10, 28, 12);
  const marko = User(id: UserId('u-marko'), name: 'Marko', role: Role.creator);
  const luka = User(id: UserId('u-luka'), name: 'Luka', role: Role.creator);
  const ana = User(id: UserId('u-ana'), name: 'Ana', role: Role.admin);
  const visitor = User(id: UserId('u-visitor'), name: 'Posetilac', role: Role.user);
  const ahri = Champion(id: ChampionId('ahri'), name: 'Ahri', cost: 4);

  Tactic tactic(String id, User author, TacticStatus status, {int daysAgo = 0}) => Tactic(
    id: TacticId(id),
    authorId: author.id,
    authorName: author.name,
    title: id,
    description: '',
    carry: ahri,
    status: status,
    updatedAt: now.subtract(Duration(days: daysAgo)),
  );

  final tactics = [
    tactic('t-1', marko, const Draft()),
    tactic('t-2', marko, Published(at: now), daysAgo: 2),
    tactic('t-3', luka, Published(at: now), daysAgo: 1),
    tactic('t-4', luka, Archived(at: now), daysAgo: 3),
  ];

  List<String> ids(List<Tactic> tactics) => [for (final t in tactics) t.id.value];

  group('visibleTactics', () {
    test('shows a user only published tactics', () {
      expect(ids(visibleTactics(tactics, visitor)), ['t-3', 't-2']);
    });

    test('shows an author every own tactic and the published tactics of others', () {
      expect(ids(visibleTactics(tactics, marko)), ['t-1', 't-3', 't-2']);
    });

    test('shows an admin every tactic, newest first', () {
      expect(ids(visibleTactics(tactics, ana)), ['t-1', 't-3', 't-2', 't-4']);
    });
  });
}
