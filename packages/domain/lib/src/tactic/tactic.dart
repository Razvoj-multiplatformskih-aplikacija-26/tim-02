import 'package:equatable/equatable.dart';

import '../catalog.dart';
import '../errors.dart';
import '../identifiers.dart';
import '../result.dart';
import 'tactic_status.dart';
import 'tactic_variant.dart';

final class Tactic extends Equatable {
  const Tactic({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.description,
    required this.carry,
    required this.status,
    required this.updatedAt,
    this.variants = const [],
  });

  static const maxTitleLength = 60;

  final TacticId id;
  final UserId authorId;
  final String authorName;
  final String title;
  final String description;
  final Champion carry;
  final TacticStatus status;
  final DateTime updatedAt;
  final List<TacticVariant> variants;

  static Result<String> parseTitle(String input) {
    final title = input.trim();
    if (title.isEmpty || title.length > maxTitleLength) return Failure(InvalidTacticTitle(title.length));
    return Success(title);
  }

  @override
  List<Object?> get props => [id, authorId, authorName, title, description, carry, status, updatedAt, variants];

  Tactic copyWith({
    String? title,
    String? description,
    TacticStatus? status,
    DateTime? updatedAt,
    List<TacticVariant>? variants,
  }) => Tactic(
    id: id,
    authorId: authorId,
    authorName: authorName,
    title: title ?? this.title,
    description: description ?? this.description,
    carry: carry,
    status: status ?? this.status,
    updatedAt: updatedAt ?? this.updatedAt,
    variants: variants ?? this.variants,
  );
}
