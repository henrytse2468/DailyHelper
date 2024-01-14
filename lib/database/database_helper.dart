import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart' as sql;

class TimeDBHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""
      CREATE TABLE workHours(
        id TEXT PRIMARY KEY NOT NULL,
        year TEXT NOT NULL,
        month TEXT NOT NULL,
        date TEXT NOT NULL,
        startTime TEXT NOT NULL,
        breakStart TEXT NULL,
        breakEnd TEXT NULL,
        endTime TEXT NULL,
        workTime REAL NULL
      )
      """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'db.db2',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  static Future<int> createItem(
      String? _id,
      String? year,
      String? month,
      String? date,
      String? startTime,
      String? breakStart,
      String? breakEnd,
      String? endTime,
      double workTime) async {
    final db = await TimeDBHelper.db();
    final data = {
      'id': _id,
      'year': year,
      'month': month,
      'date': date,
      'startTime': startTime,
      'breakStart': breakStart,
      'breakEnd': breakEnd,
      'endTime': endTime,
      'workTime': workTime
    };
    final id = await db.insert('workHours', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getRecords() async {
    final db = await TimeDBHelper.db();
    var maps = db.query('workHours', orderBy: "id");
    print(maps);
    return maps;
  }

  static Future<List<Map<String, dynamic>>> getRecordById(String id) async {
    final db = await TimeDBHelper.db();
    return db.query('workHours', where: 'id = ?', whereArgs: [id], limit: 1);
  }

  static Future<List<Map<String, dynamic>>> getRecordByYearMonth(
      String? year, String? month) async {
    final db = await TimeDBHelper.db();
    var maps = db.query('workHours',
        where: 'year = ? and month = ?',
        whereArgs: [year, month],
        orderBy: "id");
    print(maps);
    return maps;
  }

  static Future<int> updateItem(
      int id,
      String? year,
      String? month,
      String? date,
      String? startTime,
      String? breakStart,
      String? breakEnd,
      String? endTime,
      double workTime) async {
    final db = await TimeDBHelper.db();
    final data = {
      'year': year,
      'month': month,
      'date': date,
      'startTime': startTime,
      'breakStart': breakStart,
      'breakEnd': breakEnd,
      'endTime': endTime,
      'workTime': workTime
    };
    final result =
        await db.update('workHours', data, where: 'id = ?', whereArgs: [id]);
    return result;
  }

  static Future<int> updateBreakStart(String id, String? breakStart) async {
    final db = await TimeDBHelper.db();
    final data = {
      'breakStart': breakStart,
    };
    final result =
        await db.update('workHours', data, where: 'id = ?', whereArgs: [id]);
    return result;
  }

  static Future<int> updateBreakEnd(String id, String? breakEnd) async {
    final db = await TimeDBHelper.db();
    final data = {
      'breakEnd': breakEnd,
    };
    final result =
        await db.update('workHours', data, where: 'id = ?', whereArgs: [id]);
    return result;
  }

  static Future<int> updateEndTime(
      String id, String? endTime, double workTime) async {
    final db = await TimeDBHelper.db();
    final data = {'endTime': endTime, 'workTime': workTime};
    final result =
        await db.update('workHours', data, where: 'id = ?', whereArgs: [id]);
    return result;
  }

  static Future<void> deleteItem(String id) async {
    final db = await TimeDBHelper.db();
    try {
      await db.delete('workHours', where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Error:$err");
    }
  }
}
