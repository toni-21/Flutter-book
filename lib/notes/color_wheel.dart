import 'package:flutter/material.dart';

class ColorWheel extends StatelessWidget {
  final notesModel;
  ColorWheel(
    this.notesModel,
  );

  @override
  Widget build(
    BuildContext context,
  ) {
    return ListTile(
      leading: Icon(Icons.color_lens),
      title: Row(
        children: <Widget>[
          GestureDetector(
            child: Container(
              decoration: ShapeDecoration(
                shape: Border.all(width: 18, color: Colors.red) +
                    Border.all(
                        width: 6,
                        color: notesModel.color == "red"
                            ? Colors.red
                            : Theme.of(context).canvasColor),
              ),
            ),
            onTap: () {
              notesModel.setColor("red");
              notesModel.entityBeingEdited.color = "red";
            },
          ),
          Spacer(),
          GestureDetector(
            child: Container(
              decoration: ShapeDecoration(
                shape: Border.all(width: 18, color: Colors.green) +
                    Border.all(
                        width: 6,
                        color: notesModel.color == "green"
                            ? Colors.green
                            : Theme.of(context).canvasColor),
              ),
            ),
            onTap: () {
              notesModel.entityBeingEdited.color = "green";
              notesModel.setColor("green");
            },
          ),
          Spacer(),
          GestureDetector(
            child: Container(
              decoration: ShapeDecoration(
                shape: Border.all(width: 18, color: Colors.blue) +
                    Border.all(
                        width: 6,
                        color: notesModel.color == "blue"
                            ? Colors.blue
                            : Theme.of(context).canvasColor),
              ),
            ),
            onTap: () {
              notesModel.entityBeingEdited.color = "blue";
              notesModel.setColor("blue");
            },
          ),
          Spacer(),
          GestureDetector(
            child: Container(
              decoration: ShapeDecoration(
                shape: Border.all(width: 18, color: Colors.yellow) +
                    Border.all(
                        width: 6,
                        color: notesModel.color == "yellow"
                            ? Colors.yellow
                            : Theme.of(context).canvasColor),
              ),
            ),
            onTap: () {
              notesModel.entityBeingEdited.color = "yellow";
              notesModel.setColor("yellow");
            },
          ),
          Spacer(),
          GestureDetector(
            child: Container(
              decoration: ShapeDecoration(
                shape: Border.all(width: 18, color: Colors.purpleAccent) +
                    Border.all(
                        width: 6,
                        color: notesModel.color == "purple"
                            ? Colors.purpleAccent
                            : Theme.of(context).canvasColor),
              ),
            ),
            onTap: () {
              notesModel.entityBeingEdited.color = "purple";
              notesModel.setColor("purple");
            },
          ),
          Spacer(),
          GestureDetector(
            child: Container(
              decoration: ShapeDecoration(
                shape: Border.all(width: 18, color: Colors.grey) +
                    Border.all(
                        width: 6,
                        color: notesModel.color == "grey"
                            ? Colors.grey
                            : Theme.of(context).canvasColor),
              ),
            ),
            onTap: () {
              notesModel.entityBeingEdited.color = "grey";
              notesModel.setColor("grey");
            },
          ),
        ],
      ),
    );
  }
}
