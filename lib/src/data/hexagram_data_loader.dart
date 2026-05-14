import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

class HexagramDataLoader {
  final Database db;

  HexagramDataLoader(this.db);

  /// Check if hexagram data already loaded
  Future<bool> isDataLoaded() async {
    final result = await db.rawQuery('SELECT COUNT(*) as cnt FROM hexagrams');
    return (result.first['cnt'] as int) > 0;
  }

  /// Load all JSON data files into SQLite
  Future<void> loadAllData() async {
    final loaded = await isDataLoaded();

    if (!loaded) {
      await _loadBasicData();
    }

    // Always update deep data
    await _loadDeepData();
  }

  Future<void> _loadBasicData() async {
    final jsonStr = await rootBundle.loadString('assets/data/hexagrams_basic.json');
    final List<dynamic> data = json.decode(jsonStr);

    for (final item in data) {
      final map = item as Map<String, dynamic>;
      await db.insert('hexagrams', {
        'id': map['id'],
        'name_zh': map['name_zh'],
        'name_pinyin': map['name_pinyin'],
        'upper_trigram': map['upper_trigram'],
        'lower_trigram': map['lower_trigram'],
        'binary_code': map['binary_code'],
        'palace': map['palace'],
        'wuxing': map['wuxing'],
        'shallow_interpretation': map['shallow_interpretation'] ?? '',
        'overall_verdict': map['overall_verdict'] ?? '',
      });
    }
  }

  Future<void> _loadDeepData() async {
    final jsonStr = await rootBundle.loadString('assets/data/hexagrams_deep.json');
    final List<dynamic> data = json.decode(jsonStr);

    for (final item in data) {
      final map = item as Map<String, dynamic>;
      final hexId = map['id'] as int;

      // Update hexagram record with deep text
      await db.update('hexagrams', {
        'judgment': map['judgment'] ?? '',
        'judgment_vernacular': map['judgment_vernacular'] ?? '',
        'tuan_zhuan': map['tuan_zhuan'] ?? '',
        'tuan_zhuan_vernacular': map['tuan_zhuan_vernacular'] ?? '',
        'xiang_zhuan': map['xiang_zhuan'] ?? '',
        'xiang_zhuan_vernacular': map['xiang_zhuan_vernacular'] ?? '',
        'shallow_interpretation': map['shallow_interpretation'] ?? '',
      }, where: 'id = ?', whereArgs: [hexId]);

      // Delete old line texts then re-insert
      await db.delete('hexagram_lines', where: 'hexagram_id = ?', whereArgs: [hexId]);
      final lines = map['lines'] as List<dynamic>? ?? [];
      for (final line in lines) {
        final l = line as Map<String, dynamic>;
        await db.insert('hexagram_lines', {
          'hexagram_id': hexId,
          'line_number': l['number'],
          'line_name': l['name'],
          'line_text': l['text'] ?? '',
          'line_text_vernacular': l['vernacular'] ?? '',
          'xiao_xiang': l['xiao_xiang'] ?? '',
          'xiao_xiang_vernacular': l['xiao_xiang_vernacular'] ?? '',
          'changing_meaning': l['changing_meaning'] ?? '',
        });
      }
    }
  }

}
