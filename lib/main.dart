import 'dart:math';

import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:fuel_pump_calculator/creditCalculation.dart';
import 'package:fuel_pump_calculator/readingCalculation.dart';
import 'package:share/share.dart';

import 'DataClass/Credit.dart';
import 'DataClass/Expense.dart';
import 'DataClass/Reading.dart';
import 'expenseCalculation.dart';

List<Credit> creditList = new List();
List<Expense> expenseList = new List();
List<Reading> readingList = new List();
void main() => runApp(MaterialApp(
      home: MyApp(),
      debugShowCheckedModeBanner: false,
      title: 'Pump Calculator',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'OpenSans'),
    ));

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
    FacebookAudienceNetwork.init(
      testingId: "6ee3cda2-63d3-4ba1-ad4b-06fc346f7d5e",
    );
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

  num reading(num starting,num ending,num rate){
    return (ending-starting)*rate;
  }

  num credit(num litre,num rate){
    return litre*rate;
  }
  Widget calculateReadingTotal(num starting, num ending, num rate) {
    return Text(((ending - starting) * rate).toStringAsFixed(2));
  }

  Widget calculateCreditTotal(num litre, num rate) {
    return Text((litre * rate).toStringAsFixed(2));
  }


  Widget displayTotalAmount(){
    num totalToDisplay = 0;
    for(var r in readingList){
      totalToDisplay+=reading(r.startingReading, r.endingReading,r.rate);
    }

    for(var c in creditList){
      totalToDisplay-=credit(c.litre,c.rate);
    }

    for(var e in expenseList){
      totalToDisplay-=e.amount;
    }
    return Text('${totalToDisplay.toStringAsFixed(2)}');
  }

  @override
  Widget build(BuildContext context) {
    FocusNode rateFocus = FocusNode();
    FocusNode openingReadingFocus = FocusNode();
    FocusNode closingReadingFocus = FocusNode();

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        centerTitle: true,
        title: new Text(
          'Pump Calculator',
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
          !(readingList.isEmpty && expenseList.isEmpty && creditList.isEmpty)
              ? IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      readingList.clear();
                      expenseList.clear();
                      creditList.clear();
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
            RaisedButton(
              child: Text(
                'Add Reading',
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
                'Add Credit Sale',
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
                'Add Expense',
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

            displayTotalAmount(),


            readingList.isNotEmpty ? Text('Reading') : Text(''),
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

            creditList.isNotEmpty ? Text('Credit') : Text(''),
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

            expenseList.isNotEmpty ? Text('Expense') : Text(''),
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
          ],
          rows: List.generate(readingList.length, (index) {
            return DataRow(cells: <DataCell>[
              DataCell(Text(expenseList[index].description)),
              DataCell(Text(expenseList[index].amount.toString())),
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
          ],
          rows: List.generate(readingList.length, (index) {
            return DataRow(cells: <DataCell>[
              DataCell(Text(creditList[index].description)),
              DataCell(Text(creditList[index].litre.toString())),
              DataCell(Text(creditList[index].rate.toString())),
              DataCell(calculateCreditTotal(
                  creditList[index].litre, creditList[index].rate)),
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
