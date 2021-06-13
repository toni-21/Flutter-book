import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'tasksDBworker.dart';
import 'tasks_model.dart';

class TasksList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TasksListState();
  }
}

class _TasksListState extends State<TasksList> {
  late bool val;

  @override
  void initState() {
    super.initState();
    tasksModel.loadTasksList();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: tasksModel,
      child: ScopedModelDescendant<TasksModel>(
        builder: (BuildContext context, Widget? child, TasksModel model) {
          Future _deleteTask(BuildContext context, Tasks task) {
            return showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Delete Task"),
                    content: Text("Are you sure you want delete this task?"),
                    actions: <Widget>[
                      TextButton(
                          child: Text("Cancel"),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                      TextButton(
                        child: Text("Delete"),
                        onPressed: () async {
                          await TasksDBWorker.db.delete(task.id!);
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 2),
                              content: Text("Task Deleted")));
                          tasksModel.loadTasksList();
                        },
                      )
                    ],
                  );
                });
          }

          Widget _buildCheckbox(Tasks task, String sDueDate) {
            this.val = task.completed == "true" ? true : false;
            return Slidable(
              actionPane: SlidableDrawerActionPane(),
              actionExtentRatio: .25,
              child: ListTile(
                leading: Checkbox(
                    value: val,
                    onChanged: (value) async {
                      task.completed = value.toString();
                      await TasksDBWorker.db.update(task);
                      setState(() {
                        this.val = value!;
                        tasksModel.loadTasksList();
                      });
                    }),
                title: Text(
                  '${task.description},',
                  style: task.completed == "true"
                      ? TextStyle(
                          color: Theme.of(context).disabledColor,
                          decoration: TextDecoration.lineThrough)
                      : TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                ),
                subtitle: task.duedate == null
                    ? null
                    : Text(
                        sDueDate,
                        style: task.completed == "true"
                            ? TextStyle(
                                color: Theme.of(context).disabledColor,
                                decoration: TextDecoration.lineThrough)
                            : TextStyle(fontSize: 15),
                      ),
                onTap: () async {
                  if (task.completed == "true") {
                    return;
                  }
                  tasksModel.entityBeingEdited =
                      await TasksDBWorker.db.get(task.id!);
                  if (tasksModel.entityBeingEdited.duedate == null) {
                    tasksModel.setChosenDate(null);
                  } else {
                    tasksModel.setChosenDate(sDueDate);
                  }

                  model.setStackIndex(1);
                },
              ),
              secondaryActions: [
                IconSlideAction(
                  caption: "Delete",
                  color: Colors.red,
                  icon: Icons.delete,
                  onTap: () => _deleteTask(context, task),
                )
              ],
            );
          }

          return Scaffold(
            backgroundColor: Theme.of(context).primaryColor,
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add, color: Colors.white),
              onPressed: () {
                tasksModel.entityBeingEdited = Tasks();
                tasksModel.setChosenDate(null);
                tasksModel.setStackIndex(1);
              },
            ),
            body: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0))),
              child: ListView.builder(
                  itemCount: tasksModel.entityList.length,
                  itemBuilder: (BuildContext context, int index) {
                    Tasks task = tasksModel.entityList[index];

                    List dateParts;
                    if (task.duedate == null) {
                      dateParts = ["0", "0", "0"];
                    } else {
                      dateParts = task.duedate!.split(",");
                    }
                    DateTime dueDate = DateTime(
                      int.parse(dateParts[0]),
                      int.parse(dateParts[1]),
                      int.parse(dateParts[2]),
                    );
                    String sDueDate =
                        DateFormat.yMMMd("en_US").format(dueDate.toLocal());
                    return _buildCheckbox(task, sDueDate);
                  }),
            ),
          );
        },
      ),
    );
  }
}
