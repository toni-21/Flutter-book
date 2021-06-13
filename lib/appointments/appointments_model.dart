import '../BaseModel.dart';
import './appointmentsDBworker.dart';

class Appointments {
  int? id;
  String? title;
  String? description;
  String? apptDate;
  String? apptTime;
}

class AppointmentsModel extends BaseModel {
  String? apptTime;
  void setApptTime(String? inApptTime) {
    apptTime = inApptTime;
    notifyListeners();
  }

   void loadApptList() async {
    entityList = await AppointmentsDBWorker.db.getAll();
    notifyListeners();
  }
}

AppointmentsModel appointmentsModel = AppointmentsModel();