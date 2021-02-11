import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audio_cache.dart';

import '../main.dart';
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
  int pomodoro = prefs.getInt('pomodoro');

  bool _isPomoDisabled = false;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _isPomoDisabled = true;
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (pomodoro == 0) {
          player.play(alarmAudioPath);
          setState(() {
            timer.cancel();
            _isPomoDisabled = false;
            pomodoro = prefs.getInt('pomodoro');
          });
        } else {
          setState(() {
            pomodoro--;
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => EditPage())).then((value) => setState(() {pomodoro = prefs.getInt('pomodoro');}));
            },
          ),

        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              onPressed: _isPomoDisabled ? null : startTimer,
              child: Text( _isPomoDisabled ? 'Pomodoro running': 'Start Pomodoro')
            ),
            Text("$pomodoro")
          ],
        ),
      ),
    );
  }
}
