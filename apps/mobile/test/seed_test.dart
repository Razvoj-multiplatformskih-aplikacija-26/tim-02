import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/seed.dart';

void main() {
  test('gives every seeded tactic a variant with an early and a final board', () {
    for (final tactic in seedTactics(DateTime.utc(2026, 11, 3))) {
      expect(tactic.variants, isNotEmpty, reason: tactic.title);
      for (final variant in tactic.variants) {
        expect(variant.early.placements, isNotEmpty, reason: variant.name);
        expect(variant.lineup.placements, isNotEmpty, reason: variant.name);
      }
    }
  });
}
