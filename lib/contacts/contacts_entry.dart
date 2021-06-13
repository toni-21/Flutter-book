import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import './contacts_model.dart';
import './contactsDBworker.dart';
import '../utils.dart' as utils;

class ContactsEntry extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ContactsEntryState();
  }
}

class _ContactsEntryState extends State<ContactsEntry> {
  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _phoneEditingController = TextEditingController();
  final TextEditingController _emailEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameEditingController.addListener(() {
      contactsModel.entityBeingEdited.name = _nameEditingController.text;
    });
    _phoneEditingController.addListener(() {
      contactsModel.entityBeingEdited.phone = _phoneEditingController.text;
    });
    _emailEditingController.addListener(() {
      contactsModel.entityBeingEdited.email = _emailEditingController.text;
    });
  }

  @override
  void dispose() {
    _nameEditingController.removeListener(() {
      contactsModel.entityBeingEdited.name = _nameEditingController.text;
    });
    _phoneEditingController.removeListener(() {
      contactsModel.entityBeingEdited.phone = _phoneEditingController.text;
    });
    _emailEditingController.removeListener(() {
      contactsModel.entityBeingEdited.email = _emailEditingController.text;
    });
    super.dispose();
  }

  void _save(BuildContext context, ContactsModel model) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    contactsModel.entityBeingEdited.name = _nameEditingController.text;
    contactsModel.entityBeingEdited.phone = _phoneEditingController.text;
    contactsModel.entityBeingEdited.email = _emailEditingController.text;
    if (contactsModel.entityBeingEdited.birthday == null ||
        contactsModel.chosenDate == null) {
      contactsModel.entityBeingEdited.birthday = "";
    }

    int id;
    if (contactsModel.entityBeingEdited.id == null) {
      id = await ContactsDBWorker.db.create(contactsModel.entityBeingEdited);
    } else {
      await ContactsDBWorker.db.update(contactsModel.entityBeingEdited);
      id = contactsModel.entityBeingEdited.id;
    }

    File avatarFile = File(join(utils.docsDir.path, "avatar"));
    if (avatarFile.existsSync()) {
      avatarFile.renameSync(join(utils.docsDir.path, id.toString()));
    }
    print("image now stored at: ${join(utils.docsDir.path, id.toString())}");
    model.loadContactsList();
    model.setStackIndex(0);
    setState(() {
      _nameEditingController.text = "";
      _phoneEditingController.text = "";
      _emailEditingController.text = "";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("Contact Saved"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2)),
    );
  }

  Future _selectAvatar(BuildContext context) async {
    File? _cameraImage;
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              content: SingleChildScrollView(
            child: ListBody(
              children: [
                GestureDetector(
                  child: Text("Take a picture"),
                  onTap: () async {
                    var pickedImage = await _picker.getImage(
                        source: ImageSource.camera,
                        imageQuality: 50,
                        maxWidth: 500);
                    setState(() {
                      _cameraImage = File(pickedImage!.path);
                      _cameraImage!
                          .copySync(join(utils.docsDir.path, "avatar"));
                    });
                    Navigator.of(context).pop();
                    print(
                        "Picture taken and stored at ${join(utils.docsDir.path, "avatar")}");
                  },
                ),
                SizedBox(height: 10.0),
                GestureDetector(
                  child: Text("Select from Gallery"),
                  onTap: () async {
                    var pickedImage = await _picker.getImage(
                        source: ImageSource.gallery,
                        imageQuality: 50,
                        maxWidth: 500);
                    setState(() {
                      _cameraImage = File(pickedImage!.path);
                      _cameraImage!
                          .copySync(join(utils.docsDir.path, "avatar"));
                    });
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          ));
        });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _nameEditingController.text = (contactsModel.entityBeingEdited == null ||
              contactsModel.entityBeingEdited.name == null)
          ? ""
          : contactsModel.entityBeingEdited.name.trim();
      _phoneEditingController.text = (contactsModel.entityBeingEdited == null ||
              contactsModel.entityBeingEdited.phone == null)
          ? ""
          : contactsModel.entityBeingEdited.phone.trim();
      _emailEditingController.text = (contactsModel.entityBeingEdited == null ||
              contactsModel.entityBeingEdited.email == null)
          ? ""
          : contactsModel.entityBeingEdited.email.trim();
    });
    return ScopedModel(
      model: contactsModel,
      child: ScopedModelDescendant<ContactsModel>(
        builder: (BuildContext context, Widget? child, ContactsModel model) {
          File avatarFile = File(join(utils.docsDir.path, "avatar"));
          if (avatarFile.existsSync() == false) {
            if (model.entityBeingEdited != null &&
                model.entityBeingEdited.id != null) {
              avatarFile = File(join(
                  utils.docsDir.path, model.entityBeingEdited.id.toString()));
            }
          }
          return Scaffold(
            backgroundColor: Theme.of(context).primaryColor,
            bottomNavigationBar: Container(
              decoration: BoxDecoration(color: Colors.white,border: Border(top: BorderSide(width: 0, color:Colors.white))),
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              child: Row(
                children: <Widget>[
                  TextButton(
                    child: Text("Cancel"),
                    onPressed: () {
                      File avatarFile =
                          File(join(utils.docsDir.path, "avatar"));
                      if (avatarFile.existsSync()) {
                        avatarFile.deleteSync();
                      }
                      setState(() {
                        _nameEditingController.text = "";
                        _phoneEditingController.text = "";
                        _emailEditingController.text = "";
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
                ],
              ),
            ),
            body: Container(decoration: BoxDecoration(
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
                              title: avatarFile.existsSync()
                                  ? Image.file(
                                      avatarFile,
                                      fit: BoxFit.cover,
                                      width: MediaQuery.of(context).size.width /
                                          1.2,
                                      height: 250,
                                    )
                                  : Text("No avatar image for this contact"),
                              trailing: IconButton(
                                icon: Icon(Icons.edit),
                                color: Colors.blue,
                                onPressed: () => _selectAvatar(context),
                              )),
                          ListTile(
                            leading: Icon(Icons.person),
                            title: TextFormField(
                              decoration: InputDecoration(labelText: "Name"),
                              controller: _nameEditingController,
                              validator: (String? value) {
                                if (value == null) {
                                  return "Please enter a name";
                                }
                                return null;
                              },
                            ),
                          ),
                          ListTile(
                            leading: Icon(Icons.phone),
                            title: TextFormField(
                              decoration: InputDecoration(labelText: "Phone"),
                              controller: _phoneEditingController,
                              keyboardType: TextInputType.phone,
                              validator: (String? value) {
                                if (value == null) {
                                  return "Please enter a phone number";
                                }
                                return null;
                              },
                            ),
                          ),
                          ListTile(
                            leading: Icon(Icons.email),
                            title: TextFormField(
                              decoration: InputDecoration(labelText: "Email"),
                              keyboardType: TextInputType.emailAddress,
                              controller: _emailEditingController,
                            ),
                          ),
                          ListTile(
                            title: Text("Birthday"),
                            subtitle: Text(contactsModel.chosenDate == null
                                ? ""
                                : contactsModel.chosenDate!),
                            leading: Icon(Icons.today),
                            trailing: IconButton(
                                icon: Icon(Icons.edit),
                                color: Colors.blue,
                                onPressed: () async {
                                  String? chosenDate = await utils.selectDate(
                                      context, model, null);
                                  if (chosenDate != null) {
                                    contactsModel.entityBeingEdited.birthday =
                                        chosenDate;
                                  }

                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                }),
                          ),
                        ],
                      ),
                    ),
                  )),
            ),
          );
        },
      ),
    );
  }
}
