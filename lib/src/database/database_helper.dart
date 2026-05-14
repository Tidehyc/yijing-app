import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'tables.dart';

final databaseProvider = Provider<DatabaseHelper>((ref) {
  throw UnimplementedError('DatabaseHelper must be overridden in main()');
});

class DatabaseHelper {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'yijing.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(Tables.createHexagrams);
    await db.execute(Tables.createHexagramLines);
    await db.execute(Tables.createCaseReferences);
    await db.execute(Tables.createDivinationRecords);
  }
}
