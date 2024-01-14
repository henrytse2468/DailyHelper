import 'package:flutter/material.dart';
import 'package:grocery_calculator/database/database_helper.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:flutter_material_pickers/flutter_material_pickers.dart';

String yearLabelText = DateTime.now().year.toString();

class WhRecord extends StatefulWidget {
  @override
  _WhRecordState createState() => _WhRecordState();
}

class _WhRecordState extends State<WhRecord> {
  List<Map<String, dynamic>> _journals = [];
  DateTime today = DateTime.now();
  String monthLabelText = 'Select Month';
  var year;
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Work Hour Record'),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => setState(() {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Select Year"),
                            content: Container(
                              // Need to use container to add size constraint.
                              width: 300,
                              height: 300,
                              child: YearPicker(
                                firstDate: DateTime(DateTime.now().year - 3),
                                lastDate: DateTime(DateTime.now().year + 3),
                                initialDate: DateTime.now(),
                                // save the selected date to _selectedDate DateTime variable.
                                // It's used to set the previous selected date when
                                // re-showing the dialog.
                                selectedDate: today,
                                onChanged: (DateTime dateTime) {
                                  // close the dialog when year is selected.
                                  Navigator.pop(context);
                                  year = dateTime.year;
                                  yearLabelText = dateTime.year.toString();
                                  setState(() {});
                                  // Do something with the dateTime selected.
                                  // Remember that you need to use dateTime.year to get the year
                                },
                              ),
                            ),
                          );
                        },
                      );
                    }),
                    icon: Icon(Icons.edit_calendar),
                    label: Text(yearLabelText),
                  ),
                ),
                Expanded(child: DropdownButtonExample()),
              ],
            ),
            const WHDataTable(),
          ],
        ));
  }
}

class WHDataTable extends StatefulWidget {
  const WHDataTable({super.key});
  @override
  State<WHDataTable> createState() => _WHDataTableState();
}

class _WHDataTableState extends State<WHDataTable> {
  List<Map<String, dynamic>> _journals = [];
  static const int numItems = 31;
  List<bool> selected = List<bool>.generate(numItems, (int index) => false);

  void _refreshJournals(String year, String month) async {
    final data = await TimeDBHelper.getRecordByYearMonth(year, month);
    setState(() {
      _journals = data;
      print(_journals);
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals(yearLabelText, selectedMonth);
  }

  double totalWorkhour(List<Map<String, dynamic>> j) {
    double total = 0;
    for (int i = 0; j.length > i; i++) {
      total = total + j[i]['workTime'];
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height - 290,
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: () =>
                          _refreshJournals(yearLabelText, selectedMonth),
                      icon: Icon(Icons.refresh)),
                  Text('Total Working Hour in this month is ' +
                      totalWorkhour(_journals).toString() +
                      ' hours.'),
                ],
              ),
              Expanded(
                child: Container(
                  height: 500,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      border: TableBorder(
                          top: (BorderSide(width: 1.0, color: Colors.black)),
                          right: (BorderSide(width: 1.0, color: Colors.black)),
                          left: (BorderSide(width: 1.0, color: Colors.black)),
                          bottom: (BorderSide(width: 1.0, color: Colors.black)),
                          verticalInside: BorderSide(
                            width: 1.0,
                            color: Colors.black,
                          )),
                      columnSpacing: 15,
                      columns: const <DataColumn>[
                        DataColumn(
                          label: Expanded(
                              child: Text(
                            'Id',
                            textAlign: TextAlign.center,
                          )),
                        ),
                        DataColumn(
                          label: Expanded(
                              child: Text('Start\nTime',
                                  textAlign: TextAlign.center)),
                        ),
                        DataColumn(
                          label: Expanded(
                              child: Text('Break\nStart',
                                  textAlign: TextAlign.center)),
                        ),
                        DataColumn(
                          label: Expanded(
                              child: Text('Break\nEnd',
                                  textAlign: TextAlign.center)),
                        ),
                        DataColumn(
                          label: Expanded(
                              child: Text('End\nTime',
                                  textAlign: TextAlign.center)),
                        ),
                        DataColumn(
                          label: Expanded(
                              child: Text('Work\nTime',
                                  textAlign: TextAlign.center)),
                        ),
                      ],
                      rows: List<DataRow>.generate(
                        _journals.length,
                        (int index) => DataRow(
                          color: MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                            // All rows will have the same selected color.
                            if (states.contains(MaterialState.selected)) {
                              return Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.08);
                            }
                            // Even rows will have a grey color.
                            if (index.isEven) {
                              return Colors.grey.withOpacity(0.3);
                            }
                            return null; // Use default value for other states and odd rows.
                          }),
                          cells: <DataCell>[
                            DataCell(
                              Center(
                                  child: Text(
                                _journals[index]['id'],
                                textAlign: TextAlign.center,
                              )),
                            ),
                            DataCell(
                              Center(
                                  child: Text(
                                _journals[index]['startTime'],
                                textAlign: TextAlign.center,
                              )),
                            ),
                            DataCell(
                              Center(
                                  child: Text(
                                _journals[index]['breakStart'] ?? "NULL",
                                textAlign: TextAlign.center,
                              )),
                            ),
                            DataCell(
                              Center(
                                  child: Text(
                                _journals[index]['breakEnd'] ?? "NULL",
                                textAlign: TextAlign.center,
                              )),
                            ),
                            DataCell(
                              Center(
                                  child: Text(
                                _journals[index]['endTime'] ?? "NULL",
                                textAlign: TextAlign.center,
                              )),
                            ),
                            DataCell(
                              Center(
                                  child: Text(
                                _journals[index]['workTime'].toString(),
                                textAlign: TextAlign.center,
                              )),
                            ),
                          ],
                          selected: selected[index],
                          onSelectChanged: (bool? value) {
                            setState(() {
                              selected[index] = value!;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ]));
  }
}

const List<String> list = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec'
];
const List<String> monthNum = <String>[
  '1',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
  '10',
  '11',
  '12'
];
String selectedMonth = DateTime.now().month.toString();

class DropdownButtonExample extends StatefulWidget {
  const DropdownButtonExample({super.key});

  @override
  State<DropdownButtonExample> createState() => _DropdownButtonExampleState();
}

class _DropdownButtonExampleState extends State<DropdownButtonExample> {
  String dropdownValue = list[monthNum.indexOf(selectedMonth)];

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      alignment: AlignmentDirectional.center,
      isExpanded: true,
      value: dropdownValue,
      icon: const Icon(Icons.arrow_drop_down_outlined),
      style: const TextStyle(color: Colors.blue),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
          selectedMonth = monthNum[list.indexOf(value)];
          //print(selectedMonth);
        });
      },
      items: list.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Center(child: Text(value, textAlign: TextAlign.center)),
        );
      }).toList(),
    );
  }
}
