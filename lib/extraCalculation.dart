import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'Calculations.dart';
import 'main.dart';

class expenseCalculation extends StatefulWidget {
  bool dialog;

  @override
  _expenseCalculationState createState() => _expenseCalculationState();

  expenseCalculation({Key key, this.dialog}) : super(key: key);
}

class _expenseCalculationState extends State<expenseCalculation> {
  bool dialog = false;

  @override
  void initState() {
    if (widget.dialog != null) {
      dialog = widget.dialog;
    }
    _othersSelected=0;


    super.initState();
  }

  int _othersType = 0;
  int _othersSelected = 0;
  void _handleRadioValueChange1(int value) {
    setState(() {
      _othersType = value;
      switch (_othersType) {
        case 0:
          setState(() {
            _othersSelected = 0;
            title='Income';
          });
          break;
        case 1:
          setState(() {
            _othersSelected = 1;
            title='Expense';

          });
          break;
      }
    });
  }
//  Navigator.of(context).push(new MaterialPageRoute(
//  builder: (context) => expenseCalculation()));

  String title='Income';
  @override
  Widget build(BuildContext context) {
    return dialog
        ? alertDialog(context)
        : Scaffold(
            appBar: AppBar(
              title: Text('Extra'),
            ),
            body: content(context));
  }

  fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  TextEditingController descriptionController = new TextEditingController();
  TextEditingController expenseController = new TextEditingController();
  FocusNode descriptionFocus = FocusNode();
  FocusNode expenseFocus = FocusNode();
  FocusNode buttonFocus = FocusNode();
  num total = 0;
  Widget content(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Column(
            children: [
              new Text(
                title,
                style: new TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                ),
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Radio(
                    value: 0,
                    groupValue: _othersSelected,
                    onChanged: _handleRadioValueChange1,
                  ),
                  new Text(
                    'Income',
                  ),
                  new Radio(
                    value: 1,
                    groupValue: _othersSelected,
                    onChanged: _handleRadioValueChange1,
                  ),
                  new Text(
                    'Expense',
                  ),
                ],
              ),
            ],
          ),
          new ListTile(
            title: new TextFormField(
              onFieldSubmitted:
                  fieldFocusChange(context, descriptionFocus, expenseFocus),
              keyboardType: TextInputType.text,
              focusNode: descriptionFocus,
              textInputAction: TextInputAction.next,
              controller: descriptionController,
              decoration: new InputDecoration(
                labelText: "Description",
              ),
            ),
          ),
          new ListTile(
            title: new TextFormField(
              focusNode: expenseFocus,
              onFieldSubmitted:
                  fieldFocusChange(context, expenseFocus, buttonFocus),
              keyboardType: TextInputType.numberWithOptions(),
              textInputAction: TextInputAction.next,
              controller: expenseController,
              decoration: new InputDecoration(
                labelText: "Amount",
              ),
            ),
          ),
          RaisedButton(
            focusNode: buttonFocus,
            child: Text(
              'Add',
            ),
            onPressed: () {
              setState(() {
                total = Calculations().extraCalculation(
                    descriptionController, expenseController,_othersSelected);
                Get.offAll(MyApp());
              });
            },
          ),
          // Text('Total: ${total.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

//  showDialog(
//  context: context,
//  builder: (BuildContext buildContext) {
//  return expenseCalculation(dialog: true,);
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
      title: Text('Extra'),
      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[content(context)],
        ),
      ),
    );
  }
}
