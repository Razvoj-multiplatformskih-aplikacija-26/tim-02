import 'package:domain/domain.dart';
import 'package:test/test.dart';

void main() {
  group('HideReason', () {
    test('accepts a reason of exactly 10 characters', () {
      expect(HideReason.parse('č' * 10).valueOrNull?.text, 'č' * 10);
    });

    test('rejects a reason of 9 characters', () {
      expect(HideReason.parse('č' * 9), const Failure<HideReason>(HideReasonTooShort(9)));
    });

    test('ignores spaces around the reason', () {
      expect(HideReason.parse('  kratko  '), const Failure<HideReason>(HideReasonTooShort(6)));
    });
  });
}
