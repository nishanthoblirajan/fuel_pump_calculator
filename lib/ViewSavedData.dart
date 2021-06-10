import 'dart:convert';

import 'package:facebook_audience_network/ad/ad_banner.dart';
import 'package:flutter/material.dart';
import 'package:fuel_pump_calculator/DataClass/Reading.dart';
import 'package:fuel_pump_calculator/DataClass/SavedData.dart';
import 'package:fuel_pump_calculator/Preferences.dart';
import 'package:fuel_pump_calculator/main.dart';
import 'package:get/get.dart';
import 'Calculations.dart';
import 'DataClass/Credit.dart';
import 'DataClass/Extra.dart';
import 'MenuLayout.dart';
import 'PDFPrint.dart';

class ViewSavedData extends StatefulWidget {
  const ViewSavedData({Key key}) : super(key: key);

  @override
  _ViewSavedDataState createState() => _ViewSavedDataState();
}

class _ViewSavedDataState extends State<ViewSavedData> {

  @override
  void initState() {

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Data'),
        actions: [
          IconButton(icon: Icon(Icons.delete_forever_outlined), onPressed: (){
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Confirm delete?'),
                    content: Text('Delete all data?'),
                    actions: [
                      FlatButton(
                        child: Text(
                          'No',
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      FlatButton(
                        child: Text(
                          'Yes',
                        ),
                        onPressed: () {
                          deleteAll();
                          setState(() {

                          });
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                });
          })
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            adFree?Container():Container(
              alignment: Alignment(0.5, 1),
              child: FacebookBannerAd(
                placementId: "2342543822724448_2839315346380624",
                bannerSize: BannerSize.STANDARD,
                listener: (result, value) {
                  switch (result) {
                    case BannerAdResult.ERROR:
                      print("Error: $value");
                      break;
                    case BannerAdResult.LOADED:
                      print("Loaded: $value");
                      break;
                    case BannerAdResult.CLICKED:
                      print("Clicked: $value");
                      break;
                    case BannerAdResult.LOGGING_IMPRESSION:
                      print("Logging Impression: $value");
                      break;
                  }
                },
              ),
            ),
            viewAllData(context),
          ],
        ),
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
  TextEditingController saveAsController = new TextEditingController();


  showAllSavedData(List<SavedData> savedDataList) {

    /*TODO edit the below list*/
    return Column(
      children: [
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
                    label: Expanded(child: Container(child: Text('Delete')))),
                DataColumn(
                    label: Expanded(child: Container(child: Text('Print')))),
                DataColumn(
                    label: Expanded(child: Container(child: Text('Share')))),
                DataColumn(
                    label: Expanded(child: Container(child: Text('View')))),
              ],
              rows: List.generate(savedDataList.length, (index) {
                  List<Credit> creditList;
                  List<Extra> extraList;
                  List<Reading> readingList;


                  /*todo showing same reading twice*/
                  SavedData savedData = savedDataList[index];
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
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Confirm delete?'),
                                content: Text('Delete this data?'),
                                actions: [
                                  FlatButton(
                                    child: Text(
                                      'No',
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  FlatButton(
                                    child: Text(
                                      'Yes',
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        deleteSavedData(savedData.id);
                                      });
                                      Get.back();
                                    },
                                  ),
                                ],
                              );
                            });

                      },
                    ),
                  ),
                  DataCell(
                    IconButton(
                      icon: Icon(Icons.print),
                      onPressed: () {

                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Print?'),
                                content: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: Column(
                                    children: [

                                      Text('Enter the document name to be saved as. Leave it empty for default name.'),
                                      new TextField(
                                        controller: saveAsController,
                                        textInputAction: TextInputAction.next,
                                        decoration: new InputDecoration(
                                          labelText: "Save as",
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  FlatButton(
                                    child: Text(
                                      'No',
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  FlatButton(
                                    child: Text(
                                      'Yes',
                                    ),
                                    onPressed: () {
                                      if(saveAsController.text!=''){
                                        PDFPrint().pdfTotal(readingList, creditList, extraList,saveAsController.text);
                                        saveAsController.clear();
                                      }else{
                                        PDFPrint().pdfTotal(readingList, creditList, extraList,'calculations');

                                        // Fluttertoast.showToast(msg: 'Enter valid document name');
                                      }

                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              );
                            });

                      },
                    ),
                  ),
                  DataCell(
                    IconButton(
                      icon: Icon(Icons.share),
                      onPressed: () {

                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Confirm share?'),
                                content: Text('Share this data?'),
                                actions: [
                                  FlatButton(
                                    child: Text(
                                      'No',
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  FlatButton(
                                    child: Text(
                                      'Yes',
                                    ),
                                    onPressed: () {
                                      Calculations()
                                          .share(readingList, extraList, creditList);
                                    },
                                  ),
                                ],
                              );
                            });

                      },
                    ),
                  ),
                  DataCell(
                    IconButton(
                      icon: Icon(Icons.remove_red_eye_rounded),
                      onPressed: () {

                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Confirm load?'),
                                content: Text('Load this data?'),
                                actions: [
                                  FlatButton(
                                    child: Text(
                                      'No',
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  FlatButton(
                                    child: Text(
                                      'Yes',
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        mainCreditList=creditList;
                                        mainReadingList=readingList;
                                        mainExtraList=extraList;
                                        Get.to(MyApp());
                                      });
                                    },
                                  ),
                                ],
                              );
                            });

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
