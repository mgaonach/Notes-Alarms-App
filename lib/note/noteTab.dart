import 'package:flutter/material.dart';
import 'package:notes_and_alarms/myTab.dart';
import 'package:notes_and_alarms/note/note.dart';
import 'package:notes_and_alarms/note/noteEditor.dart';
import 'package:notes_and_alarms/note/noteTile.dart';

typedef AddCallback(Note newNote);
typedef DeleteCallback(Note deleteNote);
typedef UpdateCallback(Note note);

class NoteTab extends MyTab {
  final icon = Icon(Icons.note);
  final title = "Notes";

  final List<Note> notes;
  final AddCallback addCallback;
  final AddCallback deleteCallback;
  final UpdateCallback updateCallback;

  NoteTab({
    this.notes,
    this.addCallback,
    this.updateCallback,
    this.deleteCallback,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: ListTile.divideTiles(
        tiles: buildTiles(this.notes),
        context: context,
      ).toList(),
    );
  }

  List<Widget> buildTiles(List<Note> notes) {
    return notes
        .map(
          (note) => NoteTile(
            note: note,
            deleteCallback: deleteCallback,
            updateCallback: updateCallback,
          ),
        )
        .toList();
  }

  @override
  FloatingActionButton getFloatingActionButton(BuildContext context) =>
      FloatingActionButton(
        onPressed: () => createNewNote(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      );

  void createNewNote(BuildContext context) {
    Note newNote = Note();
    this.addCallback(newNote);
    NoteEditor.openFor(newNote, context, updateCallback);
  }
}
