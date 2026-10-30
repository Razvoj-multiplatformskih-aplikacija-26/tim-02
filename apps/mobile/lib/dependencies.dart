import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'data/fake_tactics.dart';

final class AppDependencies {
  AppDependencies({required this.user, required TacticRepository tactics})
    : getTactics = GetTactics(tactics: tactics),
      getTierList = GetTierList(tactics: tactics);

  factory AppDependencies.fake({Clock clock = const SystemClock(), Duration? latency}) {
    final tactics = latency == null ? FakeTactics(clock: clock) : FakeTactics(clock: clock, latency: latency);
    return AppDependencies(
      user: const User(id: UserId('u-marko'), name: 'Marko', role: Role.creator),
      tactics: tactics,
    );
  }

  final User user;
  final GetTactics getTactics;
  final GetTierList getTierList;
}
