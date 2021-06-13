import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:scoped_model/scoped_model.dart';
import 'notesDBworker.dart';
import 'notes_model.dart' show NotesModel, notesModel;
import 'notes_model.dart';

class NotesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: notesModel,
      child: ScopedModelDescendant<NotesModel>(
        builder: (BuildContext context, Widget? child, NotesModel model) {
          Future _deleteNote(BuildContext context, Note note) {
            return showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Delete Note"),
                    content:
                        Text("Are you sure you want delete ${note.title}?"),
                    actions: <Widget>[
                      TextButton(
                          child: Text("Cancel"),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                      TextButton(
                        child: Text("Delete"),
                        onPressed: () async {
                          await NotesDBWorker.db.delete(note.id!);
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 2),
                              content: Text("Note Deleted")));
                          notesModel.loadData("notesData", NotesDBWorker.db);
                        },
                      )
                    ],
                  );
                });
          }

          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add, color: Colors.white),
              onPressed: () {
                notesModel.entityBeingEdited = Note();
                notesModel.setColor(null);
                notesModel.setStackIndex(1);
              },
            ),
            backgroundColor: Theme.of(context).primaryColor,
            body: Container(
            decoration: BoxDecoration(color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft :Radius.circular(30.0),topRight :Radius.circular(30.0))),
              child: ListView.builder(
                itemCount: notesModel.entityList.length,
                itemBuilder: (BuildContext context, int index) {
                  Note note = notesModel.entityList[index];
                  Color color = Colors.white;
                  switch (note.color) {
                    case "red":
                      color = Colors.red;
                      break;
                    case "green":
                      color = Colors.green;
                      break;
                    case "blue":
                      color = Colors.blue;
                      break;
                    case "yellow":
                      color = Colors.yellow;
                      break;
                    case "purple":
                      color = Colors.purpleAccent;
                      break;
                    case "grey":
                      color = Colors.grey;
                      break;
                  }
                  return Container(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Slidable(
                      actionPane: SlidableDrawerActionPane(),
                      actionExtentRatio: .25,
                      secondaryActions: [
                        IconSlideAction(
                            caption: "Delete",
                            color: Colors.red,
                            icon: Icons.delete,
                            onTap: () => _deleteNote(context, note))
                      ],
                      child: Card(
                        elevation: 8,
                        color: color,
                        child: ListTile(
                            title: Text("${note.title}"),
                            subtitle: Text("${note.content}"),
                            onTap: () async {
                              notesModel.entityBeingEdited =
                                  await NotesDBWorker.db.get(note.id!);
                              notesModel
                                  .setColor(notesModel.entityBeingEdited.color);
                              notesModel.setStackIndex(1);
                            }),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
