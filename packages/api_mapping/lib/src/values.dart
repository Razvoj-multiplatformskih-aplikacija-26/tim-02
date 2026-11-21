import 'package:domain/domain.dart';

T accepted<T>(Result<T> result) => switch (result) {
  Success(:final value) => value,
  Failure(:final error) => throw FormatException('The contract carried a value the domain rejects', error),
};

T byName<T extends Enum>(List<T> values, String name) =>
    values.where((value) => value.name == name).firstOrNull ?? (throw FormatException('Unknown value', name));
