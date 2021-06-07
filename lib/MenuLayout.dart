import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fuel_pump_calculator/DataClass/SavedData.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';

import 'ApplicationConstants.dart';
import 'ads_remove.dart';
import 'main.dart';

Widget buildDrawer(BuildContext context) {

  return Drawer(
    child: ListView(
      children: <Widget>[
        buildHeadingMenu('Menu'),
        Container(
          child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
              title: Text('Remove Ads'),
              leading: Icon(FlutterIcons.ad_faw5s),
              onTap: () {
                Get.to(AdsRemove());
              }),
        ),
        // buildHeadingMenu('${ApplicationConstants.webVersionNumber}'),
        buildHeadingMenu('${ApplicationConstants.copyrightText}'),
      ],
    ),
  );
}

Widget buildMenuItem(BuildContext context, String name, String route) {
  return Container(
    child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
        title: Text(name),
        onTap: () {
          Navigator.pushNamed(context, '/' + route);
        }),
  );
}

Widget buildMenuItemWithout(String name) {
  return Container(
    child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
        title: Text(name),
        onTap: () {}),
  );
}

Widget buildHeadingMenu(String name) {
  return Container(
    child: ListTile(
      title: Text(
        name,
        style: TextStyle(color: Colors.blueGrey, fontSize: 12),
      ),
    ),
  );
}

Future<void> insertSavedData(SavedData savedData) async {
  // Get a reference to the database.
  final Database db = await database;

  // Insert the Dog into the correct table. You might also specify the
  // `conflictAlgorithm` to use in case the same dog is inserted twice.
  //
  // In this case, replace any previous data.
  await db.insert(
    'SavedData',
    savedData.toMap(),
    conflictAlgorithm: ConflictAlgorithm.fail,
  ).then((value) {
    if(value>0){
      Fluttertoast.showToast(msg: 'Saved');
    }
  });
}

Future<void> closeDatabase() async {
  final Database db = await database;
  db.close();


}

Future<List<SavedData>> getAllSavedData() async {
  // Get a reference to the database.
  final Database db = await database;

  // Query the table for all The Dogs.
  final List<Map<String, dynamic>> maps = await db.query('SavedData');

  // Convert the List<Map<String, dynamic> into a List<Dog>.
  return List.generate(maps.length, (i) {
    return SavedData(
        id: maps[i]['id'],
        time: maps[i]['time'],
        credits: maps[i]['credits'],
        extras : maps[i]['extras'],
        readings: maps[i]['readings'],
    );
  });
}
Future<void> deleteSavedData(int id) async {
  // Get a reference to the database.
  final db = await database;

  // Remove the Dog from the Database.
  await db.delete(
    'SavedData',
    // Use a `where` clause to delete a specific dog.
    where: "id = ?",
    // Pass the Dog's id as a whereArg to prevent SQL injection.
    whereArgs: [id],
  );
}

Future<void> updateSavedData(SavedData savedData  ) async {
  // Get a reference to the database.
  final db = await database;

  // Update the given Dog.
  await db.update(
    'SavedData',
    savedData.toMap(),
    // Ensure that the Dog has a matching id.
    where: "id = ?",
    // Pass the Dog's id as a whereArg to prevent SQL injection.
    whereArgs: [savedData.id],
  );
}
