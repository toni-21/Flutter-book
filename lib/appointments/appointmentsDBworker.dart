import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import './appointments_model.dart';
import '../utils.dart' as utils;

class AppointmentsDBWorker {
  AppointmentsDBWorker._();
  static final AppointmentsDBWorker db = AppointmentsDBWorker._();

  Database? _db;

  Future get database async {
    if (_db == null) {
      _db = await init();
    }
    return _db;
  }

  Future<Database> init() async {
    String path = join(utils.docsDir.path, "appointments.db");
    Database db = await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database inDB, int inVersion) async {
        await inDB.execute(
            "CREATE TABLE IF NOT EXISTS appointments(appt_id INTEGER PRIMARY KEY autoincrement, title TEXT, description TEXT, apptDate TEXT,apptTime TEXT)");
      },
    );
    return db;
  }

  Future create(Appointments appt) async {
    Database db = await database;
    var val = await db
        .rawQuery("SELECT MAX(appt_id)+ 1 AS appt_id FROM appointments");
    var id = val.first["appt_id"];
    if (id == null) {
      id = 1;
    }
    return await db.rawInsert(
        "INSERT INTO appointments(appt_id,title,description,apptDate,apptTime)"
        "VALUES (?,?,?,?,?)",
        [id, appt.title, appt.description,appt.apptDate, appt.apptTime]);
  }

  Appointments apptFromMap(Map map) {
    Appointments appt = Appointments();
    appt.id = map["appt_id"];
    appt.title = map["title"];
    appt.description = map["description"];
    appt.apptDate = map["apptDate"];
    appt.apptTime = map["apptTime"];
    return appt;
  }

  Map<String, dynamic> apptToMap(Appointments appt) {
    Map<String, dynamic> inMap = Map<String, dynamic>();
    inMap["appt_id"] = appt.id;
    inMap["title"] = appt.title;
    inMap["description"] = appt.description;
    inMap["apptDate"] = appt.apptDate;
    inMap["apptTime"] = appt.apptTime;
    return inMap;
  }

  Future<Appointments> get(int inID) async {
    Database db = await database;
    var rec =
        await db.query("appointments", where: "appt_id = ?", whereArgs: [inID]);
    return apptFromMap(rec.first);
  }

  Future<List> getAll() async {
    Database db = await database;
    var recs = await db.query("appointments");
    var list = recs.isNotEmpty ? recs.map((m) => apptFromMap(m)).toList() : [];
    return list;
  }

  Future update(Appointments appt) async {
    Database db = await database;
    var upd = await db.update("appointments", apptToMap(appt),
        where: "appt_id = ?", whereArgs: [appt.id]);
    return upd;
  }

  Future delete(int id) async {
    Database db = await database;
    return db.delete("appointments", where: "appt_id = ?", whereArgs: [id]);
  }
}
