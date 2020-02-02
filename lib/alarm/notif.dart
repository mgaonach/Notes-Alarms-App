import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notes_and_alarms/alarm/alarm.dart';
import 'package:notes_and_alarms/dao.dart';

class Notif {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

  Dao<Alarm> _dao;

  Notif() {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

    _dao = AlarmDao();
  }

  Future onSelectNotification(String payload) async {
  }

  Future<dynamic> onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    Alarm alarm =
        (await _dao.findAll()).firstWhere((element) => element.id == id);
    if (alarm != null) {
      updateNotif(alarm);
    }
  }

  Future<void> scheduleNotif(Alarm alarm) async {
    DateTime time = alarm.nextOccurrence;
    if (time != null && alarm.enabled) {
      var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'Alarms',
        'Alarms',
        'Notifies you when an alarm is triggered',
        importance: Importance.Max,
        channelAction: AndroidNotificationChannelAction.Update,
      );
      var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
      NotificationDetails platformChannelSpecifics = new NotificationDetails(
          androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.schedule(
          alarm.id, 'Alarm', alarm.title, time, platformChannelSpecifics);
    }
  }

  Future<void> updateNotif(Alarm alarm) async {
    await removeNotif(alarm);
    await scheduleNotif(alarm);
  }

  Future<void> removeNotif(Alarm alarm) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(alarm.id);
    } catch (e) {
      print(e);
    }
  }

  Future<void> initNotifs() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    (await _dao.findAll()).forEach(updateNotif);
  }
}
