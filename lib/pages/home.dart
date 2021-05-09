import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wakelock/wakelock.dart';

import '../main.dart';
import './edit_page.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Timer _timer; //to play the alarm even when app is in background.
  final AudioCache soundPlayer = AudioCache(prefix: 'assets/sounds/');

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
  var _animatedTimer;

  //swiping should not change the timer type when the timer is paused in the middle
  //_pausedInTheMiddle will be true when the user has paused while the timer was running
  //this is needed because _isPaused will be true when _restart() is called but swiping is allowed when the timer is restarted
  bool _pausedInTheMiddle = false;

  _restart() async {
    // _controller.restart(duration: _stateDuration() * 60);
    _controller.restart(duration: _stateDuration());
    _controller.pause(); //timer will automiatically start without this.
    Wakelock.disable();
    _timer.cancel();

    _isPaused = true;
    _isPlayDisabled = false;
    _pausedInTheMiddle = false;

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

  _start() {
    _controller.start();
    Wakelock.enable();

    setState(() {
      _startIcon = Icon(Icons.pause);
    });
    _timer = Timer.periodic(Duration(seconds: _stateDuration()), (timer) {
      soundPlayer.play('beep.mp3');
      _timer.cancel();
    });

    _showOngoingNotification();
  }

  _resume() {
    _controller.resume();
    Wakelock.enable();

    _pausedInTheMiddle = false;

    setState(() {
      _startIcon = Icon(Icons.pause);
    });

    //_controller.getTime() returns a string of type 01:30
    //it is converted to seconds
    //it is then used as duration for timer
    String _timeLeft = _controller.getTime();
    List<String> _parts = _timeLeft.split(':');
    int _inSeconds = int.parse(_parts[0]) * 60 + int.parse(_parts[1]);
    _timer = Timer.periodic(Duration(seconds: _inSeconds), (timer) {
      soundPlayer.play('beep.mp3');
      _timer.cancel();
    });

    _showOngoingNotification();
  }

  _pause() async {
    _controller.pause();
    _timer.cancel();

    _isPaused = true;
    _pausedInTheMiddle = true;

    setState(() {
      _startIcon = Icon(Icons.play_arrow);
    });
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  _buildTimerUI(int key) {
    return GestureDetector(
      //start the timer, when tapped on the timer UI
      onTap: () {
        if (!_isPlayDisabled && !_isPaused) {
          _start();
        } else if (_isPaused) {
          _resume();
        }
      },
      child: CircularCountDownTimer(
        key: ValueKey(key),
        // Countdown duration in Seconds.
        // duration: _stateDuration() * 60,
        duration: _stateDuration(),

        // Controls (i.e Start, Pause, Resume, Restart) the Countdown Timer.
        controller: _controller,

        // Width of the Countdown Widget.
        width: MediaQuery.of(context).size.width / 2,

        // Height of the Countdown Widget.
        height: MediaQuery.of(context).size.height / 2,

        // Ring Color for Countdown Widget.
        color: Color(0xFF23213a),

        // Filling Color for Countdown Widget.
        fillColor: Color(0xFF544de7),

        // Background Color for Countdown Widget.
        backgroundColor: Color(0xFF232230),

        // Border Thickness of the Countdown Ring.
        strokeWidth: 5.0,

        // Begin and end contours with a flat edge and no extension.
        strokeCap: StrokeCap.round,

        // Text Style for Countdown Text.
        textStyle: TextStyle(fontSize: 36.0, color: Colors.white),

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
          _isPlayDisabled = true;
          _isPaused = false;
        },

        // This Callback will execute when the Countdown Ends.
        //next timer is choosen and changed here
        onComplete: () async {
          Wakelock.disable();
          setState(() {
            _timer.cancel();

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

          //timer is completed notification
          _showTimerCompletedNotification();
        },
      ),
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

    soundPlayer.load('beep.mp3');
  }

  Future<void> _showOngoingNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'Pomodoro',
      'Pomodoro Timer',
      'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'Pomodoro', _stateName() + ' is running!', platformChannelSpecifics);
  }

  Future<void> _showTimerCompletedNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'Pomodoro', 'Completed Session', 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'Completed!', _stateName() + ' is completed!', platformChannelSpecifics);
  }

  Future onSelectNotification(String payload) async {
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    _animatedTimer = _buildTimerUI(timerState);

    Color _startStopButtonsColor = Color(0xFF664efe);

    return Scaffold(
      body: Center(
        child: GestureDetector(
          //SWIPE
          onHorizontalDragEnd: (dragEndDetails) {
            if (!_isPlayDisabled && !_pausedInTheMiddle) {
              _timer.cancel();
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
            } else {
              return;
            }
          },

          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                //title and menu button
                IntrinsicHeight(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(_stateName(),
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w900)),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: Icon(Icons.menu),
                          onPressed: () {
                            //Only go to the menu if the timer is NOT running.
                            if (!_isPlayDisabled) {
                              Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => EditPage()))
                                  .then((value) {
                                setState(() {
                                  pomodoro = prefs.getInt('pomodoro');
                                  shortBreak = prefs.getInt('short_break');
                                  longBreak = prefs.getInt('long_break');
                                  untilLongBreak =
                                      prefs.getInt('until_long_break');
                                });
                                _restart(); //to update the timer with new values
                              });
                            } else {
                              Fluttertoast.showToast(
                                msg: "Timer is running!",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(seconds: 1),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) =>
                          ScaleTransition(child: child, scale: animation),
                  child: _animatedTimer,
                ),
              ]),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: IconButton(
              icon: _startIcon,
              color: _startStopButtonsColor,
              onPressed: () async {
                //START
                if (!_isPlayDisabled && !_isPaused) {
                  _start();
                }
                //PAUSE
                else if (_isPlayDisabled && !_isPaused) {
                  _pause();
                }
                //RESUME
                else if (_isPaused) {
                  _resume();
                }
              },
            ),
          ),
          Expanded(
            child: IconButton(
              icon: Icon(Icons.replay),
              color: _startStopButtonsColor,
              onPressed: () => _restart(),
            ),
          ),
        ],
      ),
    );
  }
}
