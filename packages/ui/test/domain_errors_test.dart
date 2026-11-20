import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui/ui.dart';

void main() {
  test('builds each rule message from the limit the error carries', () {
    expect(const TooManyItems(3, max: 2).message, 'Šampion može nositi najviše 2 predmeta.');
    expect(const HideReasonTooShort(4, min: 15).message, 'Obrazloženje mora imati bar 15 znakova.');
    expect(const InvalidTacticTitle(81, max: 80).message, 'Naslov mora imati od 1 do 80 znakova.');
  });
}
