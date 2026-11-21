import 'dart:convert';

import 'package:api_contract/api_contract.dart';
import 'package:api_mapping/api_mapping.dart';
import 'package:domain/domain.dart';
import 'package:postgres/postgres.dart';

const _select = '''
  SELECT t.id, t.author_id, u.name, t.title, t.description, c.id, c.name, c.cost,
         t.status, t.status_at, t.hidden_reason, t.hidden_by, t.updated_at, t.variants
  FROM tactics t
  JOIN users u ON u.id = t.author_id
  JOIN champions c ON c.id = t.carry_id
''';

final class TacticStore {
  const TacticStore(this._database);

  final Session _database;

  Future<bool> isEmpty() async {
    final rows = await _database.execute('SELECT count(*) FROM users');
    return rows.single[0] == 0;
  }

  Future<Catalog> catalog() async {
    final champions = await _database.execute('SELECT id, name, cost FROM champions ORDER BY name');
    final items = await _database.execute('SELECT id, name FROM items ORDER BY name');
    return Catalog(
      champions: [
        for (final [id, name, cost] in champions)
          Champion(id: ChampionId(id! as String), name: name! as String, cost: cost! as int),
      ],
      items: [for (final [id, name] in items) Item(id: ItemId(id! as String), name: name! as String)],
    );
  }

  Future<List<Tactic>> tactics() async {
    final rows = await _database.execute('$_select ORDER BY t.updated_at DESC');
    return [for (final row in rows) _tactic(row)];
  }

  Future<Tactic?> tactic(TacticId id) async {
    final rows = await _database.execute(Sql.named('$_select WHERE t.id = @id'), parameters: {'id': id.value});
    return rows.isEmpty ? null : _tactic(rows.single);
  }

  Future<TacticId> insert(Tactic tactic, {bool newId = false}) async {
    final rows = await _database.execute(
      Sql.named('''
        INSERT INTO tactics
          (id, author_id, title, description, carry_id, status, status_at, hidden_reason, hidden_by, updated_at, variants)
        VALUES
          (COALESCE(@id::text, 't-' || gen_random_uuid()), @author, @title, @description, @carry, @status, @statusAt,
           @reason, @hiddenBy, @updatedAt, @variants::jsonb)
        RETURNING id
      '''),
      parameters: {
        ..._columns(tactic),
        'id': newId ? null : tactic.id.value,
        'author': tactic.authorId.value,
        'carry': tactic.carry.id.value,
      },
    );
    return TacticId(rows.single[0]! as String);
  }

  Future<bool> update(Tactic tactic, {required TacticStatus from}) async {
    final result = await _database.execute(
      Sql.named('''
        UPDATE tactics
        SET title = @title, description = @description, status = @status, status_at = @statusAt,
            hidden_reason = @reason, hidden_by = @hiddenBy, updated_at = @updatedAt, variants = @variants::jsonb
        WHERE id = @id AND status = @from
      '''),
      parameters: {..._columns(tactic), 'id': tactic.id.value, 'from': from.toDto().kind},
    );
    return result.affectedRows == 1;
  }

  Future<bool> deleteDraft(TacticId id) async {
    final result = await _database.execute(
      Sql.named("DELETE FROM tactics WHERE id = @id AND status = 'draft'"),
      parameters: {'id': id.value},
    );
    return result.affectedRows == 1;
  }

  Future<TierList> tierList({bool locked = false}) async {
    final current = await _database.execute('SELECT id FROM patches WHERE is_current${locked ? ' FOR UPDATE' : ''}');
    final patch = current.single[0]! as String;
    final rows = await _database.execute(
      Sql.named('SELECT tactic_id, tier FROM tier_placements WHERE patch_id = @patch ORDER BY position'),
      parameters: {'patch': patch},
    );
    return TierListDto(
      patch: patch,
      placements: [
        for (final [tactic, tier] in rows) TierPlacementDto(tacticId: tactic! as String, tier: tier! as String),
      ],
    ).toDomain();
  }

  Future<void> replacePlacements(TierList tierList) async {
    await _database.execute(
      Sql.named('DELETE FROM tier_placements WHERE patch_id = @patch'),
      parameters: {'patch': tierList.patch.value},
    );
    for (final (position, placement) in tierList.toDto().placements.indexed) {
      await _database.execute(
        Sql.named(
          'INSERT INTO tier_placements (patch_id, tactic_id, tier, position) VALUES (@patch, @tactic, @tier, @position)',
        ),
        parameters: {
          'patch': tierList.patch.value,
          'tactic': placement.tacticId,
          'tier': placement.tier,
          'position': position,
        },
      );
    }
  }
}

Map<String, Object?> _columns(Tactic tactic) {
  final dto = tactic.toDto();
  return {
    'title': dto.title,
    'description': dto.description,
    'status': dto.status.kind,
    'statusAt': dto.status.at,
    'reason': dto.status.reason,
    'hiddenBy': dto.status.by,
    'updatedAt': dto.updatedAt,
    'variants': jsonEncode([for (final variant in dto.variants) variant.toJson()]),
  };
}

Tactic _tactic(ResultRow row) {
  final [
    id,
    authorId,
    authorName,
    title,
    description,
    carryId,
    carryName,
    carryCost,
    status,
    statusAt,
    reason,
    hiddenBy,
    updatedAt,
    variants,
  ] = row;
  return TacticDto(
    id: id! as String,
    authorId: authorId! as String,
    authorName: authorName! as String,
    title: title! as String,
    description: description! as String,
    carry: ChampionDto(id: carryId! as String, name: carryName! as String, cost: carryCost! as int),
    status: TacticStatusDto(
      kind: status! as String,
      at: statusAt as DateTime?,
      reason: reason as String?,
      by: hiddenBy as String?,
    ),
    updatedAt: updatedAt! as DateTime,
    variants: [
      for (final variant in variants! as List<Object?>) TacticVariantDto.fromJson(variant! as Map<String, Object?>),
    ],
  ).toDomain();
}
