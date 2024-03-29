import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/home.dart'; 
import 'pages/intro_page.dart';

SharedPreferences prefs;


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();

  runApp(MyApp());

  //Default values are set here.
  if(prefs.getInt('pomodoro') == null){
    await prefs.setInt('pomodoro', 10);
  }
  if(prefs.getInt('short_break') == null){
    await prefs.setInt('short_break', 5);
  }
  if(prefs.getInt('long_break') == null){
    await prefs.setInt('long_break', 5);
  }
  if(prefs.getInt('until_long_break') == null){
    await prefs.setInt('until_long_break', 4);
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pomodoro Flutter',
      theme: ThemeData.dark().copyWith(
        backgroundColor: Color(0xFF1e1b2e),
        scaffoldBackgroundColor:  Color(0xFF1e1b2e),
        dividerColor: Colors.transparent,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // home: prefs.getBool('first_time') == null ? IntroPage() : MyHomePage(),
      home: MyHomePage(),
    );
  }
}

