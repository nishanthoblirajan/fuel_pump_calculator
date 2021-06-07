import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fuel_pump_calculator/DataClass/SavedData.dart';
import 'DataClass/Credit.dart';
import 'MenuLayout.dart';

class ViewSavedData extends StatefulWidget {
  const ViewSavedData({Key key}) : super(key: key);

  @override
  _ViewSavedDataState createState() => _ViewSavedDataState();
}

class _ViewSavedDataState extends State<ViewSavedData> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Data'),
      ),
      body: Container(
        child: viewAllData(context),
      ),
    );
  }



  Widget viewAllData(BuildContext context) {
    return Container(
      child: FutureBuilder(
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return new Text('Not Available');
            case ConnectionState.waiting:
              return new Center(child: new CircularProgressIndicator());
            case ConnectionState.active:
              return new Text('');
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: new Text(
                      'No data available',
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ));
              } else {
                List<SavedData> savedDataList = snapshot.data;
                return showAllSavedData(savedDataList);
              }
              break;
            default:
              return Text('No data available');
          }
        },
        future: getAllSavedData(),
      ),
    );
  }


  showAllInvoiceList(List<SavedData> savedDataList) {

    /*TODO edit the below list*/
    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            List<List<String>> data = [
              [
                "Date",
                "Credits",
                "Extras",
                "Readings",
              ],
            ];
            for (var i in savedDataList) {
              SavedData savedData = i;
              print('here is ' + savedData.toString());
              List<Credit> creditList = new List();
              (json.decode(savedData.credits) as List).map((i) {
                print('i is $i');
                Credit credit = Credit.fromJson(jsonDecode(i));
                print('credit is ${credit.toString()}');
                creditList.add(credit);
              }).toList();
              final netTotal = creditList
                  .map((item) => BillPrint().calculateWithoutGST(item))
                  .reduce((item1, item2) => item1 + item2);
              final cgstTotal = creditList
                  .map((item) => BillPrint().cgstAmount(item))
                  .reduce((item1, item2) => item1 + item2);
              final sgstTotal = creditList
                  .map((item) => BillPrint().sgstAmount(item))
                  .reduce((item1, item2) => item1 + item2);
              final total = netTotal + cgstTotal + sgstTotal;

              num received = 0;
              try {
                received = num.parse(savedData.receivingAmount.toString());
              } catch (e) {
                print('Amount error $e');
              }

              num discount = 0;
              if (received < total) {
                discount = total - received;
              }
              data.add([
                creditList[0].date,
                savedData.billNumber,
                netTotal.toStringAsFixed(2),
                sgstTotal.toStringAsFixed(2),
                cgstTotal.toStringAsFixed(2),
                total.toStringAsFixed(2),
                discount.toStringAsFixed(2),
                received.toStringAsFixed(2)
              ]);
            }
            String csvData = ListToCsvConverter().convert(data);

            final File file = await _localFile;
            print('writing to file');
            // file.writeAsString(csvData);
            // print('file path is ${file.path}');

            var excel = Excel.createExcel();
            Sheet sheetObject = excel['Sheet1'];
            for(int i=0;i<data.length;i++){
              sheetObject.insertRowIterables(data[i],i);

            }
            excel.encode().then((onValue) {
              print('onValue is ${onValue.toString()}');
              File(file.path)
                ..createSync(recursive: true)
                ..writeAsBytesSync(onValue);
              OpenFile.open("${file.path}");

            });

          },
          child: Text('Export the data'),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
              columns: <DataColumn>[
                DataColumn(
                    label: Expanded(child: Container(child: Text('Date')))),
                DataColumn(
                    label:
                    Expanded(child: Container(child: Text('Invoice No.')))),
                DataColumn(
                    label: Expanded(child: Container(child: Text('Subtotal')))),
                DataColumn(
                    label: Expanded(child: Container(child: Text('CGST')))),
                DataColumn(
                    label: Expanded(child: Container(child: Text('SGST')))),
                DataColumn(
                    label: Expanded(child: Container(child: Text('Total')))),
                DataColumn(
                    label: Expanded(child: Container(child: Text('Discount')))),
                DataColumn(
                    label: Expanded(child: Container(child: Text('Received')))),
                DataColumn(
                    label: Expanded(child: Container(child: Text('Print')))),
                DataColumn(
                    label: Expanded(child: Container(child: Text('Del')))),
              ],
              rows: List.generate(invoices.length, (index) {
                TaxInvoices invoice = invoices[index];
                print('here is ' + invoice.toString());
                List<Selling> sellList = new List();
                (json.decode(invoice.sellingList) as List).map((i) {
                  print('i is $i');
                  Selling sell = Selling.fromJson(jsonDecode(i));
                  print('sell is ${sell.toString()}');
                  sellList.add(sell);
                }).toList();
                final netTotal = sellList
                    .map((item) => BillPrint().calculateWithoutGST(item))
                    .reduce((item1, item2) => item1 + item2);
                final cgstTotal = sellList
                    .map((item) => BillPrint().cgstAmount(item))
                    .reduce((item1, item2) => item1 + item2);
                final sgstTotal = sellList
                    .map((item) => BillPrint().sgstAmount(item))
                    .reduce((item1, item2) => item1 + item2);
                final total = netTotal + cgstTotal + sgstTotal;

                num received = 0;
                try {
                  received = num.parse(invoice.receivingAmount.toString());
                } catch (e) {
                  print('Amount error $e');
                }

                num discount = 0;
                if (received < total) {
                  discount = total - received;
                }

                return DataRow(cells: <DataCell>[
                  //todo change to invoice.invoiceDate

                  DataCell(Text(sellList[0].date ?? 'N/A')),
                  DataCell(Text(invoice.billNumber)),
                  DataCell(Text(netTotal.toStringAsFixed(2))),
                  DataCell(Text(cgstTotal.toStringAsFixed(2))),
                  DataCell(Text(sgstTotal.toStringAsFixed(2))),
                  DataCell(Text(total.toStringAsFixed(2))),
                  DataCell(Text(discount.toStringAsFixed(2))),
                  DataCell(Text(received.toStringAsFixed(2))),
                  DataCell(
                    IconButton(
                      icon: Icon(Icons.print),
                      onPressed: () {
                        //todo change to invoice.invoiceDate
                        PDFPrint().printTaxInvoice(
                            sellList[0].date,
                            jewellersName,
                            jewellersAddress,
                            jewellersGST,
                            sellList,
                            invoice.billNumber,
                            invoice.customerName,
                            invoice.customerAddress,
                            invoice.customerPhone,
                            invoice.receivingAmount ??
                                BillPrint()
                                    .totalSellingList(sellList)
                                    .toStringAsFixed(0));
                      },
                    ),
                  ),

                  DataCell(
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          deleteTaxInvoice(invoice.id);
                        });
                      },
                    ),
                  ),
                ]);
              })),
        ),
      ],
    );
  }
}
