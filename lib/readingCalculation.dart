import 'package:flutter/material.dart';
import 'package:fuel_pump_calculator/Calculations.dart';
import 'package:get/get.dart';

import 'main.dart';

class readingCalculation extends StatefulWidget {
  bool dialog;

  @override
  _readingCalculationState createState() => _readingCalculationState();

  readingCalculation({Key key, this.dialog}) : super(key: key);
}

class _readingCalculationState extends State<readingCalculation> {
  bool dialog = false;

  @override
  void initState() {
    if (widget.dialog != null) {
      dialog = widget.dialog;
    }

    super.initState();
    // descriptionFocus.requestFocus();
  }

  final FocusNode startingReadingFocus = FocusNode();
  final FocusNode endingReadingFocus = FocusNode();
  final FocusNode rateFocus = FocusNode();
  final FocusNode descriptionFocus = FocusNode();
  final FocusNode calculateFocus = FocusNode();
  @override
  void dispose() {
    super.dispose();
  }

//  Navigator.of(context).push(new MaterialPageRoute(
//  builder: (context) => readingCalculation()));
  @override
  Widget build(BuildContext context) {
    return dialog
        ? alertDialog(context)
        : Scaffold(
            appBar: AppBar(
              title: Text('Reading'),
            ),
            body: content(context));
  }

  TextEditingController startingReadingController = new TextEditingController();
  TextEditingController endingReadingController = new TextEditingController();
  TextEditingController rateController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();
  fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }


  num total = 0;
  Widget content(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: <Widget>[
            new ListTile(
              title: new TextFormField(
                keyboardType: TextInputType.text,
                focusNode: descriptionFocus,
                // autofocus: true,
                onFieldSubmitted: fieldFocusChange(context,descriptionFocus,startingReadingFocus),
                controller: descriptionController,
                textInputAction: TextInputAction.next,

                decoration: new InputDecoration(
                  labelText: "Description",
                ),
              ),
            ),
            new ListTile(
              title: new TextFormField(
                focusNode: startingReadingFocus,
                onFieldSubmitted: fieldFocusChange(context,startingReadingFocus,endingReadingFocus),

                keyboardType: TextInputType.numberWithOptions(),
                controller: startingReadingController,
                textInputAction: TextInputAction.next,

                decoration: new InputDecoration(
                  labelText: "Starting Reading",
                ),
              ),
            ),
            new ListTile(
              title: new TextFormField(
                focusNode: endingReadingFocus,
                onFieldSubmitted: fieldFocusChange(context,endingReadingFocus,rateFocus),

                keyboardType: TextInputType.numberWithOptions(),
                controller: endingReadingController,
                textInputAction: TextInputAction.next,

                decoration: new InputDecoration(
                  labelText: "Ending Reading",
                ),
              ),
            ),
            new ListTile(
              title: new TextFormField(
                onFieldSubmitted: fieldFocusChange(context,rateFocus,calculateFocus),

                focusNode: rateFocus,
                keyboardType: TextInputType.numberWithOptions(),
                controller: rateController,
                textInputAction: TextInputAction.next,

                decoration: new InputDecoration(
                  labelText: "Rate",
                ),
              ),
            ),

            RaisedButton(

              focusNode: calculateFocus,
              child: Text(
                'Add',
              ),
              onPressed: () {
                setState(() {
                  total = Calculations().readingCalculations(
                      descriptionController,
                      startingReadingController,
                      endingReadingController,
                      rateController);
                  Get.back();
                });
              },
            ),
            Text('Total: ${total.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

//  showDialog(
//  context: context,
//  builder: (BuildContext buildContext) {
//  return readingCalculation(dialog: true,);
//  });
  Widget alertDialog(BuildContext context) {
    return new AlertDialog(
      actions: <Widget>[
        FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Close')),
      ],
      title: Text('Reading'),
      content: content(context),
    );
  }
}
