import 'package:flutter/material.dart';
import 'package:notes_and_alarms/note/note.dart';
import 'package:notes_and_alarms/note/noteTab.dart';

class NoteEditor extends StatefulWidget {
  final UpdateCallback updateCallback;
  final Note note;

  NoteEditor({this.updateCallback, this.note});

  @override
  State<StatefulWidget> createState() => _NoteEditorState();

  static openFor(
      Note note, BuildContext context, UpdateCallback updateCallback) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (BuildContext context) {
        return NoteEditor(
          note: note,
          updateCallback: updateCallback,
        );
      }),
    );
  }
}

class _NoteEditorState extends State<NoteEditor> {
  Note get note => widget.note;

  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  FocusNode titleFocus = FocusNode();
  FocusNode contentFocus = FocusNode();

  @override
  void initState() {
    titleController.text = note.title;
    titleController.addListener(() {
      if (note.title != titleController.text) {
        note.title = titleController.text;
        widget.updateCallback(note);
      }
    });
    contentController.text = note.content;
    contentController.addListener(() {
      if (note.content != contentController.text) {
        note.content = contentController.text;
        widget.updateCallback(note);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit note")),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              autofocus: !note.hasTitle,
              focusNode: titleFocus,
              controller: titleController,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              maxLines: null,
              textInputAction: TextInputAction.next,
              onSubmitted: (text) {
                titleFocus.unfocus();
                FocusScope.of(context).requestFocus(contentFocus);
              },
              style: TextStyle(
                fontFamily: 'ZillaSlab',
                fontSize: 32,
              ),
              decoration: InputDecoration.collapsed(
                hintText: 'Enter a title',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 32,
                  fontFamily: 'ZillaSlab',
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              textAlign: TextAlign.start,
              focusNode: contentFocus,
              controller: contentController,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              maxLines: null,
              onSubmitted: (text) {
                contentFocus.unfocus();
              },
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              decoration: InputDecoration.collapsed(
                hintText: 'Start typing...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 18,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
