import 'dart:math';

import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:fuel_pump_calculator/Calculations.dart';
import 'package:fuel_pump_calculator/PDFPrint.dart';
import 'package:fuel_pump_calculator/creditCalculation.dart';
import 'package:fuel_pump_calculator/readingCalculation.dart';
import 'package:get/get.dart';
import 'package:share/share.dart';

import 'ApplicationConstants.dart';
import 'DataClass/Credit.dart';
import 'DataClass/Extra.dart';
import 'DataClass/Reading.dart';
import 'HexColor.dart';
import 'extraCalculation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

List<Credit> creditList = new List();
List<Extra> expenseList = new List();
List<Reading> readingList = new List();

FirebaseAnalytics analytics = FirebaseAnalytics();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FacebookAudienceNetwork.init(
    testingId: "2c870386-66ee-4a9f-a9b7-0a0ef7a5bd13", //optional
  );

  Firebase.initializeApp();

  runApp(GetMaterialApp(
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      title: 'Fuel Pump Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: HexColor(ApplicationConstants.mainColor),
        // textTheme: GoogleFonts.loraTextTheme(),
        // primaryTextTheme: TextTheme(
        //   headline6: GoogleFonts.lora(
        //     fontWeight: FontWeight.w600,
        //   ),
        // ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: HexColor(ApplicationConstants.mainColor),

        // primaryTextTheme: TextTheme(
        //   headline6: GoogleFonts.lora(
        //     fontWeight: FontWeight.w600,
        //   ),
        // )

      ),home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController rateInputController;
  TextEditingController openingReadingController;
  TextEditingController closingReadingController;
  String _selectedProducts = ''; // Option 2

  @override
  void initState() {
    rateInputController = new TextEditingController();
    openingReadingController = new TextEditingController();
    closingReadingController = new TextEditingController();
    rateInputController.text = '';
    openingReadingController.text = '';
    closingReadingController.text = '';

    _selectedProducts = 'MS';
    super.initState();
  }

  Widget total = Text('Enter Values to calculate');

  Widget calculateReadingLitreTotal(num starting, num ending) {
    return Text((ending - starting).toStringAsFixed(2));
  }

  Widget calculateReadingTotal(num starting, num ending, num rate) {
    return Text(((ending - starting) * rate).toStringAsFixed(2));
  }

  Widget calculateCreditTotal(num litre, num rate) {
    return Text((litre * rate).toStringAsFixed(2));
  }

  Widget displayTotalAmount() {
    num totalToDisplay = 0;
    totalToDisplay =
        Calculations().calculateTotal(readingList, expenseList, creditList);
    return Text('${totalToDisplay.toStringAsFixed(2)}',style: finalAmountStyle(),);
  }

  Widget displayData(String text,num toDisplay){
    return Container(
    color: Colors.blueGrey,
    width:Get.width,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$text',style:TextStyle(color:Colors.white)),
            Text('${toDisplay.toStringAsFixed(2)}',textAlign: TextAlign.right,style:TextStyle(color:Colors.white))
          ],
        ),
      ),
    );
  }
  TextStyle finalAmountStyle() {
    return TextStyle(fontWeight: FontWeight.w900,
      fontStyle: FontStyle.normal,fontSize: 24,);
  }
  @override
  Widget build(BuildContext context) {


    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          centerTitle: true,
          title: new Text(
            'Pump Calculator',
          ),
          actions: [
            // IconButton(
            //   icon: Icon(Icons.refresh),
            //   onPressed: () {
            //     setState(() {});
            //   },
            // ),
            !(readingList.isEmpty && expenseList.isEmpty && creditList.isEmpty)
                ? IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Confirmation'),
                              content: Text('Clear all data?'),
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
                                      readingList.clear();
                                      expenseList.clear();
                                      creditList.clear();
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          });
                    },
                  )
                : Container(),
            !(readingList.isEmpty && expenseList.isEmpty && creditList.isEmpty)
                ? IconButton(
              icon: Icon(Icons.download_sharp),
              onPressed: () {
                PDFPrint().pdfTotal(readingList, creditList, expenseList);
              },
            )
                : Container(),
            !(readingList.isEmpty && expenseList.isEmpty && creditList.isEmpty)
                ? IconButton(
                    icon: Icon(Icons.share),
                    onPressed: () {
                      setState(() {
                        Calculations()
                            .share(readingList, expenseList, creditList);
                      });
                    },
                  )
                : Container(),
          ],
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Container(
              //   alignment: Alignment(0.5, 1),
              //   child: FacebookBannerAd(
              //     placementId: "2342543822724448_2342544912724339",
              //     bannerSize: BannerSize.STANDARD,
              //     listener: (result, value) {
              //       switch (result) {
              //         case BannerAdResult.ERROR:
              //           print("Error: $value");
              //           break;
              //         case BannerAdResult.LOADED:
              //           print("Loaded: $value");
              //           break;
              //         case BannerAdResult.CLICKED:
              //           print("Clicked: $value");
              //           break;
              //         case BannerAdResult.LOGGING_IMPRESSION:
              //           print("Logging Impression: $value");
              //           break;
              //       }
              //     },
              //   ),
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RaisedButton(
                    child: Text(
                      'Reading',
                    ),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext buildContext) {
                            return readingCalculation(
                              dialog: true,
                            );
                          });
                    },
                  ),
                  RaisedButton(
                    child: Text(
                      'Credit',
                    ),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext buildContext) {
                            return creditCalculation(
                              dialog: true,
                            );
                          });
                    },
                  ),
                  RaisedButton(
                    child: Text(
                      'Extra',
                    ),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext buildContext) {
                            return expenseCalculation(
                              dialog: true,
                            );
                          });
                    },
                  ),
                ],
              ),

              (readingList.isNotEmpty||creditList.isNotEmpty||expenseList.isNotEmpty)?Center(child: displayTotalAmount()):Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(ApplicationConstants.mainTips,style: TextStyle(color: Colors.blueGrey,fontStyle: FontStyle.italic),),
              ),

              readingList.isNotEmpty ? displayData('Reading',  Calculations().calculateReadingTotal(readingList)): Text(''),
              readingList.isNotEmpty ? buildReadingList() : Text(''),

              // Expanded(
              //   child: new ListView.builder(
              //       shrinkWrap: true,
              //       scrollDirection: Axis.horizontal,
              //       itemCount: readingList.length,
              //       itemBuilder: (BuildContext context, int index) {
              //         return new Text(readingList[index].toString());
              //       }),
              // ),

              creditList.isNotEmpty ?displayData('Credit',  Calculations().calculateCreditTotal(creditList))
            : Text(''),
              creditList.isNotEmpty ? buildCreditList() : Text(''),

              // Expanded(
              //   child: new ListView.builder(
              //       shrinkWrap: true,
              //       scrollDirection: Axis.horizontal,
              //       itemCount: creditList.length,
              //       itemBuilder: (BuildContext context, int index) {
              //         return new Text(creditList[index].toString());
              //       }),
              // )

              expenseList.isNotEmpty ? displayData('Extras',  Calculations().calculateExtraTotal(expenseList)) : Text(''),
              expenseList.isNotEmpty ? buildExpenseList() : Text(''),
              // Expanded(
              //   child: new ListView.builder(
              //       shrinkWrap: true,
              //       scrollDirection: Axis.horizontal,
              //       itemCount: expenseList.length,
              //       itemBuilder: (BuildContext context, int index) {
              //         return new Text(expenseList[index].toString());
              //       }),
              // ),

              /*Old Code */
//           Container(
//             child: Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Container(
//                   child: Column(
//                 children: <Widget>[
//                   Container(
//                     child: new Row(
//                       children: <Widget>[
// //                    2342543822724448_2342544912724339

//                         Expanded(
//                           child: RaisedButton(
//                             onPressed: () {
//                               setState(() {
//                                 _selectedProducts = 'MS';
//                               });
//                             },
//                             child: new Text('MS'),
//                           ),
//                         ),
//                         Expanded(
//                           child: RaisedButton(
//                             onPressed: () {
//                               setState(() {
//                                 _selectedProducts = 'HSD';
//                               });
//                             },
//                             child: new Text('HSD'),
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                   Text(
//                     _selectedProducts,
//                     style: TextStyle(
//                       fontSize: 20.0,
//                     ),
//                   ),
//                   TextFormField(
//                     keyboardType: TextInputType.number,
//                     controller: rateInputController,
//                     textInputAction: TextInputAction.next,
//                     focusNode: rateFocus,
//                     onFieldSubmitted: (term) {
//                       _fieldFocusChange(
//                           context, rateFocus, openingReadingFocus);
//                     },
//                     decoration: InputDecoration(labelText: 'Price/Litre'),
//                   ),
//                   TextFormField(
//                     keyboardType: TextInputType.number,
//                     controller: openingReadingController,
//                     textInputAction: TextInputAction.next,
//                     focusNode: openingReadingFocus,
//                     onFieldSubmitted: (term) {
//                       _fieldFocusChange(
//                           context, openingReadingFocus, closingReadingFocus);
//                     },
//                     decoration: InputDecoration(labelText: 'Opening Reading'),
//                   ),
//                   TextFormField(
//                     keyboardType: TextInputType.number,
//                     controller: closingReadingController,
//                     textInputAction: TextInputAction.done,
//                     focusNode: closingReadingFocus,
//                     onFieldSubmitted: (term) {
//                       closingReadingFocus.unfocus();
//                       calculate();
//                     },
//                     decoration: InputDecoration(labelText: 'Closing Reading'),
//                   ),
//                   new RaisedButton(
//                     onPressed: () {
//                       calculate();
//                     },
//                     child: Text('Calculate'),
//                   ),
//                   total
//                 ],
//               )),
//             ),
//           ),
            ],
          ),
        ),
    );
  }

  SingleChildScrollView buildReadingList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
          columns: <DataColumn>[
            DataColumn(
                label: Expanded(child: Container(child: Text('Description')))),
            DataColumn(
                label: Expanded(child: Container(child: Text('Starting')))),
            DataColumn(
                label: Expanded(child: Container(child: Text('Ending')))),
            DataColumn(
                label: Expanded(child: Container(child: Text('Total Litres')))),
            DataColumn(label: Expanded(child: Container(child: Text('Rate')))),
            DataColumn(
                label: Expanded(child: Container(child: Text('Amount')))),
            DataColumn(label: Expanded(child: Container(child: Text('Del')))),
          ],
          rows: List.generate(readingList.length, (index) {
            return DataRow(cells: <DataCell>[
              DataCell(Text(readingList[index].description)),
              DataCell(Text(readingList[index].startingReading.toString())),
              DataCell(Text(readingList[index].endingReading.toString())),
              DataCell(calculateReadingLitreTotal(
                  readingList[index].startingReading,
                  readingList[index].endingReading)),
              DataCell(Text(readingList[index].rate.toString())),
              DataCell(calculateReadingTotal(readingList[index].startingReading,
                  readingList[index].endingReading, readingList[index].rate)),
              DataCell(
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      readingList.removeAt(index);
                    });
                  },
                ),
              ),
            ]);
          })),
    );
  }

  SingleChildScrollView buildExpenseList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
          columns: <DataColumn>[
            DataColumn(
                label: Expanded(child: Container(child: Text('Description')))),
            DataColumn(
                label: Expanded(child: Container(child: Text('Amount')))),
            DataColumn(label: Expanded(child: Container(child: Text('Del')))),
          ],
          rows: List.generate(expenseList.length, (index) {
            return DataRow(cells: <DataCell>[
              DataCell(Text(expenseList[index].description)),
              DataCell(Text(expenseList[index].amount.toString())),
              DataCell(
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      expenseList.removeAt(index);
                    });
                  },
                ),
              ),
            ]);
          })),
    );
  }

  SingleChildScrollView buildCreditList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
          columns: <DataColumn>[
            DataColumn(
                label: Expanded(child: Container(child: Text('Description')))),
            DataColumn(label: Expanded(child: Container(child: Text('Litre')))),
            DataColumn(label: Expanded(child: Container(child: Text('Rate')))),
            DataColumn(
                label: Expanded(child: Container(child: Text('Amount')))),
            DataColumn(label: Expanded(child: Container(child: Text('Del')))),
          ],
          rows: List.generate(creditList.length, (index) {
            return DataRow(cells: <DataCell>[
              DataCell(Text(creditList[index].description)),
              DataCell(Text(creditList[index].litre.toString())),
              DataCell(Text(creditList[index].rate.toString())),
              DataCell(calculateCreditTotal(
                  creditList[index].litre, creditList[index].rate)),
              DataCell(
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      creditList.removeAt(index);
                    });
                  },
                ),
              ),
            ]);
          })),
    );
  }

  void calculate() {
    if (_selectedProducts != '' &&
        rateInputController.text != '' &&
        openingReadingController.text != '' &&
        closingReadingController.text != '') {
      double productRate = double.parse(rateInputController.text);
      double openingReading = double.parse(openingReadingController.text);
      double closingReading = double.parse(closingReadingController.text);
      double saleInLitres = dp(closingReading - openingReading, 2);
      double saleInRs = dp(saleInLitres * productRate, 2);
      setState(() {
        total = Expanded(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  /*TODO add custom fonts*/
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Product',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Rate',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Sales (in l)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Sales (in Rs)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('$_selectedProducts'),
                      Text('₹ $productRate/litre'),
                      Text('$saleInLitres litres'),
                      Text('₹ $saleInRs'),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () {
                  Share.share('Product - $_selectedProducts\n'
                      'Rate - ₹ $productRate/litre\n'
                      'Opening - $openingReading\n'
                      'Closing - $closingReading\n'
                      'Sales (in l) - $saleInLitres litres\n'
                      'Sales (in Rs) - ₹ $saleInRs');
                },
              )
            ],
          ),
        );
      });
    } else {
      setState(() {
        total = new Text('Error values. Try Again');
      });
    }
  }

  double dp(double val, double places) {
    double mod = pow(10.0, places);
    return ((val * mod).round().toDouble() / mod);
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }
}
