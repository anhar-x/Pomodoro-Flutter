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
  static const alarmAudioPath = "piece-of-cake.mp3";

  Timer _timer;

  int pomodoro = prefs.getInt('pomodoro');
  int shortBreak = prefs.getInt('short_break');
  int longBreak = prefs.getInt('long_break');
  int untilLongBreak = prefs.getInt('until_long_break');


  /*
  timerState=1=pomodoro
  timerState=0=shortBreak
  timerState=-1=longBreak
  */
  int timerState = 1;

  bool _isPlayDisabled = false;
  bool _isPaused = false;

  CountDownController _controller = CountDownController();
  CircularCountDownTimer _animatedTimer;

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

  _restart() {
    _controller.restart(duration: _whichState());
    _controller.pause();
    _isPaused = true;
  }

  _whichState() {
    if (timerState == 1) {
      return pomodoro;
    } else if (timerState == 0) {
      return shortBreak;
    } else if (timerState == -1) {
      return longBreak;
    }
  }

  //this is BAD code
  _stateName() {
    if (timerState == 1) {
      return 'pomodoro';
    } else if (timerState == 0) {
      return 'short break';
    } else {
      return 'long break';
    }
  }

  _buildTimerUI(int key) {
    return CircularCountDownTimer(
      key: ValueKey(key),
      // Countdown duration in Seconds.
      // duration: key == 1 ? pomodoro : shortBreak ,
      duration: _whichState(),

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
          fontSize: 33.0, color: Colors.white, fontWeight: FontWeight.bold),

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
      //next timer is choosen and changed here
      onComplete: () {
        print('Countdown Ended');
        player.play(alarmAudioPath);
        _restart();
        _isPlayDisabled = false;

        setState(() {
          // timerState = timerState == 1 ? 0 : 1;

          if (timerState == 1) {
            timerState = 0;
          } else if (timerState == 0) {
            timerState = -1;
          } else if (timerState == -1) {
            timerState = 1;
          }

          _animatedTimer = _buildTimerUI(timerState);
        });
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
    _animatedTimer = _buildTimerUI(timerState);

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
                        shortBreak = prefs.getInt('short_break');
                        longBreak = prefs.getInt('long_break');
                        untilLongBreak = prefs.getInt('until_long_break');

                      }));
            },
          ),
        ],
      ),
      body: Center(
          child: GestureDetector(
        //SWIPE
        //Using the DragEndDetails allows us to only fire once per swipe.
        onHorizontalDragEnd: (dragEndDetails) {
          if (dragEndDetails.primaryVelocity < 0) {
            //forwards
            setState(() {
              if (timerState == 1) {
                timerState = -1;
              } else if (timerState == -1) {
                timerState = 0;
              } else if (timerState == 0) {
                timerState = 1;
              }

              _animatedTimer = _buildTimerUI(timerState);
              _isPlayDisabled = false;
            });
          } else if (dragEndDetails.primaryVelocity > 0) {
            //backwards
            setState(() {
              if (timerState == 1) {
                timerState = 0;
              } else if (timerState == -1) {
                timerState = 1;
              } else if (timerState == 0) {
                timerState = -1;
              }

              _animatedTimer = _buildTimerUI(timerState);
              _isPlayDisabled = false;
            });
          }
        },
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(_stateName(),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              AnimatedSwitcher(
                duration: const Duration(seconds: 1),
                transitionBuilder:
                    (Widget child, Animation<double> animation) =>
                        ScaleTransition(child: child, scale: animation),
                child: _animatedTimer,
              ),
            ]),
      )),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 30,
          ),
          _button(
              title: "Start",
              onPressed: () {
                print('this is pressed');
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
            onPressed: () => _restart(),
          )
        ],
      ),
    );
  }
}
