import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:grocery_calculator/main.dart';
import 'package:grocery_calculator/database/database_helper.dart';

class WorkHour extends StatefulWidget {
  _WorkHourState createState() => _WorkHourState();
}

class _WorkHourState extends State<WorkHour> {
  List<Map<String, dynamic>> _journals = [];
  DateTime _date = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _breakStart = TimeOfDay.now();
  TimeOfDay _breakEnd = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();

  Future<void> _addItem() async {
    await TimeDBHelper.createItem(
        _date.year.toString() + _date.month.toString() + _date.day.toString(),
        _date.year.toString(),
        _date.month.toString(),
        _date.day.toString(),
        _startTime.hour.toString() + ':' + _startTime.minute.toString(),
        _breakStart.hour.toString() + ':' + _breakStart.minute.toString(),
        _breakEnd.hour.toString() + ':' + _breakEnd.minute.toString(),
        _endTime.hour.toString() + ':' + _endTime.minute.toString(),
        double.parse(timeWorked(_startTime, _breakStart, _breakEnd, _endTime)
            .toStringAsFixed(3)));
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Message'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[Text('Successfully Added!')],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                setState(() {
                  Navigator.pop(context);
                  setState(() {
                    _date = DateTime.now();
                    _startTime = TimeOfDay.now();
                    _breakStart = TimeOfDay.now();
                    _breakEnd = TimeOfDay.now();
                    _endTime = TimeOfDay.now();
                  });
                  //Navigator.push(
                  //  context,
                  //  MaterialPageRoute(builder: (context) => MyApp()),
                  //).then((value) => setState(() {}));
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _reload() async {
    //TimeDBHelper.deleteItem('2023103');
    final data = await TimeDBHelper.getRecords();
    setState(() {
      _journals = data;
      print(_journals);

      print("number of item in WorkHour ${_journals.length}");
    });
  }

  @override
  void initState() {
    super.initState();
    var db = TimeDBHelper.db();
    //_reload();
    _date = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Work Hour Tracker"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(32),
          child: Column(children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("Date: ${_date.toString().substring(0, 10)}"),
                TextButton(
                  child: Text("Select Date"),
                  onPressed: () {
                    _selectDate(context);
                  },
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(10),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("Start time: ${formatHourMinutes(_startTime)}"),
                TextButton(
                  child: Text("Select start time"),
                  onPressed: () {
                    _selectStartTime(context);
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("Break Start: ${formatHourMinutes(_breakStart)}"),
                TextButton(
                  child: Text("Select Break Start"),
                  onPressed: () {
                    _selectBreakStart(context);
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("Break End: ${formatHourMinutes(_breakEnd)}"),
                TextButton(
                  child: Text("Select Break End"),
                  onPressed: () {
                    _selectBreakEnd(context);
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("End time: ${formatHourMinutes(_endTime)}"),
                TextButton(
                  child: Text("Select end time"),
                  onPressed: () {
                    _selectEndTime(context);
                  },
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(10),
            ),
            Text("Total duration: " +
                timeWorked(_startTime, _breakStart, _breakEnd, _endTime)
                    .toString()),
            TextButton(
                child: Text("SAVE"),
                onPressed: () async {
                  await _addItem();
                  _showMyDialog();
                })
          ]),
        ),
      ),
    );
  }

  double timeWorked(TimeOfDay st, TimeOfDay bs, TimeOfDay be, TimeOfDay et) {
    double startTime = st.hour + st.minute / 60;
    double breakStart = bs.hour + bs.minute / 60;
    double breakEnd = be.hour + be.minute / 60;
    double endTime = et.hour + et.minute / 60;
    double duration = (breakStart - startTime) + (endTime - breakEnd);
    //((breakStart - startTime) + (endTime - breakEnd)) / 60;
    return duration;
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: new DateTime(_date.year - 3),
      lastDate: new DateTime(_date.year + 3),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
      });
    }
  }

  Future<Null> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<Null> _selectBreakStart(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _breakStart,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _breakStart = picked;
      });
    }
  }

  Future<Null> _selectBreakEnd(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _breakEnd,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _breakEnd = picked;
      });
    }
  }

  Future<Null> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  String getDayMonthYear(DateTime date) {
    return date.day.toString() + date.month.toString() + date.year.toString();
  }

  String getDay(DateTime date) {
    return date.day.toString();
  }

  String getMonth(DateTime date) {
    return date.month.toString();
  }

  String getYear(DateTime date) {
    return date.year.toString();
  }

  String formatHourMinutes(TimeOfDay tod) {
    String res = "";
    if (tod.hour < 10) {
      res = "0" + tod.hour.toString();
    } else {
      res = tod.hour.toString();
    }
    res += ":";
    if (tod.minute < 10) {
      res += "0";
      res += tod.minute.toString();
    } else {
      res += tod.minute.toString();
    }
    return res;
  }
}
