import 'package:domain/domain.dart';
import 'package:test/test.dart';

void main() {
  group('LineupName', () {
    test('accepts a name of exactly 40 characters', () {
      expect(LineupName.parse('š' * 40).valueOrNull?.text, 'š' * 40);
    });

    test('rejects a blank name', () {
      expect(LineupName.parse('   '), const Failure<LineupName>(InvalidLineupName(0)));
    });

    test('rejects a name of 41 characters', () {
      expect(LineupName.parse('š' * 41), const Failure<LineupName>(InvalidLineupName(41)));
    });
  });
}
