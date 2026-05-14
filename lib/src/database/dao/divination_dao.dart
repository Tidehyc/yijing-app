import 'package:sqflite/sqflite.dart';

class DivinationDao {
  final Database db;

  DivinationDao(this.db);

  Future<int> insertRecord(Map<String, dynamic> record) async {
    return db.insert('divination_records', record);
  }

  Future<void> updateNotes(int id, String notes) async {
    await db.update(
      'divination_records',
      {'notes': notes},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateQuestion(int id, String question) async {
    await db.update(
      'divination_records',
      {'question': question},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> softDelete(int id) async {
    await db.update(
      'divination_records',
      {'is_deleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> permanentDelete(int id) async {
    await db.delete('divination_records', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>?> getRecordById(int id) async {
    final results = await db.query(
      'divination_records',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<List<Map<String, dynamic>>> getRecords({
    int limit = 20,
    int offset = 0,
    String? filter, // 'today', 'week', 'month', null = all
  }) async {
    String? whereClause;
    List<dynamic>? whereArgs;

    if (filter == 'today') {
      whereClause = "date(created_at) = date('now') AND is_deleted = 0";
    } else if (filter == 'week') {
      whereClause = "created_at >= date('now', '-7 days') AND is_deleted = 0";
    } else if (filter == 'month') {
      whereClause = "created_at >= date('now', '-30 days') AND is_deleted = 0";
    } else {
      whereClause = 'is_deleted = 0';
    }

    return db.query(
      'divination_records',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );
  }

  Future<int> getRecordCount({String? filter}) async {
    String? whereClause;

    if (filter == 'today') {
      whereClause = "date(created_at) = date('now') AND is_deleted = 0";
    } else if (filter == 'week') {
      whereClause = "created_at >= date('now', '-7 days') AND is_deleted = 0";
    } else if (filter == 'month') {
      whereClause = "created_at >= date('now', '-30 days') AND is_deleted = 0";
    } else {
      whereClause = 'is_deleted = 0';
    }

    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM divination_records WHERE $whereClause',
    );
    return result.first['cnt'] as int;
  }
}
