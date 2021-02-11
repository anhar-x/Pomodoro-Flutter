import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

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

  bool _isPlayDisabled = false;
  bool _isPaused = false;

  CountDownController _controller = CountDownController();

  _button({String title, VoidCallback onPressed}) {
    var icon;
    if (title == 'Start') {
      icon = Icon(Icons.play_arrow);
    } else if (title == 'Pause') {
      icon = Icon(Icons.pause);
    } else {
      icon = Icon(Icons.replay);
    }
    return Expanded(
        child: IconButton(
      icon: icon,
      onPressed: onPressed,
      color: Colors.purple,
    ));
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
            onPressed: () {
              Navigator.push(context,
                      MaterialPageRoute(builder: (context) => EditPage()))
                  .then((value) => setState(() {
                        pomodoro = prefs.getInt('pomodoro');
                      }));
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularCountDownTimer(
                // Countdown duration in Seconds.
                duration: pomodoro,

                // Controls (i.e Start, Pause, Resume, Restart) the Countdown Timer.
                controller: _controller,

                // Width of the Countdown Widget.
                width: MediaQuery.of(context).size.width / 2,

                // Height of the Countdown Widget.
                height: MediaQuery.of(context).size.height / 2,

                // Ring Color for Countdown Widget.
                color: Colors.grey[300],

                // Filling Color for Countdown Widget.
                fillColor: Colors.blue[400],

                // Background Color for Countdown Widget.
                backgroundColor: Colors.blue[500],

                // Border Thickness of the Countdown Ring.
                strokeWidth: 20.0,

                // Begin and end contours with a flat edge and no extension.
                strokeCap: StrokeCap.round,

                // Text Style for Countdown Text.
                textStyle: TextStyle(
                    fontSize: 33.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),

                // Format for the Countdown Text.
                textFormat: CountdownTextFormat.MM_SS,

                // Handles Countdown Timer (true for Reverse Countdown (max to 0), false for Forward Countdown (0 to max)).
                isReverse: true,

                // Handles Animation Direction (true for Reverse Animation, false for Forward Animation).
                isReverseAnimation: true,

                // Handles visibility of the Countdown Text.
                isTimerTextShown: true,

                // Handles the timer start.
                autoStart: false,

                // This Callback will execute when the Countdown Starts.
                onStart: () {
                  // Here, do whatever you want
                  print('Countdown Started');
                },

                // This Callback will execute when the Countdown Ends.
                onComplete: () {
                  print('Countdown Ended');
                  player.play(alarmAudioPath);
                  _isPlayDisabled = false;
                },
              ),
            ]),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 30,
          ),
          _button(
              title: "Start",
              onPressed: () {
                if (!_isPlayDisabled) {
                  _controller.start();
                  _isPlayDisabled = true;
                }
                if (_isPaused) {
                  _controller.resume();
                  _isPaused = false;
                }
              }),
          SizedBox(
            width: 10,
          ),
          _button(
              title: "Pause",
              onPressed: () {
                _controller.pause();
                _isPaused = true;
              }),
          SizedBox(
            width: 10,
          ),
          _button(
              title: "Restart",
              onPressed: () {
                _controller.restart(duration: pomodoro);
                _isPlayDisabled = true;

              }),
        ],
      ),
    );
  }
}
