import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""
      CREATE TABLE records(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        shop TEXT,
        date TEXT,
        foodName TEXT NOT NULL,
        price REAL NOT NULL
      )
      """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'db.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  static Future<int> createItem(
      String? shop, String? date, String? foodName, double price) async {
    final db = await SQLHelper.db();
    final data = {
      'shop': shop,
      'date': date,
      'foodName': foodName,
      'price': price
    };
    final id = await db.insert('records', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.query('records', orderBy: "id");
  }

  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SQLHelper.db();
    return db.query('records', where: 'id = ?', whereArgs: [id], limit: 1);
  }

  static Future<int> updateItem(int id, String? shop, String? date,
      String? foodName, double price) async {
    final db = await SQLHelper.db();
    final data = {
      'shop': shop,
      'date': date,
      'foodName': foodName,
      'price': price
    };
    final result =
        await db.update('records', data, where: 'id = ?', whereArgs: [id]);
    return result;
  }

  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete('records', where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Error:$err");
    }
  }
}

class RecordPage extends StatefulWidget {
  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
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

  @override
  void initState() {
    super.initState();
    _refreshJournals();
    print("number of records ${_journals.length}");
  }

  final TextEditingController _recordShop = TextEditingController();
  final TextEditingController _recordDate = TextEditingController();
  final TextEditingController _recordFoodName = TextEditingController();
  final TextEditingController _recordPrice = TextEditingController();

  Future<void> _editItem(int id) async {
    await SQLHelper.updateItem(id, _recordShop.text, _recordDate.text,
        _recordFoodName.text, double.parse(_recordPrice.text));
    _refreshJournals();
  }

  Future<void> _delItem(int id) async {
    await SQLHelper.deleteItem(id);
    _refreshJournals();
  }

  Future<void> _displayTextInputDialog(BuildContext context, int id) async {
    final existingJournal =
        _journals.firstWhere((element) => element['id'] == id);
    _recordShop.text = existingJournal['shop'];
    _recordDate.text = existingJournal['date'];
    _recordFoodName.text = existingJournal['foodName'];
    _recordPrice.text = existingJournal['price'].toString();

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Edit Record'),
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
                  decoration: const InputDecoration(hintText: "FoodName"),
                ),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      valueText = value;
                    });
                  },
                  controller: _recordPrice,
                  decoration: const InputDecoration(hintText: "Price"),
                ),
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
                child: const Text('Edit'),
                onPressed: () async {
                  await _editItem(id);
                  setState(() {
                    Navigator.pop(context);
                    _refreshJournals();
                  });
                },
              ),
            ],
          );
        });
  }

  String? valueText;

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Grocery Record'),
        ),
        body: ListView.builder(
          itemCount: _journals.length,
          itemBuilder: (context, index) => Card(
              margin: const EdgeInsets.all(15),
              child: ListTile(
                  visualDensity: VisualDensity(vertical: 4),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueGrey,
                    child: Text(_journals[index]['id'].toString()),
                  ),
                  title: Text(_journals[index]['shop']),
                  subtitle: Row(
                    children: [
                      Expanded(child: Text(_journals[index]['foodName'])),
                      Expanded(child: Text(_journals[index]['date'])),
                      Expanded(
                          child: Text(_journals[index]['price'].toString()))
                    ],
                  ),
                  trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _displayTextInputDialog(
                                context, _journals[index]['id']),
                            //journals[index]['id']
                          ),
                          IconButton(
                              onPressed: () => _delItem(_journals[index]['id']),
                              icon: const Icon(Icons.delete))
                        ],
                      )))),
        ));
  }
}
