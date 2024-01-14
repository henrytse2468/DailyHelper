import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:grocery_calculator/main.dart';
import 'package:grocery_calculator/database/database_helper.dart';

class AutoWorkHour extends StatefulWidget {
  _AutoWorkHourState createState() => _AutoWorkHourState();
}

class _AutoWorkHourState extends State<AutoWorkHour> {
  String sid = DateTime.now().year.toString() +
      DateTime.now().month.toString() +
      DateTime.now().day.toString();
  DateTime _date = DateTime.now();
  String showText = "null";
  List<Map<String, dynamic>> _journals = [];

  void _reload() async {
    //TimeDBHelper.deleteItem('2023106');
    final data = await TimeDBHelper.getRecordById(
        DateTime.now().year.toString() +
            DateTime.now().month.toString() +
            DateTime.now().day.toString());
    if (data.isEmpty) {
      showText = "Record Start Time";
    } else if (data[0]['breakStart'] == null) {
      showText = "Record Break Start";
      print("success");
    } else if (data[0]['breakEnd'] == null) {
      showText = "Record Break End";
    } else {
      showText = "Record End Time";
    }
    setState(() {
      _journals = data;
    });
  }

  @override
  void initState() {
    super.initState();
    var db = TimeDBHelper.db();
    _reload();
  }

  double convertStringToTOD(String s) {
    List i = s.split(':');
    print(i);
    int hour = int.parse(i[0]);
    int minute = int.parse(i[1]);
    TimeOfDay result = TimeOfDay(hour: hour, minute: minute);
    return result.hour + result.minute / 60;
  }

  double calculateWorkTime(String st, String bs, String be, String et) {
    double startTime = convertStringToTOD(st);
    double breakStart = convertStringToTOD(bs);
    double breakEnd = convertStringToTOD(be);
    double endTime = convertStringToTOD(et);
    double duration = (breakStart - startTime) + (endTime - breakEnd);
    return duration;
  }

  Future<void> _addRecord() async {
    if (_journals.isEmpty) {
      await TimeDBHelper.createItem(
          DateTime.now().year.toString() +
              DateTime.now().month.toString() +
              DateTime.now().day.toString(),
          DateTime.now().year.toString(),
          DateTime.now().month.toString(),
          DateTime.now().day.toString(),
          TimeOfDay.now().hour.toString() +
              ':' +
              TimeOfDay.now().minute.toString(),
          null,
          null,
          null,
          0.0);
    } else if (_journals[0]['breakStart'] == null) {
      await TimeDBHelper.updateBreakStart(
          sid,
          TimeOfDay.now().hour.toString() +
              ':' +
              TimeOfDay.now().minute.toString());
    } else if (_journals[0]['breakEnd'] == null) {
      await TimeDBHelper.updateBreakEnd(
          sid,
          TimeOfDay.now().hour.toString() +
              ':' +
              TimeOfDay.now().minute.toString());
    } else {
      var workTime = calculateWorkTime(
          _journals[0]['startTime'],
          _journals[0]['breakStart'],
          _journals[0]['breakEnd'],
          TimeOfDay.now().hour.toString() +
              ':' +
              TimeOfDay.now().minute.toString());
      workTime = double.parse(workTime.toStringAsFixed(3));

      await TimeDBHelper.updateEndTime(
          sid,
          TimeOfDay.now().hour.toString() +
              ':' +
              TimeOfDay.now().minute.toString(),
          workTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Auto WorkHour"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Date: ' +
                  DateTime.now().year.toString() +
                  '-' +
                  DateTime.now().month.toString() +
                  '-' +
                  DateTime.now().day.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 40),
            ),
            Padding(padding: EdgeInsets.all(16.0)),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    side: BorderSide(width: 1, color: Colors.black12)),
                onPressed: () {
                  _addRecord();
                  setState(() {
                    _reload();
                  });
                },
                child: Text(showText, style: TextStyle(fontSize: 20)))
          ],
        ),
      ),
    );
  }
}
