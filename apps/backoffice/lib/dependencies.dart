import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'data/fake_tactics.dart';

final class BackofficeDependencies {
  BackofficeDependencies({
    required this.clock,
    required this.user,
    required TacticRepository tactics,
    required CatalogRepository catalog,
    this.fakeTactics,
  }) : getTactics = GetTactics(tactics: tactics),
       getTierList = GetTierList(tactics: tactics),
       changeTacticStatus = ChangeTacticStatus(tactics: tactics, clock: clock),
       placeTactic = PlaceTactic(tactics: tactics),
       editTactic = EditTactic(tactics: tactics, clock: clock),
       getCatalog = GetCatalog(catalog: catalog);

  factory BackofficeDependencies.fake({Clock clock = const SystemClock(), Duration? latency}) {
    final tactics = latency == null ? FakeTactics(clock: clock) : FakeTactics(clock: clock, latency: latency);
    return BackofficeDependencies(
      clock: clock,
      user: const User(id: UserId('u-ana'), name: 'Ana', role: Role.admin),
      tactics: tactics,
      catalog: tactics,
      fakeTactics: tactics,
    );
  }

  final Clock clock;
  final User user;
  final GetTactics getTactics;
  final GetTierList getTierList;
  final ChangeTacticStatus changeTacticStatus;
  final PlaceTactic placeTactic;
  final EditTactic editTactic;
  final GetCatalog getCatalog;
  final FakeTactics? fakeTactics;
}
