import 'package:flutter/material.dart';
import 'package:notes_and_alarms/alarm/AlarmEditor.dart';
import 'package:notes_and_alarms/alarm/alarm.dart';
import 'package:notes_and_alarms/alarm/alarmTab.dart';

class AlarmTile extends StatelessWidget {
  final Alarm alarm;
  final DeleteCallback deleteCallback;
  final UpdateCallback updateCallback;

  AlarmTile({this.alarm, this.deleteCallback, this.updateCallback});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      direction: DismissDirection.endToStart,
      key: ObjectKey(alarm),
      background: Container(
        color: Colors.red,
        child: Icon(
          Icons.delete,
          color: Colors.white,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
      ),
      onDismissed: (direction) {
        deleteCallback(this.alarm);
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text("Alarm deleted.")));
      },
      child: ListTile(
        title: Text(alarm.displayTitle),
        subtitle: Text(alarm.displayContent),
        onTap: () => AlarmEditor.openFor(alarm, context, updateCallback),
        trailing: alarm.isHistory
            ? Icon(Icons.alarm)
            : Switch(
                value: alarm.enabled,
                onChanged: (value) {
                  alarm.enabled = value;
                  updateCallback(alarm);
                },
              ),
      ),
    );
  }
}
