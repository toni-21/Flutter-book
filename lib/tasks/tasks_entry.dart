import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'tasksDBworker.dart';
import 'tasks_model.dart';
import '../utils.dart' as utils;

class TasksEntry extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TasksEntryState();
  }
}

class _TasksEntryState extends State<TasksEntry> {
  final TextEditingController _descriptionEditingController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _descriptionEditingController.addListener(() {
      tasksModel.entityBeingEdited.description =
          _descriptionEditingController.text;
    });
  }

  @override
  void dispose() {
    _descriptionEditingController.removeListener(() {
      tasksModel.entityBeingEdited.description =
          _descriptionEditingController.text;
    });
    super.dispose();
  }

  void _save(BuildContext context, TasksModel model) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    tasksModel.entityBeingEdited.description =
        _descriptionEditingController.text;
    if (tasksModel.entityBeingEdited.id == null) {
      await TasksDBWorker.db.create(tasksModel.entityBeingEdited);
    } else {
      await TasksDBWorker.db.update(tasksModel.entityBeingEdited);
    }

    model.loadTasksList();
    model.setStackIndex(0);
    setState(() {
      _descriptionEditingController.text = "";
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("Task Saved"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _descriptionEditingController.text =
          (tasksModel.entityBeingEdited == null ||
                  tasksModel.entityBeingEdited.description == null)
              ? ""
              : tasksModel.entityBeingEdited.description.trim();
    });
    return ScopedModel(
      model: tasksModel,
      child: ScopedModelDescendant<TasksModel>(
        builder: (BuildContext context, Widget? child, TasksModel model) {
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
                          _descriptionEditingController.text = "";
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
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
                  child: Container(
                    margin: EdgeInsets.all(10.0),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.title),
                            title: TextFormField(
                              decoration: InputDecoration(
                                  labelText: "Task Description"),
                              controller: _descriptionEditingController,
                              validator: (String? value) {
                                if (value == "") {
                                  return "Please enter a task";
                                }
                              },
                            ),
                          ),
                          ListTile(
                            title: Text("Due Date"),
                            subtitle: Text(tasksModel.chosenDate == null
                                ? ""
                                : tasksModel.chosenDate!),
                            leading: Icon(Icons.today),
                            trailing: IconButton(
                                icon: Icon(Icons.edit),
                                color: Colors.blue,
                                onPressed: () async {
                                  String chosenDate = await utils.selectDate(
                                      context, model, null);
                                  tasksModel.entityBeingEdited.duedate =
                                      chosenDate;
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ));
        },
      ),
    );
  }
}
