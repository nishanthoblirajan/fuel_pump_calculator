import 'package:flutter/material.dart';

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
    _selectedProducts = 'HSD';
    super.initState();
  }

  Widget estimateButton(){

  }
  @override
  Widget build(BuildContext context) {
    FocusNode rateFocus;
    FocusNode openingReadingFocus;
    FocusNode closingReadingFocus;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pump Calculator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(
          title: new Text('Pump Calculator'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
              child: Column(
            children: <Widget>[
              Container  (
                child: new Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(onPressed: (){
                          setState(() {
                            _selectedProducts='MS';
                          });
                        },
                        child: new Text('MS'),),
                      ),
                      Expanded(
                        child: RaisedButton(onPressed: (){
                          setState(() {
                            _selectedProducts='HSD';
                          });
                        },
                          child: new Text('HSD'),),
                      )
                  ],
                ),
              ),
              Text(_selectedProducts,style: TextStyle(
                fontSize: 20.0,
              ),),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: rateInputController,
                textInputAction: TextInputAction.next,
                focusNode: rateFocus,
                onFieldSubmitted: (term){
                  _fieldFocusChange(context, rateFocus, openingReadingFocus);
                },
                decoration: InputDecoration(labelText: 'Price/Litre'),
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: openingReadingController,
                textInputAction: TextInputAction.next,
                focusNode: openingReadingFocus,
                onFieldSubmitted: (term){
                  _fieldFocusChange(context, openingReadingFocus, closingReadingFocus);
                },
                decoration: InputDecoration(labelText: 'Opening Reading'),
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: closingReadingController,
                textInputAction: TextInputAction.done,
                focusNode: closingReadingFocus,
                onFieldSubmitted: (term){
                  closingReadingFocus.unfocus();
                },

                decoration: InputDecoration(labelText: 'Closing Reading'),
              ),
            ],
          )),
        ),
      ),
    );
  }
  _fieldFocusChange(BuildContext context, FocusNode currentFocus,FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }
}
