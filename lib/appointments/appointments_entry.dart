import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import './appointmentsDBworker.dart';
import './appointments_model.dart';
import '../utils.dart' as utils;

class AppointmentsEntry extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AppointmentsEntryState();
  }
}

class _AppointmentsEntryState extends State<AppointmentsEntry> {
  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _descriptionEditingController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleEditingController.addListener(() {
      appointmentsModel.entityBeingEdited.title = _titleEditingController.text;
    });
    _descriptionEditingController.addListener(() {
      appointmentsModel.entityBeingEdited.description =
          _descriptionEditingController.text;
    });
  }

  @override
  void dispose() {
    _titleEditingController.dispose();
    _descriptionEditingController.dispose();

    super.dispose();
  }

  void _save(BuildContext context, AppointmentsModel model) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    appointmentsModel.entityBeingEdited.title = _titleEditingController.text;
    appointmentsModel.entityBeingEdited.description =
        _descriptionEditingController.text;
    if (appointmentsModel.entityBeingEdited.id == null) {
      await AppointmentsDBWorker.db.create(appointmentsModel.entityBeingEdited);
    } else {
      await AppointmentsDBWorker.db.update(appointmentsModel.entityBeingEdited);
    }

    model.loadApptList();
    model.setStackIndex(0);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("Appointment Saved"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2)),
    );
  }

  Future _selectTime(BuildContext context) async {
    TimeOfDay initialTime = TimeOfDay.now();
    if (appointmentsModel.entityBeingEdited.apptTime != null) {
      List timeParts =
          (appointmentsModel.entityBeingEdited.apptTime.split(","));
      initialTime = TimeOfDay(
          hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
    }
    TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: initialTime);
    if (picked != null) {
      appointmentsModel.entityBeingEdited.apptTime =
          "${picked.hour},${picked.minute}";
      appointmentsModel.setApptTime(picked.format(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: appointmentsModel,
      child: ScopedModelDescendant<AppointmentsModel>(
        builder:
            (BuildContext context, Widget? child, AppointmentsModel model) {
          return Scaffold(
            backgroundColor: Theme.of(context).primaryColor,
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border:
                      Border(top: BorderSide(width: 0, color: Colors.white))),
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              child: Row(
                children: <Widget>[
                  TextButton(
                    child: Text("Cancel"),
                    onPressed: () {
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
                ],
              ),
            ),
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
                          leading: Icon(Icons.notes),
                          title: TextFormField(
                            decoration:
                                InputDecoration(hintText: "Appointment"),
                            controller: _titleEditingController,
                            validator: (String? value) {
                              if (value == null) {
                                return "Please enter a title";
                              }
                              return null;
                            },
                          ),
                        ),
                        ListTile(
                          leading: Icon(Icons.description),
                          title: TextFormField(
                            decoration:
                                InputDecoration(hintText: "Description"),
                            maxLines: 3,
                            keyboardType: TextInputType.multiline,
                            controller: _descriptionEditingController,
                            validator: (String? value) {
                              if (value == null) {
                                return "Please enter a description";
                              }
                              return null;
                            },
                          ),
                        ),
                        ListTile(
                          title: Text("Date"),
                          subtitle: Text(appointmentsModel.chosenDate == null
                              ? ""
                              : appointmentsModel.chosenDate!),
                          leading: Icon(Icons.today),
                          trailing: IconButton(
                              icon: Icon(Icons.edit),
                              color: Colors.blue,
                              onPressed: () async {
                                String chosenDate = await utils.selectDate(
                                    context, model, null);
                                appointmentsModel.entityBeingEdited.apptDate =
                                    chosenDate;
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                              }),
                        ),
                        ListTile(
                          title: Text("Time"),
                          subtitle: Text(appointmentsModel.apptTime == null
                              ? ""
                              : appointmentsModel.apptTime!),
                          leading: Icon(Icons.alarm),
                          trailing: IconButton(
                              icon: Icon(Icons.edit),
                              color: Colors.blue,
                              onPressed: () => _selectTime(context)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
