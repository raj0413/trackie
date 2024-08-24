


import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trackie/models/expense.dart';

class ExpenseDatabase extends ChangeNotifier{
  static late Isar isar;
  final List<Expense> _allExpenses = [];


//initialise database 
static Future<void> initialise() async{
  final dir = await getApplicationDocumentsDirectory();
  isar = await Isar.open([ExpenseSchema], directory: dir.path);
}

//getter method
List<Expense> get allExpense => _allExpenses;


// OPERATIONS//
 

//create
Future<void> createNewExpense(Expense newExpense) async {

  await isar.writeTxn(() => isar.expenses.put(newExpense));
  
readExpenses();
}




//read   
Future<void> readExpenses() async {
  List<Expense> fetchedExpenses = await isar.expenses.where().findAll();


//provide to local expense list as updated
  _allExpenses.clear();
  _allExpenses.addAll(fetchedExpenses);


  //update ui
  notifyListeners();
}




//update 
Future<void> updateExpeses(int id ,  Expense upadtedExpense) async{
  upadtedExpense.id = id;

  await isar.writeTxn(() => isar.expenses.put(upadtedExpense));

  await readExpenses();
}


//delete

Future<void> deleteExpense(int id ) async{
  await isar.writeTxn(() => isar.expenses.delete(id));

  await readExpenses();
}

//helper 

//calculate total of each month
Future<Map<int,double>> calculateMonthlytotals() async {
  Map<int, double> monthlytotals = {} ;

  for (var expense in _allExpenses) {
    int month = expense.date.month;

    if (!monthlytotals.containsKey(month)) {
      monthlytotals[month] = 0;
    }
    monthlytotals[month] = monthlytotals[month]! + expense.amount;

  }
  return monthlytotals;
}


Future<double> calculateMonthlytotal() async {
  // ensure expenses are read from db first 
  await readExpenses();

  //get current month , year 
  int currentMonth = DateTime.now().month;
  int currentYear = DateTime.now().year;


  List<Expense> currentMonthExpense = _allExpenses.where((expense) {
    return expense.date.month == currentMonth && 
     expense.date.year == currentYear ; 
  }).toList();

  //calculating total amount of current month 
  double total = currentMonthExpense.fold(0, (sum , expense) => sum + expense.amount);

  return total;
}


//get start month 

int getstartmonth(){
  if (_allExpenses.isEmpty) {
    return DateTime.now().month;
  }
  _allExpenses.sort(
(a,b) => a.date.compareTo(b.date)
  );
  return _allExpenses.first.date.month;
}


//get start year
int getstartyear(){
  if (_allExpenses.isEmpty) {
    return DateTime.now().year;
  }
  _allExpenses.sort(
(a,b) => a.date.compareTo(b.date)
  );
  return _allExpenses.first.date.year;
}





}