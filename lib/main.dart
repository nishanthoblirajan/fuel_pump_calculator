import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:math';

import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fuel_pump_calculator/Calculations.dart';
import 'package:fuel_pump_calculator/DataClass/SavedData.dart';
import 'package:fuel_pump_calculator/PDFPrint.dart';
import 'package:fuel_pump_calculator/creditCalculation.dart';
import 'package:fuel_pump_calculator/readingCalculation.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:share/share.dart';
import 'package:sqflite/sqflite.dart';

import 'ApplicationConstants.dart';
import 'DataClass/Credit.dart';
import 'DataClass/Extra.dart';
import 'DataClass/Reading.dart';
import 'HexColor.dart';
import 'MenuLayout.dart';
import 'Preferences.dart';
import 'extraCalculation.dart';
import 'package:path/path.dart' as path;

List<Credit> mainCreditList = new List();
List<Extra> mainExtraList = new List();
List<Reading> mainReadingList = new List();
FirebaseAnalytics analytics = FirebaseAnalytics();
Future<Database> database;
bool adFree=false;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  database = openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
      path.join(await getDatabasesPath(), 'saved_data.db'),
  onCreate: (db, version) {
  // Run the CREATE TABLE statement on the database.
  return db.execute(
  "CREATE TABLE SavedData(id INTEGER PRIMARY KEY, time TEXT, credits TEXT, extras TEXT, readings TEXT)",
  );
  },
  // Set the version. This executes the onCreate function and provides a
  // path to perform database upgrades and downgrades.
  version: 1,
  );
  InAppPurchaseConnection.enablePendingPurchases();

  Firebase.initializeApp();
  await SentryFlutter.init(
        (options) {
      options.dsn = 'https://457e5c85f5d34e609418c9665f47f9f9@o420327.ingest.sentry.io/5810637';
    },
    appRunner: () => runApp(GetMaterialApp(
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
        home: MyApp())),
  );

}

class MyApp extends StatefulWidget {

  // List<Reading> readingList;
  // List<Credit> creditList;
  // List<Extra> extraList;
  @override
  _MyAppState createState() => _MyAppState();

  // MyApp({Key key, this.readingList,this.creditList,this.extraList}) : super(key: key);

}

class _MyAppState extends State<MyApp> {
  InAppPurchaseConnection _iap = InAppPurchaseConnection.instance;

  bool _available = true;

  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];

  StreamSubscription _subscription;




  _getPastPurchases() async {
    QueryPurchaseDetailsResponse response = await _iap.queryPastPurchases();
    setState(() {
      _purchases = response.pastPurchases;
      print('purchases are ${_purchases.toString()}');

    });
  }
  _getProducts() async {
    Set<String> ids = Set.from([ApplicationConstants.ad_remove_iap]);
    ProductDetailsResponse response = await _iap.queryProductDetails(ids);
    setState(() {
      _products = response.productDetails;
      print('products are ${_products.toString()}');
    });
  }
  PurchaseDetails _hasPurchased (String productID){
    print('checking hasPurchased $productID');
    return _purchases.firstWhere((element) => element.productID==productID,orElse: ()=> null);
  }

  Future<void> _verifyPurchase() async {
    PurchaseDetails purchase = _hasPurchased(ApplicationConstants.ad_remove_iap);
    if(purchase.billingClientPurchase!=null){
      final pending = !purchase.billingClientPurchase.isAcknowledged;
      if (pending) {
        await _iap.completePurchase(purchase);
      }
      if(purchase!=null&&purchase.status==PurchaseStatus.purchased&&purchase.billingClientPurchase.isAcknowledged){
        print('AdFree purchased');
        Preferences().setAdFree(true);
        adFree=true;
      }else{
        Preferences().setAdFree(false);
        adFree=false;
      }
    }else{
      Fluttertoast.showToast(msg: 'Error');
      Preferences().setAdFree(false);
      adFree=false;
    }

  }

  void _initialize() async {

    _available = await _iap.isAvailable();
    if(_available){
      await _getProducts();
      await _getPastPurchases();
      List<Future> futures = [_getProducts(),_getPastPurchases()];
      await Future.wait(futures);

      _verifyPurchase();

      _subscription = _iap.purchaseUpdatedStream.listen((data){
        setState(() {
          print('NEW PURCHASE');
          _purchases = data;
          _verifyPurchase();
        });
      });

    }
  }
  TextEditingController rateInputController;
  TextEditingController openingReadingController;
  TextEditingController closingReadingController;
  String _selectedProducts = ''; // Option 2

  bool valuesSaved = false;
  bool _isInterstitialAdLoaded = false;

  void _loadInterstitialAd() {

    FacebookInterstitialAd.loadInterstitialAd(
      placementId:
      "2342543822724448_2777582475887245", //"IMG_16_9_APP_INSTALL#2312433698835503_2650502525028617" YOUR_PLACEMENT_ID
      listener: (result, value) {
        print(">> FAN > Interstitial Ad: $result --> $value");
        if (result == InterstitialAdResult.LOADED)
          _isInterstitialAdLoaded = true;

        /// Once an Interstitial Ad has been dismissed and becomes invalidated,
        /// load a fresh Ad by calling this function.
        if (result == InterstitialAdResult.DISMISSED &&
            value["invalidated"] == true) {
          _isInterstitialAdLoaded = false;
          _loadInterstitialAd();
        }
      },
    );
  }
  _showInterstitialAd() {
    if (_isInterstitialAdLoaded == true)
      FacebookInterstitialAd.showInterstitialAd();
    else
      print("Interstial Ad not yet loaded!");
  }
  @override
  void initState() {
    _initialize();
    FacebookAudienceNetwork.init(
      // testingId: "5ac2b819-0f53-4e7d-80ab-c3145ff29a1b", //optional
      // testingId: "aa2aaf1b-a217-40a7-8346-8420995a1349", //optional
      testingId: "55f68f88-90db-4854-80b7-06c0af3eeeca", //optional
      // testingId: "cf58dd5f-bf77-4ff6-a37d-08b25f052e9f", //optional
    );

    _loadInterstitialAd();

    rateInputController = new TextEditingController();
    openingReadingController = new TextEditingController();
    closingReadingController = new TextEditingController();
    rateInputController.text = '';
    openingReadingController.text = '';
    closingReadingController.text = '';

    _selectedProducts = 'MS';
    Preferences().getAdFree().then((string) {
      if (string != null) {
        setState(() {
          adFree = string;
          print('adFree is $adFree');
        });
      }else{
        Preferences().setAdFree(false);
        adFree=false;
      }
    });
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
        Calculations().calculateTotal(mainReadingList, mainExtraList, mainCreditList);
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
    insertSavedData(new SavedData(time:DateFormat("hh:mm:ss dd-MM-yyyy").format(DateTime.now()),credits: jsonEncode(mainCreditList),extras: jsonEncode(mainExtraList),readings:jsonEncode(mainReadingList) ));


    // ignore: unnecessary_statements
    mainReadingList.isNotEmpty
        ? await Preferences().setReadings(jsonEncode(mainReadingList))
        : null;
    mainCreditList.isNotEmpty
        ? await Preferences().setCredits(jsonEncode(mainCreditList))
        : null;
    mainExtraList.isNotEmpty
        ? await Preferences().setExtras(jsonEncode(mainExtraList))
        : null;
    Fluttertoast.showToast(msg: 'Saved');
  }

  retrieveAll() async {
    /*retieve all values*/
    setState(() {
      mainReadingList.clear();
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
          mainReadingList.add(readingObject);
        });
      }).toList();
    } catch (e) {
      print('No Readings saved');
    }

    setState(() {
      mainCreditList.clear();
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
          mainCreditList.add(creditObject);
        });
      }).toList();
    } catch (e) {
      print('No Credit saved');
    }

    setState(() {
      mainExtraList.clear();
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
          mainExtraList.add(extraObject);
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
      drawer: buildDrawer(context),


      appBar: AppBar(
        title: new Text(
          'Pump Calculator',
        ),
        actions: [
          !(mainReadingList.isEmpty && mainExtraList.isEmpty && mainCreditList.isEmpty)?IconButton(icon: Icon(Icons.delete_forever_outlined), onPressed: (){
            if(!adFree){
              _showInterstitialAd();
            }
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
                            mainReadingList.clear();
                            mainExtraList.clear();
                            mainCreditList.clear();
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                });
          }):Container()
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            adFree?Container():Container(
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
                !(mainReadingList.isEmpty && mainExtraList.isEmpty && mainCreditList.isEmpty)
                    ? Tooltip(
                  message: 'Save data',
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.save),
                    onPressed: () async {
                      if(!adFree){
                        _showInterstitialAd();
                      }
                      await saveAll();
                    }, label: Text('Save'),
                  ),
                )
                    : Container(),
                !(mainReadingList.isEmpty && mainExtraList.isEmpty && mainCreditList.isEmpty)
                    ? Tooltip(
                  message: 'Print',
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.print),
                    onPressed: () {

                      // _currentAd=_loadInterstitialAd();
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: adFree?Container():Container(
                                alignment: Alignment(0.5, 1),
                                child: FacebookBannerAd(
                                  placementId: "2342543822724448_2716143442031149",
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
                                  onPressed: ()  {

                                    if(saveAsController.text!=''){
                                      PDFPrint().pdfTotal(mainReadingList, mainCreditList, mainExtraList,saveAsController.text);

                                    }else{
                                      PDFPrint().pdfTotal(mainReadingList, mainCreditList, mainExtraList,'calculations');

                                      // Fluttertoast.showToast(msg: 'Enter valid document name');
                                    }
                                  },
                                ),
                              ],
                            );
                          });

                    }, label: Text('Print'),
                  ),
                )
                    : Container(),
                !(mainReadingList.isEmpty && mainExtraList.isEmpty && mainCreditList.isEmpty)
                    ? Tooltip(
                  message: 'Share',
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.share),
                    onPressed: () {
                      setState(() {
                        Calculations()
                            .share(mainReadingList, mainExtraList, mainCreditList);
                      });
                    }, label: Text('Share'),
                  ),
                )
                    : Container(),


              ],
            ),


            (mainReadingList.isNotEmpty ||
                    mainCreditList.isNotEmpty ||
                    mainExtraList.isNotEmpty)
                ? Center(child: displayTotalAmount())
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      ApplicationConstants.mainTips,
                      style: TextStyle(
                          color: Colors.blueGrey, fontStyle: FontStyle.italic),
                    ),
                  ),

            mainReadingList.isNotEmpty
                ? displayData('Reading',
                    Calculations().calculateReadingTotal(mainReadingList))
                : Text(''),
            mainReadingList.isNotEmpty ? buildReadingList() : Text(''),

            // Expanded(
            //   child: new ListView.builder(
            //       shrinkWrap: true,
            //       scrollDirection: Axis.horizontal,
            //       itemCount: readingList.length,
            //       itemBuilder: (BuildContext context, int index) {
            //         return new Text(readingList[index].toString());
            //       }),
            // ),

            mainCreditList.isNotEmpty
                ? displayData(
                    'Credit', Calculations().calculateCreditTotal(mainCreditList))
                : Text(''),
            mainCreditList.isNotEmpty ? buildCreditList() : Text(''),

            // Expanded(
            //   child: new ListView.builder(
            //       shrinkWrap: true,
            //       scrollDirection: Axis.horizontal,
            //       itemCount: creditList.length,
            //       itemBuilder: (BuildContext context, int index) {
            //         return new Text(creditList[index].toString());
            //       }),
            // )

            mainExtraList.isNotEmpty
                ? displayData(
                    'Extras', Calculations().calculateExtraTotal(mainExtraList))
                : Text(''),
            mainExtraList.isNotEmpty ? buildExpenseList() : Text(''),
            // Expanded(
            //   child: new ListView.builder(
            //       shrinkWrap: true,
            //       scrollDirection: Axis.horizontal,
            //       itemCount: expenseList.length,
            //       itemBuilder: (BuildContext context, int index) {
            //         return new Text(expenseList[index].toString());
            //       }),
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.add),
                  label: Text(
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
                ElevatedButton.icon(
                  label: Text(
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
                  }, icon: Icon(Icons.remove),
                ),
                ElevatedButton.icon(
                  label: Text(
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
                  }, icon: Icon(Icons.miscellaneous_services),
                ),
              ],
            ),
            !(mainReadingList.isEmpty && mainExtraList.isEmpty && mainCreditList.isEmpty)?FacebookNativeAd(
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
            DataColumn(label: Expanded(child: Container(child: Text('Edit')))),
            DataColumn(label: Expanded(child: Container(child: Text('Del')))),
          ],
          rows: List.generate(mainReadingList.length, (index) {
            return DataRow(cells: <DataCell>[
              DataCell(Text(mainReadingList[index].description)),
              DataCell(Text(mainReadingList[index].startingReading.toString())),
              DataCell(Text(mainReadingList[index].endingReading.toString())),
              DataCell(calculateReadingLitreTotal(
                  mainReadingList[index].startingReading,
                  mainReadingList[index].endingReading)),
              DataCell(Text(mainReadingList[index].rate.toString())),
              DataCell(calculateReadingTotal(mainReadingList[index].startingReading,
                  mainReadingList[index].endingReading, mainReadingList[index].rate)),
              DataCell(
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    setState(() {
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext buildContext) {
                            return readingCalculation(
                              dialog: true,
                              edit: true,
                              index: index,
                            );
                          });
                    });
                  },
                ),
              ),
              DataCell(
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      mainReadingList.removeAt(index);
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
          rows: List.generate(mainExtraList.length, (index) {
            return DataRow(cells: <DataCell>[
              DataCell(Text(mainExtraList[index].description)),
              DataCell(Text(mainExtraList[index].amount.toString())),
              DataCell(
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      mainExtraList.removeAt(index);
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
            DataColumn(label: Expanded(child: Container(child: Text('Edit')))),
            DataColumn(label: Expanded(child: Container(child: Text('Del')))),
          ],
          rows: List.generate(mainCreditList.length, (index) {
            return DataRow(cells: <DataCell>[
              DataCell(Text(mainCreditList[index].description)),
              DataCell(Text(mainCreditList[index].litre.toString())),
              DataCell(Text(mainCreditList[index].rate.toString())),
              DataCell(calculateCreditTotal(
                  mainCreditList[index].litre, mainCreditList[index].rate)),
              DataCell(
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    setState(() {
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext buildContext) {
                            return creditCalculation(
                              dialog: true,
                              edit: true,
                              index: index,
                            );
                          });                    });
                  },
                ),
              ),
              DataCell(
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      mainCreditList.removeAt(index);
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
