import 'package:equatable/equatable.dart';

import '../errors.dart';
import '../result.dart';

final class HideReason extends Equatable {
  const HideReason._(this.text);

  static const minLength = 10;

  final String text;

  static Result<HideReason> parse(String input) {
    final text = input.trim();
    if (text.length < minLength) return Failure(HideReasonTooShort(text.length));
    return Success(HideReason._(text));
  }

  @override
  List<Object?> get props => [text];
}
