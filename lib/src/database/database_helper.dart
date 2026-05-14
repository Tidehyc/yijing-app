import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'tables.dart';
import '../data/hexagram_data_loader.dart';
import 'dao/hexagram_dao.dart';
import 'dao/divination_dao.dart';

final databaseProvider = Provider<DatabaseHelper>((ref) {
  throw UnimplementedError('DatabaseHelper must be overridden in main()');
});

class DatabaseHelper {
  Database? _database;
  HexagramDao? _hexagramDao;
  DivinationDao? _divinationDao;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  HexagramDao get hexagramDao {
    if (_hexagramDao == null) {
      throw StateError('Database not initialized. Call database first.');
    }
    return _hexagramDao!;
  }

  DivinationDao get divinationDao {
    if (_divinationDao == null) {
      throw StateError('Database not initialized. Call database first.');
    }
    return _divinationDao!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'yijing.db');

    final db = await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    _hexagramDao = HexagramDao(db);
    _divinationDao = DivinationDao(db);

    // Load hexagram data from JSON on first launch
    final loader = HexagramDataLoader(db);
    await loader.loadAllData();

    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(Tables.createHexagrams);
    await db.execute(Tables.createHexagramLines);
    await db.execute(Tables.createCaseReferences);
    await db.execute(Tables.createDivinationRecords);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute(Tables.migrateAddAiResult);
      } catch (_) {
        // Column may already exist
      }
    }
  }
}
