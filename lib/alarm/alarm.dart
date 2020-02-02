import 'package:intl/intl.dart';
import 'package:notes_and_alarms/Dated.dart';
import 'package:notes_and_alarms/dao.dart';
import 'package:notes_and_alarms/stringUtils.dart';
import 'package:sqflite/sqflite.dart';

class Alarm implements Dated {
  int id;
  int date;
  String title;
  Repeat repeat;
  bool enabled;

  Alarm({int id, int date, this.title = "", this.enabled = true, repeat}) {
    this.id = id ?? (DateTime.now().millisecondsSinceEpoch/1000).floor();
    this.repeat = repeat ?? Repeat.no;
    if (date != null) {
      this.date = date;
    } else {
      //Default time is current time rounded to hours + 1 hour
      DateTime now = DateTime.now();
      DateTime time = DateTime(now.year, now.month, now.day, now.hour);
      time = time.add(Duration(hours: 1));
      this.date = time.millisecondsSinceEpoch;
    }
  }

  DateTime get dateTime {
    return DateTime.fromMillisecondsSinceEpoch(this.date);
  }

  bool get hasTitle {
    return title.trim().isNotEmpty;
  }

  String get displayTitle {
    return hasTitle ? formatAndCut(title, 20) : "Untitled";
  }

  String get displayContent {
    if (repeat == Repeat.no) {
      return "${DateFormat.yMMMd().format(dateTime)} at ${DateFormat.Hm().format(dateTime)}";
    }
    if (repeat == Repeat.week) {
      return "Every ${DateFormat.EEEE().format(dateTime)} at ${DateFormat.Hm().format(dateTime)} starting ${DateFormat.yMMMd().format(dateTime)}";
    }
    if (repeat == Repeat.day) {
      return "Every day at ${DateFormat.Hm().format(dateTime)} starting ${DateFormat.yMMMd().format(dateTime)}";
    }
    return "Unknown";
  }

  void setDay(int year, int month, int day) {
    DateTime current = this.dateTime;
    DateTime time = DateTime(year, month, day, current.hour, current.minute);
    this.date = time.millisecondsSinceEpoch;
  }

  void setHour(int hour, int minute) {
    DateTime current = this.dateTime;
    DateTime time =
        DateTime(current.year, current.month, current.day, hour, minute);
    this.date = time.millisecondsSinceEpoch;
  }

  void setWeekday(String weekday) {
    DateTime time = this.dateTime;
    int targetDay = 1;
    switch (weekday) {
      case "monday":
        targetDay = DateTime.monday;
        break;
      case "tuesday":
        targetDay = DateTime.tuesday;
        break;
      case "wednesday":
        targetDay = DateTime.wednesday;
        break;
      case "thursday":
        targetDay = DateTime.thursday;
        break;
      case "friday":
        targetDay = DateTime.friday;
        break;
      case "saturday":
        targetDay = DateTime.saturday;
        break;
      case "sunday":
        targetDay = DateTime.sunday;
        break;
    }
    //Go to next matching day
    while (time.weekday != targetDay) {
      time = time.add(Duration(days: 1));
    }
    this.date = time.millisecondsSinceEpoch;
  }

  @override
  bool get isHistory {
    return repeat == Repeat.no && dateTime.isBefore(DateTime.now());
  }

  DateTime get nextOccurrence {
    if (isHistory) {
      return null;
    }
    if (repeat == Repeat.no || dateTime.isAfter(DateTime.now())) {
      return dateTime;
    } else {
      int interval;
      if (repeat == Repeat.week) {
        interval = 7;
      } else {
        interval = 1;
      }
      DateTime next = dateTime;
      while (next.isBefore(DateTime.now())) {
        next = next.add(Duration(days: interval));
      }
      return next;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'title': title,
      'repeat': repeat.value,
      'enabled': enabled,
    };
  }

  static Alarm fromMap(Map<String, dynamic> map) {
    return Alarm(
      id: map['id'],
      title: map['title'],
      date: map['date'],
      repeat: Repeat.fromString(map['repeat']),
      enabled: map['enabled'] != 0,
    );
  }
}

class Repeat {
  final String value;
  Repeat._(this.value);
  factory Repeat.fromString(String s) {
    if (week.value == s) {
      return week;
    }
    if (day.value == s) {
      return day;
    }
    if (no.value == s) {
      return no;
    }
    throw "Requested repeat value does not exists";
  }
  static final Repeat week = Repeat._("week");
  static final Repeat day = Repeat._("day");
  static final Repeat no = Repeat._("no");
}

class AlarmDao extends Dao<Alarm> {
  @override
  Future<void> create(Alarm alarm) async {
    final Database db = await database;
    await db.insert(
      'alarm',
      alarm.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<Alarm>> findAll() async {
    final Database db = await database;
    return (await db.query('alarm')).map(Alarm.fromMap).toList();
  }

  @override
  Future<void> update(Alarm alarm) async {
    final Database db = await database;
    await db.update(
      'alarm',
      alarm.toMap(),
      where: "id=?",
      whereArgs: [alarm.id],
    );
  }

  @override
  Future<void> delete(Alarm alarm) async {
    final Database db = await database;
    await db.delete(
      'alarm',
      where: "id=?",
      whereArgs: [alarm.id],
    );
  }
}
