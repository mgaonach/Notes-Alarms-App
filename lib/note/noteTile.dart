import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_and_alarms/note/note.dart';
import 'package:notes_and_alarms/note/noteEditor.dart';
import 'package:notes_and_alarms/note/noteTab.dart';

class NoteTile extends StatelessWidget {
  final Note note;
  final DeleteCallback deleteCallback;
  final UpdateCallback updateCallback;

  NoteTile({this.note, this.deleteCallback, this.updateCallback});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      direction: DismissDirection.endToStart,
      key: ObjectKey(note),
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
        deleteCallback(this.note);
        Scaffold.of(context).showSnackBar(
            SnackBar(content: Text("${this.note.displayTitle} deleted.")));
      },
      child: ListTile(
        title: Text(note.displayTitle),
        subtitle: Text(note.displayContent),
        onTap: () => NoteEditor.openFor(note, context, updateCallback),
        trailing: note.isHistory ? Icon(Icons.note):Text(DateFormat.MMMd().format(note.dateTime)),
      ),
    );
  }
}
