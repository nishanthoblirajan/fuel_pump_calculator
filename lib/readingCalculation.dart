import 'package:facebook_audience_network/ad/ad_banner.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:fuel_pump_calculator/Calculations.dart';
import 'package:get/get.dart';

import 'DataClass/Reading.dart';
import 'Preferences.dart';
import 'main.dart';

class readingCalculation extends StatefulWidget {
  bool dialog;
  bool edit;
  int index;

  @override
  _readingCalculationState createState() => _readingCalculationState();

  readingCalculation({Key key, this.dialog,this.edit,this.index}) : super(key: key);
}

class _readingCalculationState extends State<readingCalculation> {

  bool adFree= false;

  bool dialog = false;

  bool edit = false;
  int index=-1;

  Reading editReading = new Reading();

  @override
  void initState() {
    Preferences().getAdFree().then((string) {
      if (string != null) {
        setState(() {
          adFree = string;
          print('adFree is $adFree');
        });
      }
    });
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
      editReading=mainReadingList[index];
      startingReadingController.text=editReading.startingReading.toString();
      endingReadingController.text=editReading.endingReading.toString();
      descriptionController.text=editReading.description;
      rateController.text=editReading.rate.toString();
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
            // 2342543822724448_2716143078697852
            adFree?Container():Container(
              alignment: Alignment(0.5, 1),
              child: FacebookBannerAd(
                placementId: "2342543822724448_2716143078697852",
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
                edit?'Edit':'Add',
              ),
              onPressed: () {
                setState(() {

                  total = edit?Calculations().editReadingCalculation(
                    index,
                      descriptionController,
                      startingReadingController,
                      endingReadingController,
                      rateController):Calculations().readingCalculations(
                      descriptionController,
                      startingReadingController,
                      endingReadingController,
                      rateController);
                  Get.offAll(MyApp());
                });
              },
            ),
            // Text('Total: ${total.toStringAsFixed(2)}'),
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
