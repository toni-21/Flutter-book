import '../BaseModel.dart';
import 'tasksDBworker.dart';

class Tasks{
  int? id;
  String? description;
  String? duedate;
  String completed = "false";

  String toString() {
    return "{id = $id , description = $description , duedate = $duedate completed = $completed}";
  }
}

class TasksModel extends BaseModel{
  void loadTasksList() async {
    entityList = await TasksDBWorker.db.getAll();
    notifyListeners();
  }
}

TasksModel tasksModel = TasksModel();