import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'utils.dart' as utils;
import 'appointments/appointments.dart';
import 'contacts/contacts.dart';
import 'notes/notes.dart';
import 'tasks/tasks.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  startMeUp() async {
    Directory docsDir = await getApplicationDocumentsDirectory();
    utils.docsDir = docsDir;
    runApp(FlutterBook());
  }

  startMeUp();
}

class FlutterBook extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(elevation: 0),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(elevation: 0),
      ),
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
            appBar: AppBar(
              title: Text("FlutterBook"),
              bottom: TabBar(
                indicatorColor: Colors.transparent,
                tabs: [
                  Tab(
                    icon: Icon(Icons.date_range),
                    text: ("Appointment"),
                  ),
                  Tab(
                    icon: Icon(Icons.contacts),
                    text: ("Contacts"),
                  ),
                  Tab(
                    icon: Icon(Icons.note),
                    text: ("Notes"),
                  ),
                  Tab(
                    icon: Icon(Icons.assignment_turned_in),
                    text: ("Tasks"),
                  ),
                ],
              ),
            ),
            body:
     TabBarView(
                children: <Widget>[
                  Appointments(),
                  Contacts(),
                  Notes(),
                  Tasks(),
                ],
              ),
            ),
      ),
    );
  }
}
