import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audio_cache.dart';

import './edit_page.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static AudioCache player = AudioCache();
  static const alarmAudioPath = "alarm_pomodoro.mp3";

  Timer _timer;
  int longBreak = 10;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (longBreak == 0) {
          player.play(alarmAudioPath);
          setState(() {
            timer.cancel();
            longBreak = 10;
          });
        } else {
          setState(() {
            longBreak--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => EditPage(longBreak: longBreak,)));
            },
          ),

        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              onPressed: (){
                startTimer();
              },
              child: Text('Start Pomodoro')
            ),
            Text("$longBreak")
          ],
        ),
      ),
    );
  }
}
