import 'package:demo_data/demo_data.dart';
import 'package:domain/domain.dart';
import 'package:postgres/postgres.dart' show Pool, Sql;

import 'passwords.dart';
import 'tactic_store.dart';

const _players = [
  User(id: UserId('u-petar'), name: 'Petar', role: Role.user),
  User(id: UserId('u-mina'), name: 'Mina', role: Role.user),
  User(id: UserId('u-ivana'), name: 'Ivana', role: Role.admin),
];

const _logins = {
  'u-petar': 'korisnik1',
  'u-mina': 'korisnik2',
  'u-marko': 'marko',
  'u-tft-insights': 'tftinsights',
  'u-luka': 'luka',
  'u-jovana': 'jovana',
  'u-ana': 'ana',
  'u-ivana': 'admin2',
};

Future<void> seedDemoData(Pool<void> database, {required DateTime now, required String? demoPassword}) async {
  if (!await TacticStore(database).isEmpty()) return;
  if (demoPassword == null) throw StateError('DEMO_PASSWORD is not set. Copy .env.example to .env.');
  await database.runTx((session) async {
    for (final user in [...seedUsers, ..._players]) {
      final login = _logins[user.id.value];
      await session.execute(
        Sql.named('INSERT INTO users (id, name, role, login, password_hash) VALUES (@id, @name, @role, @login, @hash)'),
        parameters: {
          'id': user.id.value,
          'name': user.name,
          'role': user.role.name,
          'login': login,
          'hash': login == null ? null : await hashPassword(demoPassword),
        },
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
