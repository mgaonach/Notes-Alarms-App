import 'package:flutter/material.dart';
import 'package:notes_and_alarms/Dated.dart';
import 'package:notes_and_alarms/alarm/alarm.dart';
import 'package:notes_and_alarms/alarm/alarmTile.dart';
import 'package:notes_and_alarms/myTab.dart';
import 'package:notes_and_alarms/note/note.dart';
import 'package:notes_and_alarms/note/noteTile.dart';

typedef DeleteNoteCallback(Note deleteElem);
typedef UpdateNoteCallback(Note elem);
typedef DeleteAlarmCallback(Alarm deleteElem);
typedef UpdateAlarmCallback(Alarm elem);

class HistoryTab extends MyTab {
  final icon = Icon(Icons.archive);
  final title = "History";

  final List<Dated> elements;
  final UpdateAlarmCallback updateAlarmCallback;
  final DeleteAlarmCallback deleteAlarmCallback;
  final UpdateNoteCallback updateNoteCallback;
  final DeleteNoteCallback deleteNoteCallback;

  HistoryTab({
    this.elements,
    this.updateAlarmCallback,
    this.deleteAlarmCallback,
    this.updateNoteCallback,
    this.deleteNoteCallback,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: ListTile.divideTiles(
        tiles: buildTiles(this.elements),
        context: context,
      ).toList(),
    );
  }

  List<Widget> buildTiles(List<Dated> elems) {
    return elems.map(
      (elem) {
        if (elem is Alarm) {
          Alarm alarm = elem;
          return AlarmTile(
            alarm: alarm,
            updateCallback: updateAlarmCallback,
            deleteCallback: deleteAlarmCallback,
          );
        }
        if (elem is Note) {
          Note note = elem;
          return NoteTile(
            note: note,
            updateCallback: updateNoteCallback,
            deleteCallback: deleteNoteCallback,
          );
        }
        throw "Unknown elem type";
      },
    ).toList();
  }
}
