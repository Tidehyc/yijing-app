import 'package:sqflite/sqflite.dart';

class HexagramDao {
  final Database db;

  HexagramDao(this.db);

  Future<Map<String, dynamic>?> getHexagramById(int id) async {
    final results = await db.query('hexagrams', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<List<Map<String, dynamic>>> getLineTexts(int hexagramId) async {
    return db.query(
      'hexagram_lines',
      where: 'hexagram_id = ?',
      whereArgs: [hexagramId],
      orderBy: 'line_number ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getCases(int hexagramId, String sourceType) async {
    return db.query(
      'case_references',
      where: 'hexagram_id = ? AND source_type = ?',
      whereArgs: [hexagramId, sourceType],
    );
  }

  Future<List<Map<String, dynamic>>> searchHexagrams(String query) async {
    return db.query(
      'hexagrams',
      where: 'name_zh LIKE ? OR overall_verdict LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
  }
}
