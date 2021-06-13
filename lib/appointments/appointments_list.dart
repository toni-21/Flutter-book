import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import './appointments_model.dart';
import './appointmentsDBworker.dart';

class AppointmentsList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AppointmentsListState();
  }
}

class _AppointmentsListState extends State<AppointmentsList> {
  @override
  void initState() {
    super.initState();
    appointmentsModel.loadApptList();
  }

  @override
  Widget build(BuildContext context) {
    EventList<Event> _markedDateMap = EventList(events: {});
    for (int i = 0; i < appointmentsModel.entityList.length; i++) {
      Appointments appointment = appointmentsModel.entityList[i];
      List dateParts = appointment.apptDate!.split(",");
      DateTime apptDate = DateTime(int.parse(dateParts[0]),
          int.parse(dateParts[1]), int.parse(dateParts[2]));
      _markedDateMap.add(
          apptDate,
          Event(
              date: apptDate,
              icon: Container(
                decoration: BoxDecoration(color: Colors.blue),
              )));
    }

    Future _deleteAppointment(BuildContext context, Appointments appt) {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Delete Appointment"),
              content: Text("Are you sure you want delete ${appt.title}?"),
              actions: <Widget>[
                TextButton(
                    child: Text("Cancel"),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                TextButton(
                  child: Text("Delete"),
                  onPressed: () async {
                    await AppointmentsDBWorker.db.delete(appt.id!);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                        content: Text("Appointment Deleted")));
                    appointmentsModel.loadApptList();
                  },
                )
              ],
            );
          });
    }

    void _editAppointment(
        BuildContext context, Appointments appointment) async {
      appointmentsModel.entityBeingEdited =
          await AppointmentsDBWorker.db.get(appointment.id!);
      if (appointmentsModel.entityBeingEdited.apptDate == null) {
        appointmentsModel.setChosenDate(null);
      } else {
        List dateParts = appointment.apptDate!.split(",");
        DateTime apptDate = DateTime(int.parse(dateParts[0]),
            int.parse(dateParts[1]), int.parse(dateParts[2]));
        appointmentsModel.setChosenDate(
            DateFormat.yMMMd("en_US").format(apptDate.toLocal()));
      }
      if (appointmentsModel.entityBeingEdited.apptTime == null) {
        appointmentsModel.setApptTime(null);
      } else {
        List timeParts = appointment.apptTime!.split(",");
        TimeOfDay apptTime = TimeOfDay(
            hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
        appointmentsModel.setApptTime(apptTime.format(context));
      }
      appointmentsModel.setStackIndex(1);
      Navigator.pop(context);
    }

    void _showAppointments(BuildContext context, DateTime date) async {
      showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return ScopedModel(
                model: appointmentsModel,
                child: ScopedModelDescendant<AppointmentsModel>(builder:
                    (BuildContext context, Widget? child,
                        AppointmentsModel model) {
                  return Scaffold(
                    body: Container(
                      padding: EdgeInsets.all(10.0),
                      child: Column(children: <Widget>[
                        Text(
                          DateFormat.yMMMd("en_US").format(
                            date.toLocal(),
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontSize: 20),
                        ),
                        Divider(),
                        Expanded(
                            child: ListView.builder(
                                itemCount: appointmentsModel.entityList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  Appointments appointment =
                                      appointmentsModel.entityList[index];
                                  if (appointment.apptDate !=
                                      "${date.year},${date.month},${date.day}") {
                                    return Container();
                                  }

                                  String apptTime = "";
                                  if (appointment.apptTime != null) {
                                    List timeParts =
                                        appointment.apptTime!.split(",");
                                    TimeOfDay at = TimeOfDay(
                                        hour: int.parse(timeParts[0]),
                                        minute: int.parse(timeParts[1]));
                                    apptTime = "(${at.format(context)})";
                                  }

                                  return Slidable(
                                    actionPane: SlidableDrawerActionPane(),
                                    actionExtentRatio: .25,
                                    child: Container(
                                      margin: EdgeInsets.all(8.0),
                                      color: Colors.grey.shade300,
                                      child: ListTile(
                                        title: Text(
                                            "${appointment.title} $apptTime"),
                                        subtitle: appointment.description ==
                                                null
                                            ? null
                                            : Text(
                                                "${appointment.description}"),
                                        onTap: () async {
                                          _editAppointment(
                                              context, appointment);
                                        },
                                      ),
                                    ),
                                    secondaryActions: [
                                      IconSlideAction(
                                          color: Colors.red,
                                          caption: "Delete",
                                          icon: Icons.delete,
                                          onTap: () => _deleteAppointment(
                                              context, appointment))
                                    ],
                                  );
                                })),
                      ]),
                    ),
                  );
                }));
          });
    }

    return ScopedModel(
      model: appointmentsModel,
      child: ScopedModelDescendant<AppointmentsModel>(builder:
          (BuildContext context, Widget? child, AppointmentsModel model) {
        return Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                appointmentsModel.entityBeingEdited = Appointments();
                DateTime now = DateTime.now();
                appointmentsModel.entityBeingEdited.apptDate =
                    "${now.year},${now.month},${now.day}";
                appointmentsModel.setChosenDate(
                    DateFormat.yMMMd("en_US").format(now.toLocal()));
                appointmentsModel.setApptTime(null);
                appointmentsModel.setStackIndex(1);
              }),
          body: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0))),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: CalendarCarousel<Event>(
                        thisMonthDayBorderColor: Colors.grey,
                        daysHaveCircularBorder: false,
                        markedDatesMap: _markedDateMap,
                        onDayPressed: (DateTime inDate, List<Event> inEvents) {
                          _showAppointments(context, inDate);
                        },
                      )),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
