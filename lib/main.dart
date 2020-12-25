import 'dart:convert';
import 'dart:math';

import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
import 'Preferences.dart';
import 'extraCalculation.dart';

List<Credit> creditList = new List();
List<Extra> extraList = new List();
List<Reading> readingList = new List();

FirebaseAnalytics analytics = FirebaseAnalytics();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FacebookAudienceNetwork.init(
    // testingId: "5ac2b819-0f53-4e7d-80ab-c3145ff29a1b", //optional
    testingId: "aa2aaf1b-a217-40a7-8346-8420995a1349", //optional
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
      ),
      home: MyApp()));
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

  bool valuesSaved = false;

  @override
  void initState() {
    rateInputController = new TextEditingController();
    openingReadingController = new TextEditingController();
    closingReadingController = new TextEditingController();
    rateInputController.text = '';
    openingReadingController.text = '';
    closingReadingController.text = '';

    _selectedProducts = 'MS';

    Preferences().getReadings().then((value) {
      if (value != null) {
        setState(() {
          valuesSaved = valuesSaved | true;
        });
      }
    });
    Preferences().getCredits().then((value) {
      if (value != null) {
        setState(() {
          valuesSaved = valuesSaved | true;
        });
      }
    });
    Preferences().getExtras().then((value) {
      if (value != null) {
        setState(() {
          valuesSaved = valuesSaved | true;
        });
      }
    });
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
        Calculations().calculateTotal(readingList, extraList, creditList);
    return Text(
      '${totalToDisplay.toStringAsFixed(2)}',
      style: finalAmountStyle(),
    );
  }

  Widget displayData(String text, num toDisplay) {
    return Container(
      color: Colors.blueGrey,
      width: Get.width,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$text', style: TextStyle(color: Colors.white)),
            Text('${toDisplay.toStringAsFixed(2)}',
                textAlign: TextAlign.right,
                style: TextStyle(color: Colors.white))
          ],
        ),
      ),
    );
  }

  TextStyle finalAmountStyle() {
    return TextStyle(
      fontWeight: FontWeight.w900,
      fontStyle: FontStyle.normal,
      fontSize: 24,
    );
  }

  /*todocompleted save operation*/
  saveAll() async {
    // ignore: unnecessary_statements
    readingList.isNotEmpty
        ? await Preferences().setReadings(jsonEncode(readingList))
        : null;
    creditList.isNotEmpty
        ? await Preferences().setCredits(jsonEncode(creditList))
        : null;
    extraList.isNotEmpty
        ? await Preferences().setExtras(jsonEncode(extraList))
        : null;
    Fluttertoast.showToast(msg: 'Saved');
  }

  retrieveAll() async {
    /*retieve all values*/
    setState(() {
      readingList.clear();
    });
    String readings = await Preferences().getReadings();
    try {
      print('LENGTH IS -------- ${(json.decode(readings) as List).length}');
      (json.decode(readings) as List).map((i) {
        print('i is $i');
        Reading readingObject = Reading.fromJson(jsonDecode(i));
        print('readingObject is ${readingObject.toString()}');
        setState(() {
          print('readingObject is ${readingObject.toString()}');
          readingList.add(readingObject);
        });
      }).toList();
    } catch (e) {
      print('No Readings saved');
    }

    setState(() {
      creditList.clear();
    });
    String credits = await Preferences().getCredits();
    try {
      print('LENGTH IS -------- ${(json.decode(credits) as List).length}');
      (json.decode(credits) as List).map((i) {
        print('i is $i');
        Credit creditObject = Credit.fromJson(jsonDecode(i));
        print('creditObject is ${creditObject.toString()}');
        setState(() {
          print('creditObject is ${creditObject.toString()}');
          creditList.add(creditObject);
        });
      }).toList();
    } catch (e) {
      print('No Credit saved');
    }

    setState(() {
      extraList.clear();
    });
    String extras = await Preferences().getExtras();
    try {
      print('LENGTH IS -------- ${(json.decode(extras) as List).length}');
      (json.decode(extras) as List).map((i) {
        print('i is $i');
        Extra extraObject = Extra.fromJson(jsonDecode(i));
        print('extraObject is ${extraObject.toString()}');
        setState(() {
          print('extraObject is ${extraObject.toString()}');
          extraList.add(extraObject);
        });
      }).toList();
    } catch (e) {
      print('No Credit saved');
    }

    // Fluttertoast.showToast(msg: 'Retrieved');
  }

  TextEditingController saveAsController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
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
          !(readingList.isEmpty && extraList.isEmpty && creditList.isEmpty)
              ? Tooltip(
            message: 'Save data',
            child: IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                saveAll();
                // retrieveAll();
              },
            ),
          )
              : Container(),
          !(readingList.isEmpty && extraList.isEmpty && creditList.isEmpty)
              ? Tooltip(
                  message: 'Print',
                  child: IconButton(
                    icon: Icon(Icons.print),
                    onPressed: () {
                      // _currentAd=_loadInterstitialAd();
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Container(
                                alignment: Alignment(0.5, 1),
                                child: FacebookBannerAd(
                                  placementId: "2342543822724448_2342544912724339",
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
                                    'Cancel',
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                FlatButton(
                                  child: Text(
                                    'Confirm',
                                  ),
                                  onPressed: () {
                                    if(saveAsController.text!=''){
                                      PDFPrint().pdfTotal(readingList, creditList, extraList,saveAsController.text);

                                    }else{
                                      PDFPrint().pdfTotal(readingList, creditList, extraList,'calculations');

                                      // Fluttertoast.showToast(msg: 'Enter valid document name');
                                    }
                                  },
                                ),
                              ],
                            );
                          });

                    },
                  ),
                )
              : Container(),
          !(readingList.isEmpty && extraList.isEmpty && creditList.isEmpty)
              ? Tooltip(
                  message: 'Share',
                  child: IconButton(
                    icon: Icon(Icons.share),
                    onPressed: () {
                      setState(() {
                        Calculations()
                            .share(readingList, extraList, creditList);
                      });
                    },
                  ),
                )
              : Container(),
PopupMenuButton(
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'ret',
                      child: Text('Retrieve'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'del',
                      child: Text('Delete'),
                    ),
                  ],
                  onSelected: (String value) {
                    if (value == 'ret') {
                      retrieveAll();

                    } else if (value == 'del') {
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
                                      extraList.clear();
                                      creditList.clear();
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          });
                    }
                  },
                )
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              alignment: Alignment(0.5, 1),
              child: FacebookBannerAd(
                placementId: "2342543822724448_2342544912724339",
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RaisedButton(
                  child: Text(
                    'Reading',
                  ),
                  onPressed: () {
                    showDialog(
                        barrierDismissible: false,
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
                        barrierDismissible: false,
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
                        barrierDismissible: false,
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

            (readingList.isNotEmpty ||
                    creditList.isNotEmpty ||
                    extraList.isNotEmpty)
                ? Center(child: displayTotalAmount())
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      ApplicationConstants.mainTips,
                      style: TextStyle(
                          color: Colors.blueGrey, fontStyle: FontStyle.italic),
                    ),
                  ),

            readingList.isNotEmpty
                ? displayData('Reading',
                    Calculations().calculateReadingTotal(readingList))
                : Text(''),
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

            creditList.isNotEmpty
                ? displayData(
                    'Credit', Calculations().calculateCreditTotal(creditList))
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

            extraList.isNotEmpty
                ? displayData(
                    'Extras', Calculations().calculateExtraTotal(extraList))
                : Text(''),
            extraList.isNotEmpty ? buildExpenseList() : Text(''),
            // Expanded(
            //   child: new ListView.builder(
            //       shrinkWrap: true,
            //       scrollDirection: Axis.horizontal,
            //       itemCount: expenseList.length,
            //       itemBuilder: (BuildContext context, int index) {
            //         return new Text(expenseList[index].toString());
            //       }),
            // ),
            !(readingList.isEmpty && extraList.isEmpty && creditList.isEmpty)?FacebookNativeAd(
              placementId: "2342543822724448_2716142125364614",
              adType: NativeAdType.NATIVE_BANNER_AD,
              bannerAdSize: NativeBannerAdSize.HEIGHT_100,
              width: double.infinity,
              backgroundColor: Colors.blue,
              titleColor: Colors.white,
              descriptionColor: Colors.white,
              buttonColor: Colors.deepPurple,
              buttonTitleColor: Colors.white,
              buttonBorderColor: Colors.white,
              listener: (result, value) {
                print("Native Ad: $result --> $value");
              },
            ):Container(),
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
          rows: List.generate(extraList.length, (index) {
            return DataRow(cells: <DataCell>[
              DataCell(Text(extraList[index].description)),
              DataCell(Text(extraList[index].amount.toString())),
              DataCell(
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      extraList.removeAt(index);
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
