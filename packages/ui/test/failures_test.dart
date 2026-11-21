import 'package:flutter_test/flutter_test.dart';
import 'package:ui/ui.dart';
import 'package:use_cases/use_cases.dart';

void main() {
  test('tells an unreachable server from a refused call and from a server error', () {
    String message(RepositoryFailure failure) => failureMessage(RepositoryException('test', failure: failure));

    expect(message(RepositoryFailure.unreachable), 'Nema veze sa serverom.');
    expect(message(RepositoryFailure.refused), 'Server nije prihvatio zahtev.');
    expect(message(RepositoryFailure.serverError), 'Greška na serveru.');
    expect(message(RepositoryFailure.unavailable), 'Podaci trenutno nisu dostupni.');
  });
}
