import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fuel_pump_calculator/DataClass/Reading.dart';
import 'package:fuel_pump_calculator/DataClass/SavedData.dart';
import 'Calculations.dart';
import 'DataClass/Credit.dart';
import 'DataClass/Extra.dart';
import 'MenuLayout.dart';

class ViewSavedData extends StatefulWidget {
  const ViewSavedData({Key key}) : super(key: key);

  @override
  _ViewSavedDataState createState() => _ViewSavedDataState();
}

class _ViewSavedDataState extends State<ViewSavedData> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Data'),
      ),
      body: Container(
        child: viewAllData(context),
      ),
    );
  }



  Widget viewAllData(BuildContext context) {
    return Container(
      child: FutureBuilder(
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return new Text('Not Available');
            case ConnectionState.waiting:
              return new Center(child: new CircularProgressIndicator());
            case ConnectionState.active:
              return new Text('');
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: new Text(
                      'No data available',
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ));
              } else {
                List<SavedData> savedDataList = snapshot.data;
                return showAllSavedData(savedDataList);
              }
              break;
            default:
              return Text('No data available');
          }
        },
        future: getAllSavedData(),
      ),
    );
  }


  showAllSavedData(List<SavedData> savedDataList) {

    /*TODO edit the below list*/
    return Column(
      children: [
        // ElevatedButton(
        //   onPressed: () async {
        //     List<List<String>> data = [
        //       [
        //         "Date",
        //         "Credits",
        //         "Extras",
        //         "Readings",
        //       ],
        //     ];
        //     for (var i in savedDataList) {
        //       SavedData savedData = i;
        //       print('here is ' + savedData.toString());
        //       List<Credit> creditList = new List();
        //       (json.decode(savedData.credits) as List).map((i) {
        //         print('i is $i');
        //         Credit credit = Credit.fromJson(jsonDecode(i));
        //         print('credit is ${credit.toString()}');
        //         creditList.add(credit);
        //       }).toList();
        //       List<Extra> extraList = new List();
        //       (json.decode(savedData.extras) as List).map((i) {
        //         print('i is $i');
        //         Extra extra = Extra.fromJson(jsonDecode(i));
        //         print('extra is ${extra.toString()}');
        //         extraList.add(extra);
        //       }).toList();
        //
        //       List<Reading> readingList = new List();
        //       (json.decode(savedData.readings) as List).map((i) {
        //         print('i is $i');
        //         Reading reading = Reading.fromJson(jsonDecode(i));
        //         print('reading is ${reading.toString()}');
        //         readingList.add(reading);
        //       }).toList();
        //
        //     }
        //
        //   },
        //   child: Text('Export the data'),
        // ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
              columns: <DataColumn>[
                DataColumn(
                    label: Expanded(child: Container(child: Text('Date')))),
                DataColumn(
                    label:
                    Expanded(child: Container(child: Text('Readings')))),
                DataColumn(
                    label: Expanded(child: Container(child: Text('Credits')))),
                DataColumn(
                    label: Expanded(child: Container(child: Text('Extras')))),
                DataColumn(
                    label: Expanded(child: Container(child: Text('Del')))),
              ],
              rows: List.generate(savedDataList.length, (index) {
                  List<Credit> creditList;
                  List<Extra> extraList;
                  List<Reading> readingList;


                  /*todo showing same reading twice*/
                for (var i in savedDataList) {
                  SavedData savedData = i;
                  print('here is ' + savedData.toString());
                  creditList = new List();
                  (json.decode(savedData.credits) as List).map((i) {
                    print('i is $i');
                    Credit credit = Credit.fromJson(jsonDecode(i));
                    print('credit is ${credit.toString()}');
                    creditList.add(credit);
                  }).toList();
                  extraList = new List();
                  (json.decode(savedData.extras) as List).map((i) {
                    print('i is $i');
                    Extra extra = Extra.fromJson(jsonDecode(i));
                    print('extra is ${extra.toString()}');
                    extraList.add(extra);
                  }).toList();

                  readingList = new List();
                  (json.decode(savedData.readings) as List).map((i) {
                    print('i is $i');
                    Reading reading = Reading.fromJson(jsonDecode(i));
                    print('reading is ${reading.toString()}');
                    readingList.add(reading);
                  }).toList();

                }
                return DataRow(cells: <DataCell>[
                  //todo change to invoice.invoiceDate

                  DataCell(Text(savedDataList[index].time ?? 'N/A')),
                  DataCell(Text(Calculations().calculateReadingTotal(readingList).toStringAsFixed(2))),
                  DataCell(Text(Calculations().calculateCreditTotal(creditList).toStringAsFixed(2))),
                  DataCell(Text(Calculations().calculateExtraTotal(extraList).toStringAsFixed(2))),
                  DataCell(
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        deleteSavedData(savedDataList[index].id);
                      },
                    ),
                  ),
                ]);
              })),
        ),
      ],
    );
  }
}
