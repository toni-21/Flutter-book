import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
//import 'notesDBworker.dart';
import 'notes_entry.dart';
import 'notes_list.dart';
import 'notes_model.dart' show NotesModel, notesModel;

class Notes extends StatelessWidget {
  Notes() {
    notesModel.loadNoteList();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
        model: notesModel,
        child: ScopedModelDescendant<NotesModel>(
            builder: (BuildContext context, Widget? child, NotesModel model) {
          return IndexedStack(
            index: model.stackIndex,
            children: [NotesList(), NotesEntry()],
          );
        }));
  }
}
