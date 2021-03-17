import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../main.dart';
import './edit_page.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  static AudioCache player = AudioCache();
  static const alarmAudioPath = "piece-of-cake.mp3";

  int pomodoro = prefs.getInt('pomodoro');
  int shortBreak = prefs.getInt('short_break');
  int longBreak = prefs.getInt('long_break');
  int untilLongBreak = prefs
      .getInt('until_long_break'); //when this is zero, longBreak is played.

  /*
  timerState=1=pomodoro
  timerState=0=shortBreak
  timerState=-1=longBreak
  */
  int timerState = 1;

  bool _isPlayDisabled = false; //true when the timer is running.
  bool _isPaused = false; //true when the timer is paused.
  Icon _startIcon = Icon(
      Icons.play_arrow); //this is changed depending on the state of the timer.

  CountDownController _controller = CountDownController();
  CircularCountDownTimer _animatedTimer;

  _restart() async {
    _controller.restart(duration: _stateDuration());
    _controller.pause();
    _isPaused = true;
    setState(() {
      _startIcon = Icon(Icons.play_arrow);
    });
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  //returns the duration of state for a given timerState.
  _stateDuration() {
    if (timerState == 1) {
      return pomodoro;
    } else if (timerState == 0) {
      return shortBreak;
    } else if (timerState == -1) {
      return longBreak;
    }
  }

  //this is BAD code or is it?
  //returns the name of the state for a given timerState.
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
      duration: _stateDuration(),

      // Controls (i.e Start, Pause, Resume, Restart) the Countdown Timer.
      controller: _controller,

      // Width of the Countdown Widget.
      width: MediaQuery.of(context).size.width / 2,

      // Height of the Countdown Widget.
      height: MediaQuery.of(context).size.height / 2,

      // Ring Color for Countdown Widget.
      color: Colors.grey[300],

      // Filling Color for Countdown Widget.
      fillColor: Colors.blueGrey,

      // Background Color for Countdown Widget.
      backgroundColor: Colors.blueGrey[900],

      // Border Thickness of the Countdown Ring.
      strokeWidth: 20.0,

      // Begin and end contours with a flat edge and no extension.
      strokeCap: StrokeCap.round,

      // Text Style for Countdown Text.
      textStyle: TextStyle(
          fontSize: 36.0, color: Colors.white, fontWeight: FontWeight.bold),

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
      },

      // This Callback will execute when the Countdown Ends.
      //next timer is choosen and changed here
      onComplete: () async {
        player.play(alarmAudioPath);
        setState(() {
          if (untilLongBreak > 1) {
            if (timerState == 1) {
              timerState = 0;
            } else {
              timerState = 1;
              untilLongBreak--;
            }
          } else {
            timerState = -1;
            untilLongBreak = prefs.getInt('until_long_break').toInt() + 1;
          }
          _animatedTimer = _buildTimerUI(timerState);
          _startIcon = Icon(Icons.play_arrow);
        });
        _isPlayDisabled = false;
        _isPaused = false;
        await flutterLocalNotificationsPlugin.cancelAll();
      },
    );
  }

  @override
  void initState() {
    super.initState();
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('pomodoro_icon');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  // Future<void> _showIndeterminateProgressNotification() async {
  //   const AndroidNotificationDetails androidPlatformChannelSpecifics =
  //       AndroidNotificationDetails(
  //           'indeterminate progress channel',
  //           'indeterminate progress channel',
  //           'indeterminate progress channel description',
  //           channelShowBadge: false,
  //           importance: Importance.max,
  //           priority: Priority.high,
  //           onlyAlertOnce: true,
  //           showProgress: true,
  //           indeterminate: true);
  //   const NotificationDetails platformChannelSpecifics =
  //       NotificationDetails(android: androidPlatformChannelSpecifics);
  //   await flutterLocalNotificationsPlugin.show(
  //       0,
  //       'Pomodoro',
  //       _stateName() + ' is running!',
  //       platformChannelSpecifics,
  //       payload: 'item x');
  // }

  Future<void> _showOngoingNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'Pomodoro', 'Pomodoro Timer', 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ongoing: true,
            autoCancel: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'Pomodoro', _stateName() + ' is running!', platformChannelSpecifics);
  }

  Future onSelectNotification(String payload) async {
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    _animatedTimer = _buildTimerUI(timerState);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blueGrey[800],
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Navigator.push(context,
                      MaterialPageRoute(builder: (context) => EditPage()))
                  .then((value) {
                setState(() {
                  pomodoro = prefs.getInt('pomodoro');
                  shortBreak = prefs.getInt('short_break');
                  longBreak = prefs.getInt('long_break');
                  untilLongBreak = prefs.getInt('until_long_break');
                });
                _restart(); //to update the timer with new values
              });
            },
          ),
        ],
      ),
      body: Center(
          child: GestureDetector(
        //SWIPE
        onHorizontalDragEnd: (dragEndDetails) {
          if (!_isPlayDisabled || _isPaused) {
            print('ITS WORKINGGGGGG');
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
              });
            }
            _startIcon = Icon(Icons.play_arrow);
            _isPlayDisabled = false;
            _isPaused = false;
          }else{
            print('DISABLEDDDDDDDD');
            return;
          }
        },

        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(_stateName(),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
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
          Expanded(
            child: IconButton(
              icon: _startIcon,
              color: Colors.blueGrey[900],
              onPressed: () async {
                //START
                if (!_isPlayDisabled && !_isPaused) {
                  _controller.start();
                  _isPlayDisabled = true;
                  setState(() {
                    _startIcon = Icon(Icons.pause);
                  });
                  // _showIndeterminateProgressNotification();
                  _showOngoingNotification();
                }
                //PAUSE
                else if (_isPlayDisabled && !_isPaused) {
                  _controller.pause();
                  _isPaused = true;
                  setState(() {
                    _startIcon = Icon(Icons.play_arrow);
                  });
                  await flutterLocalNotificationsPlugin.cancelAll();
                }
                //RESUME
                else if (_isPaused) {
                  _controller.resume();
                  _isPaused = false;
                  setState(() {
                    _startIcon = Icon(Icons.pause);
                  });
                  // _showIndeterminateProgressNotification();
                  _showOngoingNotification();
                }
              },
            ),
          ),
          Expanded(
            child: IconButton(
              icon: Icon(Icons.replay),
              color: Colors.blueGrey[900],
              onPressed: () => _restart(),
            ),
          ),
        ],
      ),
    );
  }
}
