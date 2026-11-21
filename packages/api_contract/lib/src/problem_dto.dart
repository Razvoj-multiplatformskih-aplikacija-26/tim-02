import 'json.dart';
import 'tactic_dto.dart';

final class ProblemDto {
  const ProblemDto({
    required this.status,
    required this.code,
    required this.title,
    this.value,
    this.min,
    this.max,
    this.row,
    this.column,
    this.tier,
    this.from,
    this.to,
  });

  static const mediaType = 'application/problem+json';

  static String typeOf(String code) => 'tag:raf.rs,2026:tft-insights/problem/$code';

  final int status;
  final String code;
  final String title;
  final int? value;
  final int? min;
  final int? max;
  final int? row;
  final int? column;
  final String? tier;
  final TacticStatusDto? from;
  final TacticStatusDto? to;

  Map<String, Object?> toJson() => {
    'type': typeOf(code),
    'title': title,
    'status': status,
    'code': code,
    'value': ?value,
    'min': ?min,
    'max': ?max,
    'row': ?row,
    'column': ?column,
    'tier': ?tier,
    if (from case final from?) 'from': from.toJson(),
    if (to case final to?) 'to': to.toJson(),
  };

  factory ProblemDto.fromJson(Map<String, Object?> json) => ProblemDto(
    status: jsonInt(json, 'status'),
    code: jsonString(json, 'code'),
    title: jsonOptionalString(json, 'title') ?? '',
    value: jsonOptionalInt(json, 'value'),
    min: jsonOptionalInt(json, 'min'),
    max: jsonOptionalInt(json, 'max'),
    row: jsonOptionalInt(json, 'row'),
    column: jsonOptionalInt(json, 'column'),
    tier: jsonOptionalString(json, 'tier'),
    from: json['from'] == null ? null : TacticStatusDto.fromJson(jsonObject(json['from'])),
    to: json['to'] == null ? null : TacticStatusDto.fromJson(jsonObject(json['to'])),
  );
}
