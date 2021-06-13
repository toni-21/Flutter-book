import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import './contacts_model.dart';
import './contactsDBworker.dart';
import 'package:path/path.dart';
import '../utils.dart' as utils;

class ContactsList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ContactsListState();
  }
}

class _ContactsListState extends State<ContactsList> {
  @override
  void initState() {
    super.initState();
    contactsModel.loadContactsList();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: contactsModel,
      child: ScopedModelDescendant<ContactsModel>(
          builder: (BuildContext context, Widget? child, ContactsModel model) {
        Future _deleteContact(BuildContext context, Contacts contact) async {
          return showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Delete Contact"),
                  content:
                      Text("Are you sure you want delete ${contact.name}?"),
                  actions: <Widget>[
                    TextButton(
                        child: Text("Cancel"),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    TextButton(
                      child: Text("Delete"),
                      onPressed: () async {
                        File avatarFile = File(
                            join(utils.docsDir.path, contact.id.toString()));
                        if (avatarFile.existsSync()) {
                          avatarFile.deleteSync();
                        }
                        await ContactsDBWorker.db.delete(contact.id!);
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2),
                            content: Text("Contact Deleted")));
                        contactsModel.loadContactsList();
                      },
                    )
                  ],
                );
              });
        }

        return Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
            floatingActionButton: FloatingActionButton(
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {
                File avatarFile = File(join(utils.docsDir.path, "avatar"));
                if (avatarFile.existsSync()) {
                  avatarFile.deleteSync();
                }
                contactsModel.entityBeingEdited = Contacts();
                contactsModel.setChosenDate(null);
                contactsModel.setStackIndex(1);
              },
            ),
            body: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0))),
              child: ListView.builder(
                  itemCount: contactsModel.entityList.length,
                  itemBuilder: (BuildContext context, int index) {
                    Contacts contact = contactsModel.entityList[index];
                    File avatarFile =
                        File(join(utils.docsDir.path, contact.id.toString()));
                    bool avatarFileExists = avatarFile.existsSync();

                    return Column(
                      children: <Widget>[
                        Slidable(
                            actionPane: SlidableDrawerActionPane(),
                            actionExtentRatio: .25,
                            child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.indigoAccent,
                                  foregroundColor: Colors.white,
                                  backgroundImage: avatarFileExists
                                      ? FileImage(avatarFile)
                                      : null,
                                  child: avatarFileExists
                                      ? null
                                      : Text(contact.name!
                                          .substring(0, 1)
                                          .toUpperCase()),
                                ),
                                title: Text("${contact.name}"),
                                subtitle: contact.phone == null
                                    ? null
                                    : Text("${contact.phone}"),
                                onTap: () async {
                                  File avatarFile =
                                      File(join(utils.docsDir.path, "avatar"));
                                  if (avatarFile.existsSync()) {
                                    avatarFile.deleteSync();
                                  }
                                  contactsModel.entityBeingEdited =
                                      await ContactsDBWorker.db
                                          .get(contact.id!);
                                  if (contactsModel
                                          .entityBeingEdited.birthday ==
                                      null) {
                                    contactsModel.setChosenDate(null);
                                  } else {
                                    List dateParts;
                                    if (contact.birthday == null ||
                                        contact.birthday == "") {
                                      dateParts = [];
                                      contactsModel.setChosenDate(null);
                                    } else {
                                      dateParts = contact.birthday!.split(",");
                                      DateTime birthday = DateTime(
                                        int.parse(dateParts[0]),
                                        int.parse(dateParts[1]),
                                        int.parse(dateParts[2]),
                                      );
                                      String sBirthday =
                                          DateFormat.yMMMd("en_US")
                                              .format(birthday.toLocal());
                                      contactsModel.setChosenDate(sBirthday);
                                    }
                                    contactsModel.setStackIndex(1);
                                  }
                                }),
                            secondaryActions: [
                              IconSlideAction(
                                caption: "Delete",
                                color: Colors.red,
                                icon: Icons.delete,
                                onTap: () => _deleteContact(context, contact),
                              )
                            ]),
                        Divider()
                      ],
                    );
                  }),
            ));
      }),
    );
  }
}
