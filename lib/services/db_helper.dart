import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/draw_line.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'drawing.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE drawings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            path TEXT,
            color INTEGER,
            strokeWidth REAL
          )
        ''');
      },
    );
  }

  static Future<void> saveLines(List<DrawnLine> lines) async {
    final db = await database;
    await db.delete('drawings');

    for (var line in lines) {
      final data = line.toJson();
      await db.insert('drawings', data);
    }
  }

  static Future<List<DrawnLine>> loadLines() async {
    final db = await database;
    final maps = await db.query('drawings');

    return maps.map((map) => DrawnLine.fromJson(map)).toList();
  }
}