import 'package:demo_data/demo_data.dart';
import 'package:postgres/postgres.dart';

import 'tactic_store.dart';

Future<void> seedDemoData(Pool<void> database, {required DateTime now}) async {
  if (!await TacticStore(database).isEmpty()) return;
  await database.runTx((session) async {
    for (final user in seedUsers) {
      await session.execute(
        Sql.named('INSERT INTO users (id, name, role) VALUES (@id, @name, @role)'),
        parameters: {'id': user.id.value, 'name': user.name, 'role': user.role.name},
      );
    }
    for (final champion in seedCatalog.champions) {
      await session.execute(
        Sql.named('INSERT INTO champions (id, name, cost) VALUES (@id, @name, @cost)'),
        parameters: {'id': champion.id.value, 'name': champion.name, 'cost': champion.cost},
      );
    }
    for (final item in seedCatalog.items) {
      await session.execute(
        Sql.named('INSERT INTO items (id, name) VALUES (@id, @name)'),
        parameters: {'id': item.id.value, 'name': item.name},
      );
    }
    await session.execute(
      Sql.named('INSERT INTO patches (id, is_current) VALUES (@id, true)'),
      parameters: {'id': seedTierList.patch.value},
    );
    final store = TacticStore(session);
    for (final tactic in seedTactics(now)) {
      await store.insert(tactic);
    }
    await store.replacePlacements(seedTierList);
  });
}
