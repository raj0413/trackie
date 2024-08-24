import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackie/database/expense_database.dart';

import 'package:trackie/pages/homepage.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await ExpenseDatabase.initialise();
  runApp(ChangeNotifierProvider(
    create: (context) => ExpenseDatabase(),
    child: const MyApp(),
  )
    
    
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
     home: Homepage(),
     debugShowCheckedModeBanner: false,
    );
  }
}

