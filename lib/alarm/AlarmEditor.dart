import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_and_alarms/alarm/alarm.dart';
import 'package:notes_and_alarms/alarm/alarmTab.dart';

class AlarmEditor extends StatefulWidget {
  final UpdateCallback updateCallback;
  final Alarm alarm;

  AlarmEditor({this.updateCallback, this.alarm});

  @override
  State<StatefulWidget> createState() => _AlarmEditorState();

  static openFor(
      Alarm alarm, BuildContext context, UpdateCallback updateCallback) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (BuildContext context) {
        return AlarmEditor(
          alarm: alarm,
          updateCallback: updateCallback,
        );
      }),
    );
  }
}

class _AlarmEditorState extends State<AlarmEditor> {
  Alarm get alarm => widget.alarm;

  final TextStyle textStyle = TextStyle(
    fontSize: 20,
    fontFamily: 'ZillaSlab',
  );

  TextEditingController titleController = TextEditingController();
  FocusNode titleFocus = FocusNode();

  @override
  void initState() {
    titleController.text = alarm.title;
    titleController.addListener(() {
      if (alarm.title != titleController.text) {
        alarm.title = titleController.text;
        widget.updateCallback(alarm);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit alarm")),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              autofocus: !alarm.hasTitle,
              focusNode: titleFocus,
              controller: titleController,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              maxLines: null,
              textInputAction: TextInputAction.next,
              onSubmitted: (text) {
                titleFocus.unfocus();
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
          Divider(),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      "Repeat",
                      style: this.textStyle,
                    ),
                    ButtonBar(
                      children: <Widget>[
                        RaisedButton(
                          child: Text("Once"),
                          onPressed: () => setState(() {
                            alarm.repeat = Repeat.no;
                          }),
                          color: alarm.repeat == Repeat.no
                              ? Theme.of(context).accentColor
                              : null,
                        ),
                        RaisedButton(
                          child: Text("Weekly"),
                          onPressed: () => setState(() {
                            alarm.repeat = Repeat.week;
                          }),
                          color: alarm.repeat == Repeat.week
                              ? Theme.of(context).accentColor
                              : null,
                        ),
                        RaisedButton(
                          child: Text("Daily"),
                          onPressed: () => setState(() {
                            alarm.repeat = Repeat.day;
                          }),
                          color: alarm.repeat == Repeat.day
                              ? Theme.of(context).accentColor
                              : null,
                        ),
                      ],
                    )
                  ],
                ),
                getTimePicker(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getTimePicker(BuildContext context) {
    if (alarm.repeat == Repeat.no) {
      return getTimePickerOnce(context);
    }
    if (alarm.repeat == Repeat.week) {
      return getTimePickerWeekly(context);
    }
    if (alarm.repeat == Repeat.day) {
      return getTimePickerDaily(context);
    }
    throw "Unknown repeat mode";
  }

  Widget getTimePickerOnce(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              "on",
              style: textStyle,
            ),
            getDayButton(context),
          ],
        ),
        Row(
          children: <Widget>[
            Text(
              "at",
              style: textStyle,
            ),
            getHourButton(context),
          ],
        ),
      ],
    );
  }

  Widget getTimePickerWeekly(BuildContext context) {
    final days = [
      "monday",
      "tuesday",
      "wednesday",
      "thursday",
      "friday",
      "saturday",
      "sunday",
    ];
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              "on   ",
              style: textStyle,
            ),
            DropdownButton<String>(
              value: days[alarm.dateTime.weekday - 1],
              items: days
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ),
                  )
                  .toList(),
              onChanged: (item) => setState(() {
                alarm.setWeekday(item);
                widget.updateCallback(alarm);
              }),
            )
          ],
        ),
        Row(
          children: <Widget>[
            Text(
              "starting ",
              style: textStyle,
            ),
            getDayButton(context),
          ],
        ),
        Row(
          children: <Widget>[
            Text(
              "at",
              style: textStyle,
            ),
            getHourButton(context),
          ],
        ),
      ],
    );
  }

  Widget getTimePickerDaily(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              "starting",
              style: textStyle,
            ),
            getDayButton(context),
          ],
        ),
        Row(
          children: <Widget>[
            Text(
              "at",
              style: textStyle,
            ),
            getHourButton(context),
          ],
        ),
      ],
    );
  }

  FlatButton getDayButton(BuildContext context) {
    return FlatButton(
      child: Text(
        DateFormat.yMd().format(alarm.dateTime),
        style: textStyle.copyWith(
          decoration: TextDecoration.underline,
          decorationStyle: TextDecorationStyle.dashed,
        ),
      ),
      onPressed: () => pickDay(context),
    );
  }

  FlatButton getHourButton(BuildContext context){
    return FlatButton(
      child: Text(
        DateFormat.Hm().format(alarm.dateTime),
        style: textStyle.copyWith(
          decoration: TextDecoration.underline,
          decorationStyle: TextDecorationStyle.dashed,
        ),
      ),
      onPressed: () => pickHour(context),
    );
  }

  void pickDay(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: alarm.dateTime,
      firstDate: alarm.dateTime.isBefore(DateTime.now())
          ? alarm.dateTime
          : DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 5000)),
    );
    if (picked != null && picked != alarm.dateTime) {
      setState(() {
        alarm.setDay(picked.year, picked.month, picked.day);
      });
      widget.updateCallback(alarm);
    }
  }

  void pickHour(BuildContext context) async {
    TimeOfDay time = TimeOfDay.fromDateTime(alarm.dateTime);
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: time,
    );

    if (picked != null && picked != time) {
      setState(() {
        alarm.setHour(picked.hour, picked.minute);
      });
      widget.updateCallback(alarm);
    }
  }
}
