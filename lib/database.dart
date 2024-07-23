import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqflite.dart';

//TO PERFORM DATABASE OPERATIONS
class QueryHelper {
  //TABLE CREATION
  static Future<void> create_Table(sql.Database database) async {
    await database.execute("""
  CREATE TABLE note(
  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  title TEXT,
  description TEXT,
  time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
  )

""");
  }

  //CREATE A DATABASE
  static Future<sql.Database> db() async {
    return sql.openDatabase("note_database.db", version: 1,
        onCreate: (sql.Database database, int version) async {
      await create_Table(database);
    });
  }

  //INSERT A NOTE INTO TABLE
  static Future<int> careateNote(String title, String? description) async {
    final db = await QueryHelper.db();
    final dataNote = {'title': title, 'description': description};
    final id = await db.insert('note', dataNote,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  //GET ALL NOTES

  static Future<List<Map<String, dynamic>>> getAllNotes() async {
    final db = await QueryHelper.db();
    return db.query('note', orderBy: 'id');
  }

  //GET A SINGLE NOTE
  static Future<List<Map<String, dynamic>>> getNote(int id) async {
    final db = await QueryHelper.db();
    return db.query('note', where: 'id = ?', whereArgs: [id], limit: 1);
  }

  //UPDATION
  static Future<int> updateNote(
      int id, String title, String? description) async {
    final db = await QueryHelper.db();
    final dataNote = {
      'title': title,
      'description': description,
      'time': DateTime.now().toString()
    };
    final result =
        await db.update('note', dataNote, where: "id = ?", whereArgs: [id]);
    return result;
  }

  //DELETE A NOTE
  static Future<void> deleteNote(int id) async {
    final db = await QueryHelper.db();
    try {
      await db.delete('note', where: "id = ?", whereArgs: [id]);
    } catch (e) {
      e.toString();
    }
  }

  //DELETE ALL NOTES
  static Future<void> deleteAllNotes() async {
    final db = await QueryHelper.db();
    try {
      await db.delete('note');
    } catch (e) {
      e.toString();
    }
  }

  //COUNT TOTAL NUMBER OF NOTES
  static Future<int> getNoteCount() async {
    final db = await QueryHelper.db();
    try {
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM note'),
      );
      return count ?? 0;
    } catch (e) {
      e.toString();
      return 0;
    }
  }
}
