import '../BaseModel.dart';
import './contactsDBworker.dart';

class Contacts {
  int? id;
  String? name;
  String? phone;
  String? email;
  String? birthday;
}

class ContactsModel extends BaseModel {

  void loadContactsList() async {
    entityList = await ContactsDBWorker.db.getAll();
    notifyListeners();
  }
}

ContactsModel contactsModel = ContactsModel();
