import 'package:notes_and_alarms/Dated.dart';
import 'package:notes_and_alarms/dao.dart';
import 'package:notes_and_alarms/stringUtils.dart';
import 'package:sqflite/sqflite.dart';

class Note implements Dated {
  int id;

  String title;
  String content;
  int date;

  Note({int id, this.title = "", this.content = "", int date}) {
    this.id = id ?? (DateTime.now().millisecondsSinceEpoch/1000).floor();
    this.date = date ?? DateTime.now().millisecondsSinceEpoch;
  }

  bool get hasTitle {
    return title.trim().isNotEmpty;
  }

  String get displayTitle {
    return hasTitle ? formatAndCut(title, 20) : "Untitled";
  }

  bool get hasContent {
    return content.trim().isNotEmpty;
  }

  String get displayContent {
    return hasContent ? formatAndCut(content, 40) : "No content";
  }

  void refreshDate() {
    this.date = DateTime.now().millisecondsSinceEpoch;
  }

  DateTime get dateTime {
    return DateTime.fromMillisecondsSinceEpoch(this.date);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date,
    };
  }

  static Note fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      date: map['date'],
    );
  }

  @override
  bool get isHistory {
    return dateTime.isBefore(DateTime.now().add(Duration(days: -30)));
  }
}

class NoteDao extends Dao<Note> {
  @override
  Future<void> create(Note note) async {
    final Database db = await database;
    await db.insert(
      'note',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<Note>> findAll() async {
    final Database db = await database;
    return (await db.query('note')).map(Note.fromMap).toList();
  }

  @override
  Future<void> update(Note note) async {
    final Database db = await database;
    await db.update(
      'note',
      note.toMap(),
      where: "id=?",
      whereArgs: [note.id],
    );
  }

  @override
  Future<void> delete(Note note) async {
    final Database db = await database;
    await db.delete(
      'note',
      where: "id=?",
      whereArgs: [note.id],
    );
  }
}
