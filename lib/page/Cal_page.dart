import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery_calculator/main.dart';
import 'package:grocery_calculator/page/record_page.dart';

class CalPage extends StatefulWidget {
  @override
  _CalPageState createState() => _CalPageState();
}

class _CalPageState extends State<CalPage> {
  var unit = "LB";
  var unit2 = "LB";
  var _value;
  var _value2;
  final valueCon = TextEditingController();
  final unitCon = TextEditingController();
  final valueCon2 = TextEditingController();
  final unitCon2 = TextEditingController();

  List<Map<String, dynamic>> _journals = [];
  bool _isloading = true;
  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
      _isloading = false;
      print("number of item ${_journals.length}");
    });
  }

  final TextEditingController _recordShop = TextEditingController();
  final TextEditingController _recordDate = TextEditingController();
  final TextEditingController _recordFoodName = TextEditingController();

  Future<void> _addItem(double price) async {
    await SQLHelper.createItem(
        _recordShop.text, _recordDate.text, _recordFoodName.text, price);
  }

  Future<void> _displayTextInputDialog(
      BuildContext context, double price) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Save Record'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      valueText = value;
                    });
                  },
                  controller: _recordShop,
                  decoration: const InputDecoration(hintText: "Shop"),
                ),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      valueText = value;
                    });
                  },
                  controller: _recordDate,
                  decoration: const InputDecoration(hintText: "Date"),
                ),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      valueText = value;
                    });
                  },
                  controller: _recordFoodName,
                  decoration: const InputDecoration(hintText: "Food Name"),
                ),
                TextFormField(initialValue: price.toString()),
              ],
            ),
            actions: <Widget>[
              MaterialButton(
                color: Colors.red,
                textColor: Colors.white,
                child: const Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              MaterialButton(
                color: Colors.blue,
                textColor: Colors.white,
                child: const Text('Clear'),
                onPressed: () {
                  setState(() {
                    _recordShop.text = "";
                    _recordFoodName.text = "";
                    _recordDate.text = "";
                  });
                },
              ),
              MaterialButton(
                color: Colors.green,
                textColor: Colors.white,
                child: const Text('Add'),
                onPressed: () async {
                  await _addItem(price);
                  setState(() {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyApp()),
                    ).then((value) => setState(() {}));
                  });
                },
              ),
            ],
          );
        });
  }

  String? codeDialog;
  String? valueText;
  @override
  void initState() {
    super.initState();
    _refreshJournals();
    print("number of records ${_journals.length}");
  }

// Initial Selected Value
  String dropdownvalue = 'LB';
  String dropdownvalue2 = 'LB';
  var final_unit;
  var final_unit2;
// List of items in our dropdown menu
  var items = ["LB", "KG", "G", "L", "ml"];
  var items2 = ["LB", "KG", "G", "L", "ml"];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Grocery Calculator"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Item A"),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: TextField(
                        controller: valueCon,
                        decoration: InputDecoration(
                          labelText: "Enter Price",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                            RegExp(r'(^\d*\.?\d{0,3})'),
                          )
                        ], // Only numbers can be entered
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: unitCon,
                              decoration: InputDecoration(
                                labelText: "Enter Unit",
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'(^\d*\.?\d{0,3})'),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: DropdownButton(
                              alignment: AlignmentDirectional.center,
                              isExpanded: true,
                              // Initial Value
                              value: dropdownvalue,

                              // Down Arrow Icon
                              icon: const Icon(Icons.keyboard_arrow_down),

                              // Array list of items
                              items: items.map((String items) {
                                return DropdownMenuItem(
                                  value: items,
                                  child: Center(
                                    child: Text(items,
                                        textAlign: TextAlign.center),
                                  ),
                                );
                              }).toList(),
                              // After selecting the desired option,it will
                              // change button value to selected value
                              onChanged: (String? newValue) {
                                setState(() {
                                  dropdownvalue = newValue!;
                                  unit = newValue;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              side:
                                  BorderSide(width: 1, color: Colors.black12)),
                          onPressed: () {
                            setState(() {
                              if (unit == "KG") {
                                _value = double.parse(
                                        double.parse(valueCon.text)
                                            .toStringAsFixed(3)) /
                                    double.parse(unitCon.text);
                                final_unit = "KG";
                              } else if (unit == "LB") {
                                _value = double.parse(
                                    (double.parse(valueCon.text) *
                                            2.204622 /
                                            double.parse(unitCon.text))
                                        .toStringAsFixed(3));
                                final_unit = "KG";
                              } else if (unit == "G") {
                                _value = double.parse(
                                    (double.parse(valueCon.text) /
                                            double.parse(unitCon.text) *
                                            1000)
                                        .toStringAsFixed(3));
                                final_unit = "KG";
                              } else if (unit == "L") {
                                _value = double.parse(
                                        double.parse(valueCon.text)
                                            .toStringAsFixed(3)) /
                                    double.parse(unitCon.text);
                                final_unit = "L";
                              } else if (unit == "ml") {
                                _value = double.parse(
                                    (double.parse(valueCon.text) /
                                            double.parse(unitCon.text) *
                                            1000)
                                        .toStringAsFixed(3));
                                final_unit = "L";
                              }
                            });
                          },
                          child: Text('Submit'),
                        ),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                side: BorderSide(
                                    width: 1, color: Colors.black12)),
                            onPressed: () {
                              if (_value != null) {
                                _displayTextInputDialog(context, _value);
                              }
                            },
                            child: Text("Save"))
                      ],
                    ),
                    Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text("\$$_value/$final_unit")),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Item B"),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: TextField(
                        controller: valueCon2,
                        decoration: InputDecoration(
                          labelText: "Enter Price",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                            RegExp(r'(^\d*\.?\d{0,3})'),
                          )
                        ], // Only numbers can be entered
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: unitCon2,
                              decoration: InputDecoration(
                                labelText: "Enter Unit",
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'(^\d*\.?\d{0,3})'),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: DropdownButton(
                              alignment: AlignmentDirectional.center,
                              isExpanded: true,
                              // Initial Value
                              value: dropdownvalue2,

                              // Down Arrow Icon
                              icon: const Icon(Icons.keyboard_arrow_down),

                              // Array list of items
                              items: items2.map((String items2) {
                                return DropdownMenuItem(
                                  value: items2,
                                  child: Center(child: Text(items2)),
                                );
                              }).toList(),
                              // After selecting the desired option,it will
                              // change button value to selected value
                              onChanged: (String? newValue) {
                                setState(() {
                                  dropdownvalue2 = newValue!;
                                  unit2 = newValue;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            side: BorderSide(width: 1, color: Colors.black12)),
                        onPressed: () {
                          setState(() {
                            if (unit2 == "KG") {
                              _value2 = double.parse(
                                      double.parse(valueCon2.text)
                                          .toStringAsFixed(3)) /
                                  double.parse(unitCon2.text);
                              final_unit2 = "KG";
                            } else if (unit2 == "LB") {
                              _value2 = double.parse(
                                  (double.parse(valueCon2.text) *
                                          2.204622 /
                                          double.parse(unitCon2.text))
                                      .toStringAsFixed(3));
                              final_unit2 = "KG";
                            } else if (unit2 == "G") {
                              _value2 = double.parse(
                                  (double.parse(valueCon2.text) /
                                          double.parse(unitCon2.text) *
                                          1000)
                                      .toStringAsFixed(3));
                              final_unit2 = "KG";
                            } else if (unit2 == "L") {
                              _value2 = double.parse(
                                      double.parse(valueCon2.text)
                                          .toStringAsFixed(3)) /
                                  double.parse(unitCon2.text);
                              final_unit2 = "L";
                            } else if (unit2 == "ml") {
                              _value2 = double.parse(
                                  (double.parse(valueCon2.text) /
                                          double.parse(unitCon2.text) *
                                          1000)
                                      .toStringAsFixed(3));
                              final_unit2 = "L";
                            }
                          });
                        },
                        child: Text('Submit'),
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              side:
                                  BorderSide(width: 1, color: Colors.black12)),
                          onPressed: () {
                            if (_value2 != null) {
                              _displayTextInputDialog(context, _value2);
                            }
                          },
                          child: Text("Save")),
                    ]),
                    Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text("\$$_value2/$final_unit2")),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
