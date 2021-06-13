import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import './contacts_model.dart';
import '../utils.dart' as utils;

class ContactsDBWorker {
  ContactsDBWorker._();
  static final ContactsDBWorker db = ContactsDBWorker._();

  Database? _db;

  Future get database async {
    if (_db == null) {
      _db = await init();
    }
    return _db;
  }

  Future<Database> init() async {
    String path = join(utils.docsDir.path, "contacts.db");
    Database db = await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database inDB, int inVersion) async {
      await inDB.execute(
          "CREATE TABLE IF NOT EXISTS contacts(contact_id INTEGER PRIMARY KEY autoincrement, name TEXT, phone TEXT, email TEXT, birthday TEXT)");
    });
    return db;
  }

  Contacts contactFromMap(Map map) {
    Contacts contact = Contacts();
    contact.id = map["contact_id"];
    contact.name = map["name"];
    contact.phone = map["phone"];
    contact.email = map["email"];
    contact.birthday = map['birthday'];
    return contact;
  }

  Map<String, dynamic> contactToMap(Contacts contact) {
    Map<String, dynamic> map = Map<String, dynamic>();
    map["contact_id"] = contact.id;
    map["name"] = contact.name;
    map["phone"] = contact.phone;
    map["email"] = contact.email;
    map['birthday'] = contact.birthday;
    return map;
  }

  Future create(Contacts contact) async {
    Database db = await database;
    var val = await db
        .rawQuery("SELECT MAX(contact_id) + 1 AS contact_id FROM contacts");
    var id = val.first["contact_id"];
    if (id == null) {
      id = 1;
    }
    db.rawInsert(
        "INSERT INTO contacts(contact_id, name,phone,email,birthday)"
        "VALUES(?,?,?,?,?)",
        [id, contact.name, contact.phone, contact.email, contact.birthday]);
    return id;
  }

  Future<Contacts> get(int inID) async {
    Database db = await database;
    var rec =
        await db.query("contacts", where: "contact_id = ?", whereArgs: [inID]);
    return contactFromMap(rec.first);
  }

  Future<List> getAll() async {
    Database db = await database;
    var recs = await db.query("contacts");
    var list =
        recs.isNotEmpty ? recs.map((m) => contactFromMap(m)).toList() : [];
    return list;
  }

  Future update(Contacts contact) async {
    Database db = await database;
    var upd = await db.update("contacts", contactToMap(contact),
        where: "contact_id = ?", whereArgs: [contact.id]);
    return upd;
  }

  Future delete(int id) async {
    Database db = await database;
    return await db
        .delete("contacts", where: "contact_id = ?", whereArgs: [id]);
  }
}
