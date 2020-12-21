import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';

import 'DataClass/Expense.dart';
import 'DataClass/Reading.dart';
import 'DataClass/Credit.dart';
import 'package:path_provider/path_provider.dart';

import 'Calculations.dart';

class PDFPrint {
  pdfTotal(List<Reading> readings,List<Credit> credits,List<Expense> expenses) async {
    final Document pdf = Document(deflate: zlib.encode);

    pdf.addPage(MultiPage(
        pageFormat:
        PdfPageFormat.a4.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
        crossAxisAlignment: CrossAxisAlignment.start,
        header: (Context context) {
          return Center(
              child: Text('Calculations'));
        },
        footer: (Context context) {
          return Container(
              alignment: Alignment.centerRight,
              margin: const EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
              child: Text(
                  'Fuel Pump Calculator',
                  style: Theme.of(context)
                      .defaultTextStyle
                      .copyWith(color: PdfColors.grey)));
        },
        build: (Context context) => <Widget>[


          /*Reading Table*/
          readings.isNotEmpty?Header(level: 1,text: 'Reading Calculation'):Text(''),
          readings.isNotEmpty?Table.fromTextArray(
              context: context,
              data: readingListTable(readings)):Text(''),

          readings.isNotEmpty?Text('\nTotal Reading Amount: ${Calculations().calculateReadingTotal(readings).toStringAsFixed(2)}'):Text(''),


          /*Credit Table*/
          credits.isNotEmpty?Header(level: 1,text: 'Credit Calculation'):Text(''),

          credits.isNotEmpty?Table.fromTextArray(
              context: context,
              data: creditListTable(credits)):Text(''),
          credits.isNotEmpty?Text('\nTotal Credit Amount: ${Calculations().calculateCreditTotal(credits).toStringAsFixed(2)}'):Text(''),

          /*Expense Table*/
          expenses.isNotEmpty?Header(level: 1,text: 'Expense Calculation'):Text(''),

          expenses.isNotEmpty?Table.fromTextArray(
              context: context,
              data: expenseListTable(expenses)):Text(''),
          expenses.isNotEmpty?Text('\nTotal Expense Amount: ${Calculations().calculateExpenseTotal(expenses).toStringAsFixed(2)}'):Text(''),

            (readings.isNotEmpty||credits.isNotEmpty||expenses.isNotEmpty)?Header(level: 1,text: 'Total'):Text(''),
          (readings.isNotEmpty||credits.isNotEmpty||expenses.isNotEmpty)?Table.fromTextArray(context: context, data:  <List<String>>[
            <String>['Type', 'Amount'],
            <String>['Reading Sales', '${Calculations().calculateReadingTotal(readings).toStringAsFixed(2)}'],
            <String>['-Credit Sales', '${Calculations().calculateCreditTotal(credits).toStringAsFixed(2)}'],
            <String>['-Expense', '${Calculations().calculateExpenseTotal(expenses).toStringAsFixed(2)}'],
            <String>['Total', '${Calculations().calculateTotal(readings,expenses,credits).toStringAsFixed(2)}'],
          ]):Text('')
        ]));
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
    final file = File("/fuelPumpCalculator.pdf");
    await file.writeAsBytes(pdf.save());
  }


  List<List<String>> readingListTable(
      List<Reading> readingList)  {
    List<List<String>> listString = new List();
    List<String> heading = [
      'S.No',
      'Description',
      'Starting Reading',
      'Ending Reading',
      'Rate',
      'Litres',
      'Amount',
    ];
    listString.add(heading);
    for (int i = 0; i < readingList.length; i++) {
      List<String> strings = [
        (i+1).toString(),
        readingList[i].description,
        readingList[i].startingReading.toString(),
        readingList[i].endingReading.toString(),
        readingList[i].rate.toString(),
        Reading().readingLitre(readingList[i].startingReading, readingList[i].endingReading).toStringAsFixed(2),
        Reading().reading(readingList[i].startingReading, readingList[i].endingReading,readingList[i].rate).toStringAsFixed(2),
      ];
      print(strings.toString());
      listString.add(strings);
    }
    return listString;
  }
  List<List<String>> creditListTable(
      List<Credit> creditList)  {
    List<List<String>> listString = new List();
    List<String> heading = [
      'S.No',

      'Description',
      'Litre',
      'Rate',
      'Amount',
    ];
    listString.add(heading);
    for (int i = 0; i < creditList.length; i++) {
      List<String> strings = [
        (i+1).toString(),
        creditList[i].description,
        creditList[i].litre.toString(),
        creditList[i].rate.toString(),
        Credit().credit(creditList[i].litre, creditList[i].rate).toStringAsFixed(2)
      ];
      print(strings.toString());
      listString.add(strings);
    }
    return listString;
  }

  List<List<String>> expenseListTable(
      List<Expense> expenseList)  {
    List<List<String>> listString = new List();
    List<String> heading = [
      'S.No',

      'Description',
      'Amount',
    ];
    listString.add(heading);
    for (int i = 0; i < expenseList.length; i++) {
      List<String> strings = [
        (i+1).toString(),
        expenseList[i].description,
        expenseList[i].amount.toStringAsFixed(2)
      ];
      print(strings.toString());
      listString.add(strings);
    }
    return listString;
  }
  Future get _localPath async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  Future get _localFile async {
    final path = await _localPath;
    //print('Path is $path/document.pdf');
    return File('$path/document.pdf');
  }

}