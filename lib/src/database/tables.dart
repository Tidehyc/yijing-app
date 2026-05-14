class Tables {
  Tables._();

  static const String createHexagrams = '''
    CREATE TABLE IF NOT EXISTS hexagrams (
      id INTEGER PRIMARY KEY,
      name_zh TEXT NOT NULL,
      name_pinyin TEXT NOT NULL,
      upper_trigram TEXT NOT NULL,
      lower_trigram TEXT NOT NULL,
      binary_code TEXT NOT NULL,
      palace TEXT,
      wuxing TEXT,
      shallow_interpretation TEXT,
      judgment TEXT,
      judgment_vernacular TEXT,
      tuan_zhuan TEXT,
      tuan_zhuan_vernacular TEXT,
      xiang_zhuan TEXT,
      xiang_zhuan_vernacular TEXT,
      overall_verdict TEXT
    )
  ''';

  static const String createHexagramLines = '''
    CREATE TABLE IF NOT EXISTS hexagram_lines (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      hexagram_id INTEGER NOT NULL,
      line_number INTEGER NOT NULL,
      line_name TEXT NOT NULL,
      line_text TEXT NOT NULL,
      line_text_vernacular TEXT,
      xiao_xiang TEXT,
      xiao_xiang_vernacular TEXT,
      changing_meaning TEXT,
      FOREIGN KEY (hexagram_id) REFERENCES hexagrams(id)
    )
  ''';

  static const String createCaseReferences = '''
    CREATE TABLE IF NOT EXISTS case_references (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      hexagram_id INTEGER NOT NULL,
      source TEXT NOT NULL,
      source_type TEXT NOT NULL,
      title TEXT NOT NULL,
      narrative TEXT NOT NULL,
      analysis TEXT NOT NULL,
      relevance TEXT,
      FOREIGN KEY (hexagram_id) REFERENCES hexagrams(id)
    )
  ''';

  static const String createDivinationRecords = '''
    CREATE TABLE IF NOT EXISTS divination_records (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      created_at TEXT NOT NULL,
      question TEXT,
      notes TEXT,
      original_hexagram_id INTEGER NOT NULL,
      changing_hexagram_id INTEGER,
      changing_line_positions TEXT,
      cast_sequence TEXT NOT NULL,
      is_deleted INTEGER DEFAULT 0,
      lunar_date TEXT,
      solar_date TEXT,
      FOREIGN KEY (original_hexagram_id) REFERENCES hexagrams(id),
      FOREIGN KEY (changing_hexagram_id) REFERENCES hexagrams(id)
    )
  ''';
}
