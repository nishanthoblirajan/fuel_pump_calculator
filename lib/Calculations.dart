import 'package:flutter/cupertino.dart';
import 'package:fuel_pump_calculator/DataClass/Credit.dart';
import 'package:fuel_pump_calculator/creditCalculation.dart';

import 'DataClass/Expense.dart';
import 'DataClass/Reading.dart';
import 'main.dart';

class Calculations {
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
