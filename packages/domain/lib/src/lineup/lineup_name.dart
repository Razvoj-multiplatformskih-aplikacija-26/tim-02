import 'package:equatable/equatable.dart';

import '../errors.dart';
import '../result.dart';

final class LineupName extends Equatable {
  const LineupName._(this.text);

  static const maxLength = 40;

  final String text;

  static Result<LineupName> parse(String input) {
    final text = input.trim();
    if (text.isEmpty || text.length > maxLength) return Failure(InvalidLineupName(text.length));
    return Success(LineupName._(text));
  }

  @override
  List<Object?> get props => [text];
}
