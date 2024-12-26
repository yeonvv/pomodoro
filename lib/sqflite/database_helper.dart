import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;

  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    String path = await getDatabasesPath();
    path = join(path, 'pomodoro.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE pomodoros(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            count INTEGER
          )
        ''');
        await db
            .execute('CREATE INDEX IF NOT EXISTS idx_date ON pomodoros(date)');
      },
    );
    return _database!;
  }

  Future<List<Map<String, dynamic>>> getPomodorosForToday(String today) async {
    final db = await DatabaseHelper.getDatabase();
    return await db.query(
      'pomodoros',
      where: 'date = ?',
      whereArgs: [today],
    );
  }

  Future<int> savePomodoro(Map<String, dynamic> row) async {
    final db = await DatabaseHelper.getDatabase();

    var existing = await db.query(
      'pomodoros',
      where: 'date = ?',
      whereArgs: [row['date']],
    );

    if (existing.isNotEmpty) {
      int id = existing.first['id'] as int? ?? 0;
      return await updatePomodoro(id, row);
    } else {
      return await db.insert('pomodoros', row);
    }
  }

  Future<List<Map<String, dynamic>>> getPomodoros() async {
    final db = await DatabaseHelper.getDatabase();
    return await db.query(
      'pomodoros',
      orderBy: 'date DESC',
    );
  }

  Future<int> updatePomodoro(int id, Map<String, dynamic> row) async {
    final db = await DatabaseHelper.getDatabase();
    return await db.update(
      'pomodoros',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deletePomodoro(int id) async {
    final db = await DatabaseHelper.getDatabase();
    return await db.delete(
      'pomodoros',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> closeDatabase() async {
    final db = await DatabaseHelper.getDatabase();
    await db.close();
  }
}
