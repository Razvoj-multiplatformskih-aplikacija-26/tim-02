import 'package:domain/domain.dart';
import 'package:test/test.dart';
import 'package:use_cases/use_cases.dart';

const marko = User(id: UserId('u-marko'), name: 'Marko', role: Role.creator);
const ahri = Champion(id: ChampionId('DA_18_Ahri'), name: 'Ahri', cost: 4);
final now = DateTime.utc(2026, 11, 21, 1);

Tactic tactic(TacticStatus status) => Tactic(
  id: const TacticId('t-1'),
  authorId: marko.id,
  authorName: marko.name,
  title: 'Ahri na nivou 8',
  description: '',
  carry: ahri,
  status: status,
  updatedAt: now,
);

final class ChangedMeanwhile implements TacticRepository {
  ChangedMeanwhile({required this.seen, required this.stored});

  final Tactic seen;
  Tactic stored;

  @override
  Future<Tactic?> find(TacticId id) async => seen;

  @override
  Future<Result<Tactic>> save(Tactic tactic, {required TacticStatus from}) async {
    if (stored.status != from) return Failure(InvalidTransition(from: stored.status, to: tactic.status));
    return Success(stored = tactic);
  }

  @override
  Future<List<Tactic>> all() => throw UnimplementedError();

  @override
  Future<TierList> currentTierList() => throw UnimplementedError();

  @override
  Future<Result<Tactic>> create(Tactic draft) => throw UnimplementedError();

  @override
  Future<Result<TacticId>> delete(TacticId id) => throw UnimplementedError();

  @override
  Future<Result<TierList>> place(Tactic tactic, Tier? tier, {required User by}) => throw UnimplementedError();
}

void main() {
  final published = Published(at: now.subtract(const Duration(days: 2)));
  final hidden = Hidden(
    reason: HideReason.parse('Zastarela postava.').valueOrNull!,
    by: const UserId('u-ana'),
    at: now.subtract(const Duration(minutes: 1)),
  );

  test('saves a change from the status it was made on', () async {
    final tactics = ChangedMeanwhile(seen: tactic(published), stored: tactic(published));

    final result = await ChangeTacticStatus(tactics: tactics, clock: FixedClock(now))(
      id: const TacticId('t-1'),
      action: TacticAction.archive,
      by: marko,
    );

    expect(result.valueOrNull?.status, Archived(at: now));
    expect(tactics.stored.status, Archived(at: now));
  });

  test('refuses a change when someone changed the status in the meantime', () async {
    final tactics = ChangedMeanwhile(seen: tactic(published), stored: tactic(hidden));

    final result = await ChangeTacticStatus(tactics: tactics, clock: FixedClock(now))(
      id: const TacticId('t-1'),
      action: TacticAction.archive,
      by: marko,
    );

    final refused = InvalidTransition(
      from: hidden,
      to: Archived(at: now),
    );
    expect(result, Failure<Tactic>(refused));
    expect(tactics.stored.status, hidden);
  });
}
