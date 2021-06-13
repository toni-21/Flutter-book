import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'tasks_list.dart';
import 'tasks_entry.dart';
import 'tasks_model.dart' show TasksModel, tasksModel;

class Tasks extends StatelessWidget {
  tasks() {
    tasksModel.loadTasksList();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
        model: tasksModel,
        child: ScopedModelDescendant<TasksModel>(
            builder: (BuildContext context, Widget? child, TasksModel model) {
          return IndexedStack(
            index: model.stackIndex,
            children: [TasksList(), TasksEntry()],
          );
        }));
  }
}