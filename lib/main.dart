import 'package:flutter/material.dart';
import 'package:notes_and_alarms/Dated.dart';
import 'package:notes_and_alarms/alarm/notif.dart';
import 'package:notes_and_alarms/dao.dart';
import 'package:notes_and_alarms/alarm/alarm.dart';
import 'package:notes_and_alarms/myTab.dart';
import 'package:notes_and_alarms/alarm/alarmTab.dart';
import 'package:notes_and_alarms/history/historyTab.dart';
import 'package:notes_and_alarms/note/note.dart';
import 'package:notes_and_alarms/note/noteTab.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes and alarms',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  final String title = "Notes & alarms";

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  List<Note> notes = [];
  List<Alarm> alarms = [];

  List<MyTab> tabs = [];
  TabController _tabController;

  Dao<Note> _noteDao;
  Dao<Alarm> _alarmDao;

  Notif notif;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _tabController.addListener(_handleTabIndex);
    _noteDao = NoteDao();
    _noteDao.findAll().then((list) {
      setState(() {
        this.notes = list;
        _reorderNotes();
      });
    });
    _alarmDao = AlarmDao();
    _alarmDao.findAll().then((list) {
      setState(() {
        this.alarms = list;
        _reorderAlarms();
      });
    });
    notif = Notif();
    notif.initNotifs();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabIndex);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    tabs = [
      NoteTab(
        notes: notes
            .where(
              (note) => !note.isHistory,
            )
            .toList(),
        deleteCallback: _deleteNote,
        addCallback: _addNote,
        updateCallback: _updateNote,
      ),
      AlarmTab(
        alarms: alarms
            .where(
              (alarm) => !alarm.isHistory,
            )
            .toList(),
        deleteCallback: _deleteAlarm,
        addCallback: _addAlarm,
        updateCallback: _updateAlarm,
      ),
      HistoryTab(
        elements: _getHistoryElements(),
        updateAlarmCallback: _updateAlarm,
        deleteAlarmCallback: _deleteAlarm,
        updateNoteCallback: _updateNote,
        deleteNoteCallback: _deleteNote,
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(currentTab.title),
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs.map((t) => Tab(icon: t.icon)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: tabs,
      ),
      floatingActionButton: currentTab.getFloatingActionButton(context),
    );
  }

  List<Dated> _getHistoryElements() {
    List<Dated> res = [];
    res.addAll(alarms);
    res.addAll(notes);

    res = res.where((element) => element.isHistory).toList();
    res.sort((a, b) => -a.date.compareTo(b.date));

    return res;
  }

  void _updateNote(Note note) {
    setState(() {
      note.refreshDate();
      _noteDao.update(note);
      _reorderNotes();
    });
  }

  void _deleteNote(Note note) {
    setState(() {
      this.notes.remove(note);
      _noteDao.delete(note);
    });
  }

  void _addNote(Note note) {
    setState(() {
      this.notes.insert(0, note);
      _noteDao.create(note);
    });
  }

  void _updateAlarm(Alarm alarm) {
    setState(() {
      _alarmDao.update(alarm);
      _reorderAlarms();
      notif.updateNotif(alarm);
    });
  }

  void _deleteAlarm(Alarm alarm) {
    setState(() {
      this.alarms.remove(alarm);
      _alarmDao.delete(alarm);
      notif.removeNotif(alarm);
    });
  }

  void _addAlarm(Alarm alarm) {
    setState(() {
      this.alarms.insert(0, alarm);
      _alarmDao.create(alarm);
      notif.scheduleNotif(alarm);
    });
  }

  void _handleTabIndex() {
    setState(() {});
  }

  void _reorderNotes() {
    notes.sort((a, b) => -a.date.compareTo(b.date));
  }

  void _reorderAlarms() {
    alarms.sort((a, b) => a.date.compareTo(b.date));
  }

  MyTab get currentTab {
    return tabs[_tabController.index];
  }
}
