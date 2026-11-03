import 'package:domain/domain.dart';
import 'package:test/test.dart';

void main() {
  final now = DateTime.utc(2026, 10, 28, 12);
  const marko = User(id: UserId('u-marko'), name: 'Marko', role: Role.creator);
  const luka = User(id: UserId('u-luka'), name: 'Luka', role: Role.creator);
  const ahri = Champion(id: ChampionId('ahri'), name: 'Ahri', cost: 4);

  Tactic tactic(TacticStatus status) => Tactic(
    id: const TacticId('t-1'),
    authorId: marko.id,
    authorName: marko.name,
    title: 't-1',
    description: '',
    carry: ahri,
    status: status,
    updatedAt: now,
  );

  group('canTransition', () {
    test('allows exactly six transitions out of sixteen', () {
      final statuses = <TacticStatus>[
        const Draft(),
        Published(at: now),
        Hidden(
          reason: HideReason.parse('Opis je preuzet bez izvora.').valueOrNull!,
          by: const UserId('u-ana'),
          at: now,
        ),
        Archived(at: now),
      ];
      final allowed = [
        for (final from in statuses)
          for (final to in statuses)
            if (canTransition(from, to)) (from.kind, to.kind),
      ];
      expect(allowed, [
        (TacticStatusKind.draft, TacticStatusKind.published),
        (TacticStatusKind.draft, TacticStatusKind.archived),
        (TacticStatusKind.published, TacticStatusKind.hidden),
        (TacticStatusKind.published, TacticStatusKind.archived),
        (TacticStatusKind.hidden, TacticStatusKind.published),
        (TacticStatusKind.hidden, TacticStatusKind.archived),
      ]);
    });
  });

  group('archiveTactic', () {
    test('archives the author\'s tactic and records when', () {
      final later = now.add(const Duration(hours: 1));
      final published = tactic(Published(at: now));
      final archived = archiveTactic(published, by: marko, now: later);
      expect(archived.valueOrNull?.status, Archived(at: later));
      expect(archived.valueOrNull?.updatedAt, later);
      expect(allowedActions(tactic(const Draft()), marko, now: now), contains(TacticAction.archive));
    });

    test('keeps an archived tactic archived', () {
      final archived = Archived(at: now);
      expect(
        archiveTactic(tactic(archived), by: marko, now: now),
        Failure<Tactic>(InvalidTransition(from: archived, to: archived)),
      );
      expect(allowedActions(tactic(archived), marko, now: now), isEmpty);
    });

    test('refuses a creator who is not the author', () {
      expect(archiveTactic(tactic(const Draft()), by: luka, now: now), const Failure<Tactic>(NotAllowed()));
      expect(allowedActions(tactic(const Draft()), luka, now: now), isEmpty);
    });
  });

  group('publish, hide and restore', () {
    const ana = User(id: UserId('u-ana'), name: 'Ana', role: Role.admin);
    final reason = HideReason.parse('Opis je preuzet bez izvora.').valueOrNull!;
    final hidden = Hidden(reason: reason, by: ana.id, at: now);

    test('keeps the author from publishing a tactic an admin hid', () {
      expect(publishTactic(tactic(hidden), by: marko, now: now), const Failure<Tactic>(HiddenByAdmin()));
      expect(allowedActions(tactic(hidden), marko, now: now), {TacticAction.archive});
    });

    test('lets only an admin hide a published tactic and restore it', () {
      final published = tactic(Published(at: now));
      expect(hideTactic(published, by: marko, reason: reason, now: now), const Failure<Tactic>(NotAllowed()));
      expect(hideTactic(published, by: ana, reason: reason, now: now).valueOrNull?.status, hidden);
      expect(restoreTactic(tactic(hidden), by: ana, now: now).valueOrNull?.status, Published(at: now));
      expect(allowedActions(tactic(hidden), ana, now: now), {TacticAction.restore});
    });

    test('restores only a hidden tactic', () {
      final published = Published(at: now);
      expect(
        restoreTactic(tactic(published), by: ana, now: now),
        Failure<Tactic>(InvalidTransition(from: published, to: published)),
      );
    });
  });
}
