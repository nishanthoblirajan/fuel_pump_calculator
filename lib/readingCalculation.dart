import 'package:flutter/material.dart';
import 'package:fuel_pump_calculator/Calculations.dart';

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

  num total = 0;
  Widget content(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: <Widget>[
            new ListTile(
              title: new TextField(
                keyboardType: TextInputType.text,
                controller: descriptionController,
                decoration: new InputDecoration(
                  labelText: "Description",
                ),
              ),
            ),
            new ListTile(
              title: new TextField(
                keyboardType: TextInputType.numberWithOptions(),
                controller: rateController,
                decoration: new InputDecoration(
                  labelText: "Rate",
                ),
              ),
            ),
            new ListTile(
              title: new TextField(
                keyboardType: TextInputType.numberWithOptions(),
                controller: startingReadingController,
                decoration: new InputDecoration(
                  labelText: "Starting Reading",
                ),
              ),
            ),
            new ListTile(
              title: new TextField(
                keyboardType: TextInputType.numberWithOptions(),
                controller: endingReadingController,
                decoration: new InputDecoration(
                  labelText: "Ending Reading",
                ),
              ),
            ),
            RaisedButton(
              child: Text(
                'Calculate',
              ),
              onPressed: () {
                setState(() {
                  total = Calculations().readingCalculations(
                      descriptionController,
                      startingReadingController,
                      endingReadingController,
                      rateController);
                  Navigator.pop(context);
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
