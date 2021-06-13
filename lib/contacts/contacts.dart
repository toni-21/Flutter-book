import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
//import 'contactsDBworker.dart';
import 'contacts_entry.dart';
import 'contacts_list.dart';
import 'contacts_model.dart';
class Contacts extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
        model: contactsModel,
        child: ScopedModelDescendant<ContactsModel>(
            builder: (BuildContext context, Widget? child, ContactsModel model) {
          return IndexedStack(
            index: model.stackIndex,
            children: [ContactsList(), ContactsEntry()],
          );
        }));
  }
}
