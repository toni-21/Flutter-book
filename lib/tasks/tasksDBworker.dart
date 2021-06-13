import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../utils.dart' as utils;
import 'tasks_model.dart';

class TasksDBWorker {
  TasksDBWorker._();
  static final TasksDBWorker db = TasksDBWorker._();

  Database? _db;

  Future get database async {
    if (_db == null) {
      _db = await init();
    }
    return _db;
  }

  Future<Database> init() async {
    String path = join(utils.docsDir.path, "tasks.db");
    Database db = await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database inDB, int inVersion) async {
      await inDB.execute(
          "CREATE TABLE IF NOT EXISTS tasks(task_id INTEGER PRIMARY KEY autoincrement, description TEXT, duedate TEXT, completed TEXT)");
    });
    return db;
  }

  Tasks tasksFromMap(Map map) {
    Tasks task = Tasks();
    task.id = map["task_id"];
    task.description = map["description"];
    task.duedate = map["duedate"];
    task.completed = map["completed"];
    return task;
  }

  Map<String, dynamic> tasksToMap(Tasks task) {
    Map<String, dynamic> inMap = Map<String, dynamic>();
    inMap["task_id"] = task.id;
    inMap["description"] = task.description;
    inMap["duedate"] = task.duedate;
    inMap["completed"] = task.completed;
    return inMap;
  }

  Future create(Tasks task) async {
    Database db = await database;
    var val = await db.rawQuery("SELECT MAX(task_id) + 1 AS task_id FROM tasks");
    var id = val.first["task_id"];
    if (id == null) {
      id = 1;
    }
    return await db.rawInsert(
        "INSERT INTO tasks(task_id,description,duedate,completed)"
        "VALUES (?,?,?,?)",
        [id, task.description,task.duedate,task.completed]);
  }

  Future<Tasks> get(int inID) async {
    Database db = await database;
    var rec = await db.query("tasks", where: "task_id = ?", whereArgs: [inID]);
    return tasksFromMap(rec.first);
  }

  Future<List> getAll() async {
    Database db = await database;
    var recs = await db.query("tasks");
    var list = recs.isNotEmpty ? recs.map((m) => tasksFromMap(m)).toList() : [];
    return list;
  }

  Future update(Tasks task) async {
    Database db = await database;
    var upd = await db.update("tasks", tasksToMap(task),
        where: "task_id = ?", whereArgs: [task.id]);
    return upd;
  }

  Future delete(int id) async {
    Database db = await database;
    return db.delete("tasks", where: "task_id = ?", whereArgs: [id]);
  }
}
