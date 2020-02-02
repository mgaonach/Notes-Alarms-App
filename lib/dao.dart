import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

abstract class Dao<T> {
  static final List<String> databaseCreationScript = [
    "CREATE TABLE note(id INTEGER PRIMARY KEY, title TEXT, content TEXT, date INTEGER);",
    "CREATE TABLE alarm(id INTEGER PRIMARY KEY, title TEXT, repeat TEXT, date INTEGER, enabled INTEGER);",
    "INSERT INTO note(id,title,content,date) VALUES (1,'My first note','Hello world', ${DateTime.now().add(Duration(days: -5)).millisecondsSinceEpoch})",
    "INSERT INTO note(id,title,content,date) VALUES (2,'My second note','This note is\nmultiline', ${DateTime.now().millisecondsSinceEpoch})",
    "INSERT INTO note(id,title,content,date) VALUES (3,'My old note','This note was created 2 month ago', ${DateTime.now().add(Duration(days: -60)).millisecondsSinceEpoch})",
    "INSERT INTO alarm(id,title,repeat,date,enabled) VALUES (1,'Wake up', 'day', ${DateTime(2020,2,2,6,45).millisecondsSinceEpoch}, 1)",
    "INSERT INTO alarm(id,title,repeat,date,enabled) VALUES (2,'Monday morning', 'week', ${DateTime(2020,2,3,7,30).millisecondsSinceEpoch}, 0)",
    "INSERT INTO alarm(id,title,repeat,date,enabled) VALUES (3,'Ski', 'no', ${DateTime(2020,3,7,8,0).millisecondsSinceEpoch}, 1)",
    "INSERT INTO alarm(id,title,repeat,date,enabled) VALUES (4,'Exam', 'no', ${DateTime(2020,1,15,14,30).millisecondsSinceEpoch}, 1)",
  ];

  final Future<Database> database = getDatabasesPath() //
      .then((path) => join(path, "notes_and_alarms12.db")) //
      .then(
        (path) => openDatabase(
          path,
          onCreate: (db, version) {
            databaseCreationScript.forEach(db.execute);
          },
          version: 1,
        ),
      );

  Future<void> create(T obj);

  Future<List<T>> findAll();

  Future<void> update(T obj);

  Future<void> delete(T obj);
}
