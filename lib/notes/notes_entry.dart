import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'notesDBworker.dart';
import 'notes_model.dart' show NotesModel, notesModel;
import './color_wheel.dart';

class NotesEntry extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return (_NotesEntryState());
  }
}

class _NotesEntryState extends State<NotesEntry> {
  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _contentEditingController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleEditingController.addListener(() {
      notesModel.entityBeingEdited.title = _titleEditingController.text;
    });
    _contentEditingController.addListener(() {
      notesModel.entityBeingEdited.content = _contentEditingController.text;
    });
  }

  @override
  void dispose() {
    _titleEditingController.removeListener(() {
      notesModel.entityBeingEdited.title = _titleEditingController.text;
    });
    _contentEditingController.removeListener(() {
      notesModel.entityBeingEdited.content = _contentEditingController.text;
    });
    super.dispose();
  }

  void _save(BuildContext context, NotesModel model) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    notesModel.entityBeingEdited.title = _titleEditingController.text;
    notesModel.entityBeingEdited.content = _contentEditingController.text;

    if (model.entityBeingEdited.id == null) {
      await NotesDBWorker.db.create(notesModel.entityBeingEdited);
    } else {
      await NotesDBWorker.db.update(notesModel.entityBeingEdited);
    }
    model.loadNoteList();
    model.setStackIndex(0);
    setState(() {
      _titleEditingController.text = "";
      _contentEditingController.text = "";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("Note Saved"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _titleEditingController.text = (notesModel.entityBeingEdited == null ||
              notesModel.entityBeingEdited.title == null)
          ? ""
          : notesModel.entityBeingEdited.title.trim();
      _contentEditingController.text = (notesModel.entityBeingEdited == null ||
              notesModel.entityBeingEdited.content == null)
          ? ""
          : notesModel.entityBeingEdited.content.trim();
    });
    return ScopedModel(
        model: notesModel,
        child: ScopedModelDescendant<NotesModel>(
            builder: (BuildContext context, Widget? child, NotesModel model) {
          return Scaffold(
            backgroundColor: Theme.of(context).primaryColor,
            bottomNavigationBar: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Colors.white))),
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                child: Row(children: <Widget>[
                  TextButton(
                    child: Text("Cancel"),
                    onPressed: () {
                      setState(() {
                        _titleEditingController.text = "";
                        _contentEditingController.text = "";
                      });
                      FocusScope.of(context).requestFocus(FocusNode());
                      model.setStackIndex(0);
                    },
                  ),
                  Spacer(),
                  TextButton(
                    child: Text("Save"),
                    onPressed: () {
                      _save(context, model);
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                  ),
                ])),
            body: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0))),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    ListTile(
                        leading: Icon(Icons.title),
                        title: TextFormField(
                          decoration: InputDecoration(labelText: "Title"),
                          controller: _titleEditingController,
                          validator: (String? value) {
                            if (value == null) {
                              return "Please enter a title";
                            }
                            return null;
                          },
                        )),
                    ListTile(
                      leading: Icon(Icons.content_paste),
                      title: TextFormField(
                        decoration: InputDecoration(labelText: "Content"),
                        keyboardType: TextInputType.multiline,
                        controller: _contentEditingController,
                        maxLines: 8,
                        validator: (String? value) {
                          if (value == null) {
                            return "Please enter content";
                          }
                          return null;
                        },
                      ),
                    ),
                    ColorWheel(notesModel),
                  ],
                ),
              ),
            ),
          );
        }));
  }
}
