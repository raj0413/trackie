import 'package:intl/intl.dart';

// all helepr function are here which can be use in all over applicat

//convert string to a double

double convertStringtoDouble(String string) {
  double? amount = double.tryParse(string);
  return amount ?? 0;
}

// format double into dollars and rupees
String formatAmount(double amount) {
  final format =
      NumberFormat.currency(locale: "en_US", symbol: "\₹", decimalDigits: 2);
  return format.format(amount);
}

////calculate number of months since first month

int calculatemonthcount(int startYear, startMonth, currentYear, currentMonth) {
  int monthCount =
      (currentYear - startYear) * 12 + currentMonth - startMonth + 1;
  return monthCount;
}

//get current month name
String getcurrentmonthName() {
  DateTime now = DateTime.now();
  List<String> months = [
    "JAN",
    "FEB",
    "MAR",
    "APR",
    "MAY",
    "JUN",
    "JULY",
    "AUG",
    "SEP",
    "OCT",
    "NOV",
    "DEC",
  ];
  return months[now.month - 1];
}
