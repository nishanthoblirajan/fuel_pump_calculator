import 'package:flutter/material.dart';
import 'package:fuel_pump_calculator/DataClass/Credit.dart';
import 'package:get/get.dart';

import 'Calculations.dart';
import 'main.dart';

class creditCalculation extends StatefulWidget {
  bool dialog;
  bool edit;
  int index;
  @override
  _creditCalculationState createState() => _creditCalculationState();

  creditCalculation({Key? key, required this.dialog,required this.edit,required this.index}) : super(key: key);
}

final _formKey = GlobalKey<FormState>(); // <-

class _creditCalculationState extends State<creditCalculation> {
  bool dialog = false;
  bool edit = false;
  int index=-1;

  late Credit editCredit;
  @override
  void initState() {
    if (widget.dialog != null) {
      dialog = widget.dialog;
    }
    if (widget.edit != null) {
      edit = widget.edit;
    }
    if (widget.index != null) {
      index = widget.index;
    }

    if(edit&&index!=-1){
      editCredit=mainCreditList[index];
      descriptionController.text=editCredit.description;
      litreController.text=editCredit.litre.toString();
      rateController.text=editCredit.rate.toString();
    }

    super.initState();
  }

//  Navigator.of(context).push(new MaterialPageRoute(
//  builder: (context) => creditCalculation()));
  @override
  Widget build(BuildContext context) {
    return dialog
        ? alertDialog(context)
        : Scaffold(
            appBar: AppBar(
              title: Text('Credit'),
            ),
            body: content(context));
  }

  FocusNode descriptionFocus = FocusNode();
  FocusNode litreFocus = FocusNode();
  FocusNode rateFocus = FocusNode();
  FocusNode buttonFocus = FocusNode();

  fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  TextEditingController descriptionController = new TextEditingController();
  TextEditingController litreController = new TextEditingController();
  TextEditingController rateController = new TextEditingController();
  num total = 0;

  Widget content(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          new ListTile(
            title: new TextFormField(
              focusNode: descriptionFocus,
              textInputAction: TextInputAction.next,
              onFieldSubmitted:
                  fieldFocusChange(context, descriptionFocus, litreFocus),
              keyboardType: TextInputType.text,
              controller: descriptionController,
              decoration: new InputDecoration(
                labelText: "Description",
              ),
            ),
          ),
          new ListTile(
            title: new TextFormField(
              focusNode: litreFocus,
              textInputAction: TextInputAction.next,
              onFieldSubmitted:
                  fieldFocusChange(context, litreFocus, rateFocus),
              keyboardType: TextInputType.numberWithOptions(),
              controller: litreController,
              decoration: new InputDecoration(
                labelText: "Litre",
              ),
            ),
          ),
          new ListTile(
            title: new TextFormField(
              focusNode: rateFocus,
              textInputAction: TextInputAction.next,
              onFieldSubmitted:
                  fieldFocusChange(context, rateFocus, buttonFocus),
              keyboardType: TextInputType.numberWithOptions(),
              controller: rateController,
              decoration: new InputDecoration(
                labelText: "Rate",
              ),
            ),
          ),
          RaisedButton(
            focusNode: buttonFocus,
            child: Text(
              edit?'Edit':'Add',
            ),
            onPressed: () {
              setState(() {
                total = edit?Calculations().editCreditCalculation(index,
                    descriptionController, litreController, rateController):Calculations().creditCalculation(
                    descriptionController, litreController, rateController);
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
//  return creditCalculation(dialog: true,);
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
      title: Text('Credit'),
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
