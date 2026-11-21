import 'package:domain/domain.dart';
import 'package:test/test.dart';

void main() {
  const player = User(id: UserId('u-petar'), name: 'Petar', role: Role.user);
  const creator = User(id: UserId('u-marko'), name: 'Marko', role: Role.creator);
  const admin = User(id: UserId('u-ana'), name: 'Ana', role: Role.admin);

  test('players and creators use the phone; creators and admins use the backoffice', () {
    expect([player, creator, admin].map(AccessPolicy.canUseMobile), [true, true, false]);
    expect([player, creator, admin].map(AccessPolicy.canUseBackoffice), [false, true, true]);
  });
}
