import 'package:domain/domain.dart';

bool isStale(DomainError error) =>
    error is InvalidTransition || error is TacticArchived || error is NotAllowed || error is NotFound;
