import '../BaseModel.dart';
import 'notesDBworker.dart';

class Note {
  int? id;
  String? title;
  String? content;
  String? color;

  String toString() {
    return "{id = $id , title = $title , content = $content color = $color}";
  }
}

class NotesModel extends BaseModel {
  String? color;

  void setColor(String? inColor) {
    color = inColor;
    notifyListeners();
  }

  void loadNoteList() async {
    entityList = await NotesDBWorker.db.getAll();
    notifyListeners();
  }
}

NotesModel notesModel = NotesModel();
