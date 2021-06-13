import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'notes_model.dart';
import '../utils.dart' as utils;

class NotesDBWorker {
  NotesDBWorker._();
  static final NotesDBWorker db = NotesDBWorker._();

  Database? _db;

  Future get database async {
    if (_db == null) {
      _db = await init();
    }
    return _db;
  }

  Future<Database> init() async {
    String path = join(utils.docsDir.path, "notes.db");
    Database db = await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database inDB, int inVersion) async {
      await inDB.execute(
        "CREATE TABLE notes(note_id INTEGER PRIMARY KEY autoincrement, title TEXT, content TEXT, color TEXT)",
      );
    });
    return db;
  }

  Note noteFromMap(Map map) {
    Note note = Note();
    note.id = map["note_id"];
    note.title = map["title"];
    note.content = map["content"];
    note.color = map["color"];
    return note;
  }

  Map<String, dynamic> noteToMap(Note inNote) {
    Map<String, dynamic> inMap = Map<String, dynamic>();
    inMap["note_id"] = inNote.id;
    inMap["title"] = inNote.title;
    inMap["content"] = inNote.content;
    inMap["color"] = inNote.color;
    return inMap;
  }

  Future create(Note note) async {
    Database db = await database;
    var val = await db.rawQuery("SELECT MAX(note_id) + 1 AS note_id FROM notes");
    var id = val.first["note_id"];
    if (id == null) {
      id = 1;
    }
    return await db.rawInsert(
        "INSERT INTO notes(note_id,title,content,color)"
        "VALUES (?,?,?,?)",
        [id, note.title, note.content, note.color]);
  }

  Future<Note> get(int inID) async {
    Database db = await database;
    var rec = await db.query("notes", where: "note_id = ?", whereArgs: [inID]);
    return noteFromMap(rec.first);
  }

  Future<List> getAll() async {
    Database db = await database;
    var recs = await db.query("notes");
    var list = recs.isNotEmpty ? recs.map((m) => noteFromMap(m)).toList() : [];
    return list;
  }

  Future update(Note note) async {
    Database db = await database;
    var upd = await db.update("notes", noteToMap(note),
        where: "note_id = ?", whereArgs: [note.id]);
    return upd;
  }

  Future delete(int id) async {
    Database db = await database;
    return db.delete("notes", where: "note_id = ?", whereArgs: [id]);
  }
}
