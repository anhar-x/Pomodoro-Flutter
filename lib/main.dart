import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'pages/home.dart'; 

SharedPreferences prefs;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
  runApp(MyApp());
  if(prefs.getInt('pomodoro') == null){
    await prefs.setInt('pomodoro', 10);
  }
  if(prefs.getInt('short_break') == null){
    await prefs.setInt('short_break', 5);
  }
   if(prefs.getInt('long_break') == null){
    await prefs.setInt('long_break', 5);
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pomodoro Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Pomodoro'),
    );
  }
}

