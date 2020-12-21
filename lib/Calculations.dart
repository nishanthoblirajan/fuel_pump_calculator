import 'package:flutter/cupertino.dart';
import 'package:fuel_pump_calculator/DataClass/Credit.dart';
import 'package:fuel_pump_calculator/creditCalculation.dart';
import 'package:share/share.dart';

import 'DataClass/Expense.dart';
import 'DataClass/Reading.dart';
import 'main.dart';

class Calculations {
  num reading(num starting, num ending, num rate) {
    return (ending - starting) * rate;
  }

  num credit(num litre, num rate) {
    return litre * rate;
  }

  num calculateReadingTotal(List<Reading> readings){
    num totalToDisplay = 0;
    for (var r in readings) {
      totalToDisplay += reading(r.startingReading, r.endingReading, r.rate);
    }
    return totalToDisplay;
  }

  num calculateExpenseTotal(List<Expense> expenses){
    num totalToDisplay = 0;

    for (var e in expenses) {
      totalToDisplay += e.amount;
    }
    return totalToDisplay;

  }

  num calculateCreditTotal(List<Credit> credits){
    num totalToDisplay = 0;

    for (var c in credits) {
      totalToDisplay += credit(c.litre, c.rate);
    }
    return totalToDisplay;

  }
  
  
  num calculateTotal(List<Reading> readings,List<Expense> expenses,List<Credit> credits){
    num totalToDisplay = 0;
    totalToDisplay+=calculateReadingTotal(readings);
    totalToDisplay-=calculateCreditTotal(credits);
    totalToDisplay-=calculateExpenseTotal( expenses);





    return totalToDisplay;
  }

  shareReading(String index,Reading reading){
    return '${index}. ${reading.toString()}';
  }
  shareExpense(String index,Expense expense){
    return '${index}. ${expense.toString()}';
  }
  shareCredit(String index,Credit credit){
    return '${index}. ${credit.toString()}';
  }


  share(List<Reading> readings,List<Expense> expenses,List<Credit> credits){
    String shareString = '';


    if(readings.isNotEmpty){
      shareString+='*Readings*\n';
    }
    for(int i=0;i<readings.length;i++){
      shareString+=shareReading((i+1).toString(), readings[i]);
    }

    if(readings.isNotEmpty){
      shareString+='*Readings Total: ${calculateReadingTotal(readings).toStringAsFixed(2)}*\n-------\n';
    }
    if(credits.isNotEmpty){
      shareString+='*Credits*\n';
    }
    for(int i=0;i<credits.length;i++){
      shareString+=shareCredit((i+1).toString(), credits[i]);
    }
    if(credits.isNotEmpty){
      shareString+='*Credits Total: ${calculateCreditTotal(credits).toStringAsFixed(2)}*\n-------\n';
    }
    if(expenses.isNotEmpty){
      shareString+='*Expenses*\n';
    }
    
    
    for(int i=0;i<expenses.length;i++){
      shareString+=shareExpense((i+1).toString(), expenses[i]);
    }
    if(expenses.isNotEmpty){
      shareString+='*Expenses Total: ${calculateExpenseTotal(expenses).toStringAsFixed(2)}*\n-------\n';
    }
    shareString+='\n************************\n';
    shareString+='*Total Amount: ${calculateTotal(readings, expenses, credits).toStringAsFixed(2)}*';


    Share.share(shareString);
    // return shareString;
  }
  readingCalculations(
      TextEditingController description,
      TextEditingController startingReading,
      TextEditingController endingReading,
      TextEditingController rateReading) {
    num starting = 0;
    num ending = 0;
    num rate = 0;

    if (startingReading.text != '') {
      starting = num.parse(startingReading.text);
    }

    if (endingReading.text != '') {
      ending = num.parse(endingReading.text);
    }

    if (rateReading.text != '') {
      rate = num.parse(rateReading.text);
    }

    num total = (ending - starting) * rate;

    readingList.add(new Reading(
        description: description.text,
        startingReading: starting,
        endingReading: ending,
        rate: rate));

    return total.round();
  }

  expenseCalculation(
    TextEditingController description,
    TextEditingController expenseController,
  ) {
    num expenseTotal = 0;

    if (expenseController.text != '') {
      expenseTotal = num.parse(expenseController.text);
    }

    expenseList
        .add(new Expense(description: description.text, amount: expenseTotal));

    return expenseTotal;
  }

  creditCalculation(
      TextEditingController description,
      TextEditingController litreController,
      TextEditingController rateController) {
    num litre = 0;
    num rate = 0;

    if (litreController.text != '') {
      litre = num.parse(litreController.text);
    }

    if (rateController.text != '') {
      rate = num.parse(rateController.text);
    }

    num total = litre * rate;

    creditList.add(
        new Credit(litre: litre, description: description.text, rate: rate));
    return total.round();
  }
}
