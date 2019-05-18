import 'dart:math';

import 'package:flutter/material.dart';
import 'package:share/share.dart';

void main() => runApp(MyApp());

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
    // TODO: implement initState
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

  @override
  Widget build(BuildContext context) {
    FocusNode rateFocus = FocusNode();
    FocusNode openingReadingFocus = FocusNode();
    FocusNode closingReadingFocus = FocusNode();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pump Calculator',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'OpenSans'),
      home: Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          centerTitle: true,
          title: new Text('Pump Calculator',),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
              child: Column(
            children: <Widget>[
              Container(
                child: new Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        onPressed: () {
                          setState(() {
                            _selectedProducts = 'MS';
                          });
                        },
                        child: new Text('MS'),
                      ),
                    ),
                    Expanded(
                      child: RaisedButton(
                        onPressed: () {
                          setState(() {
                            _selectedProducts = 'HSD';
                          });
                        },
                        child: new Text('HSD'),
                      ),
                    )
                  ],
                ),
              ),
              Text(
                _selectedProducts,
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: rateInputController,
                textInputAction: TextInputAction.next,
                focusNode: rateFocus,
                onFieldSubmitted: (term) {
                  _fieldFocusChange(context, rateFocus, openingReadingFocus);
                },
                decoration: InputDecoration(labelText: 'Price/Litre'),
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: openingReadingController,
                textInputAction: TextInputAction.next,
                focusNode: openingReadingFocus,
                onFieldSubmitted: (term) {
                  _fieldFocusChange(
                      context, openingReadingFocus, closingReadingFocus);
                },
                decoration: InputDecoration(labelText: 'Opening Reading'),
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: closingReadingController,
                textInputAction: TextInputAction.done,
                focusNode: closingReadingFocus,
                onFieldSubmitted: (term) {
                  closingReadingFocus.unfocus();
                  calculate();
                },
                decoration: InputDecoration(labelText: 'Closing Reading'),
              ),
              new RaisedButton(
                onPressed: () {
                  calculate();
                },
                child: Text('Calculate'),
              ),
              total
            ],
          )),
        ),
      ),
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
              IconButton(icon: Icon(Icons.share),onPressed: (){
                Share.share(
                    'Product - $_selectedProducts\n'
                    'Rate - ₹ $productRate/litre\n'
                    'Opening - $openingReading\n'
                    'Closing - $closingReading\n'
                    'Sales (in l) - $saleInLitres litres\n'
                    'Sales (in Rs) - ₹ $saleInRs');

              },)
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
