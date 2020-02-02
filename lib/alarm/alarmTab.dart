import 'package:flutter/material.dart';
import 'package:notes_and_alarms/alarm/AlarmEditor.dart';
import 'package:notes_and_alarms/alarm/alarm.dart';
import 'package:notes_and_alarms/alarm/alarmTile.dart';
import 'package:notes_and_alarms/myTab.dart';

typedef AddCallback(Alarm newAlarm);
typedef DeleteCallback(Alarm deleteAlarm);
typedef UpdateCallback(Alarm alarm);

class AlarmTab extends MyTab {
  final icon = Icon(Icons.alarm);
  final title = "Alarms";

  final List<Alarm> alarms;
  final AddCallback addCallback;
  final AddCallback deleteCallback;
  final UpdateCallback updateCallback;

  AlarmTab({
    this.alarms,
    this.addCallback,
    this.updateCallback,
    this.deleteCallback,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: ListTile.divideTiles(
        tiles: buildTiles(this.alarms),
        context: context,
      ).toList(),
    );
  }

  List<Widget> buildTiles(List<Alarm> alarms) {
    return alarms
        .map(
          (alarm) => AlarmTile(
            alarm: alarm,
            deleteCallback: deleteCallback,
            updateCallback: updateCallback,
          ),
        )
        .toList();
  }

  @override
  FloatingActionButton getFloatingActionButton(BuildContext context) =>
      FloatingActionButton(
        onPressed: () => createNewAlarm(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      );

  void createNewAlarm(BuildContext context) {
    Alarm newAlarm = Alarm();
    this.addCallback(newAlarm);
    AlarmEditor.openFor(newAlarm, context, updateCallback);
  }
}
