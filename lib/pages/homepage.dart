import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:trackie/BARGRAP/bar_graph.dart';
import 'package:trackie/database/expense_database.dart';
import 'package:trackie/helper/helper_functions.dart';
import 'package:trackie/models/expense.dart';
import 'package:trackie/my_list_tile.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  //text editing controllers

  TextEditingController namecontroller = TextEditingController();
  TextEditingController amountcontroller = TextEditingController();

  //futures to load graph data
  Future<Map<int, double>>? _monthlyTotalsFuture;
  Future<double>? _calculateCurrentMonthTotal;

  //show the entered values from alert box
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  //refresh graph data
  void refreshData() {
    _monthlyTotalsFuture = Provider.of<ExpenseDatabase>(context, listen: false)
        .calculateMonthlytotals();
        _calculateCurrentMonthTotal = Provider.of<ExpenseDatabase>(context , listen: false)
        .calculateMonthlytotal();
  }

  //initially loads the data of bar graph
  Future<void> _loadData() async {
    await Provider.of<ExpenseDatabase>(context, listen: false).readExpenses();
    refreshData();
  }

//delete box

  void openDeleteBox(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        actions: [_DeleteExpenseButton(expense.id), _cancelBUtton()],
      ),
    );
  }

//edit box
  void openEditBox(Expense expense) {
    //prefill the values

    String existingname = expense.name;
    String existingamount = expense.amount.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namecontroller,
              decoration: InputDecoration(hintText: existingname),
            ),
            TextField(
              controller: amountcontroller,
              decoration: InputDecoration(hintText: existingamount),
            ),
          ],
        ),
        actions: [_EditExpenseButton(expense), _cancelBUtton()],
      ),
    );
  }

//main new expense box
  void openNewExpeseBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namecontroller,
              decoration: InputDecoration(hintText: "Expense name"),
            ),
            TextField(
              controller: amountcontroller,
              decoration: InputDecoration(hintText: " Amount"),
            ),
          ],
        ),
        actions: [
//save button
          _SaveBUtton(),

//cancel button

          _cancelBUtton()
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(builder: (context, value, child) {
//get dates
      int startMonth = value.getstartmonth();
      int startYear = value.getstartyear();
      int currentMonth = DateTime.now().month;
      int currentYear = DateTime.now().year;

//calculate number of months since first month
      int monthCount =
          calculatemonthcount(startYear, startMonth, currentYear, currentMonth);

      //only display the expenses for current monthen
      List<Expense> currentMonthExpense = value.allExpense.where((expense) {
        return expense.date.year == currentYear && 
        expense.date.month == currentMonth;
      }).toList();

//return ui
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: FutureBuilder<double>(
            future: _calculateCurrentMonthTotal, 
            builder: (context , snapshot){
              if (snapshot.connectionState == ConnectionState.done) {
                return  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Text('\₹' + snapshot.data!.toStringAsFixed(2)),

                    //month display
                     Text(getcurrentmonthName())
                  ],
                );
              }
              //loading 
              else{
                return const Text("Loading");
              }

            }),
        ),
        backgroundColor: const Color.fromARGB(255, 228, 191, 191),
        floatingActionButton: FloatingActionButton(
          onPressed: openNewExpeseBox,
          child: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            //bar graph
            SafeArea(
              child: SizedBox(
                height: 250,
                child: FutureBuilder(
                  future: _monthlyTotalsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      final monthlyTotals = snapshot.data ?? {};

                      //list of monthly summary
                      List<double> monthlySummary =
                          List.generate(monthCount, (index) {
                        final month = startMonth + index;
                        return month <= DateTime.now().month
                            ? monthlyTotals[month] ?? 0.0
                            : 0.0;
                      });

                      return BarGraph(
                          monthlySummary: monthlySummary,
                          startMonth: startMonth);
                    } else {
                      return const Center(
                        child: Text("Loading..."),
                      );
                    }
                  },
                ),
              ),
            ),

            //expense list ui
            Expanded(
              child: ListView.builder(
                  itemCount: currentMonthExpense.length,
                  itemBuilder: (context, index) {


                    // reverse index to show latest item first 
                    int reversedIndex = currentMonthExpense.length - 1 - index;

                    Expense individualExpense = currentMonthExpense[reversedIndex];

                    //return listtile
                    return MyListTile(
                      title: individualExpense.name,
                      trailing: formatAmount(individualExpense.amount),
                      onDeletePressed: (context) =>
                          openDeleteBox(individualExpense),
                      onEditPressed: (context) =>
                          openEditBox(individualExpense),
                    );
                  }),
            ),
          ],
        ),
      );
    });
  }

  //cancel button
  Widget _cancelBUtton() {
    return MaterialButton(
      onPressed: () {
        Navigator.pop(context);

        namecontroller.clear();
        amountcontroller.clear();
      },
      child: const Text("Clear"),
    );
  }

  //save button
  Widget _SaveBUtton() {
    return MaterialButton(
      onPressed: () {
        if (namecontroller.text.isNotEmpty &&
            amountcontroller.text.isNotEmpty) {
          //pop the box
          Navigator.pop(context);

          //create new expense
          Expense newExpense = Expense(
              name: namecontroller.text,
              amount: convertStringtoDouble(amountcontroller.text),
              date: DateTime.now());

          //save db

          context.read<ExpenseDatabase>().createNewExpense(newExpense);

          //refresh graph
          refreshData();

          //clear controllers

          namecontroller.clear();
          amountcontroller.clear();
        }
      },
      child: Text("Save"),
    );
  }

  Widget _EditExpenseButton(Expense expense) {
    return MaterialButton(onPressed: () async {
      if (namecontroller.text.isNotEmpty && amountcontroller.text.isNotEmpty) {
        //pop the box

        Navigator.pop(context);
        //create new expense
        Expense updatedExpense = Expense(
            name: namecontroller.text.isNotEmpty
                ? namecontroller.text
                : expense.name,
            amount: amountcontroller.text.isNotEmpty
                ? convertStringtoDouble(amountcontroller.text)
                : expense.amount,
            date: DateTime.now());

        //old expense id
        int existingID = expense.id;

        //save to db
        await context
            .read<ExpenseDatabase>()
            .updateExpeses(existingID, updatedExpense);

        //refresh graph

        refreshData();
      }
    });
  }

  Widget _DeleteExpenseButton(int id) {
    return MaterialButton(
      onPressed: () async {
//pop box

        Navigator.pop(context);

//delete from db

        await context.read<ExpenseDatabase>().deleteExpense(id);

        //refresh graph
        refreshData();
      },
      child: const Text("Delete"),
    );
  }
}
