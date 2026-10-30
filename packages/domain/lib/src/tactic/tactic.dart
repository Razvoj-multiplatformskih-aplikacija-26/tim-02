import 'package:equatable/equatable.dart';

import '../catalog.dart';
import '../identifiers.dart';
import 'tactic_status.dart';

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
  });

  final TacticId id;
  final UserId authorId;
  final String authorName;
  final String title;
  final String description;
  final Champion carry;
  final TacticStatus status;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [id, authorId, authorName, title, description, carry, status, updatedAt];
}
