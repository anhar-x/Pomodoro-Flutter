import 'package:flutter/material.dart';

import '../main.dart';
import './home.dart';

class IntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: Text('press'),
          onPressed: () {
            prefs.setBool('first_time', false);
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => MyHomePage()));
          },
        ),
      ),
    );
  }
}
