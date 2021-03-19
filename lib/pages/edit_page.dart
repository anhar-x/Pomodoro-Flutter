import 'package:flutter/material.dart';
import '../main.dart';

class EditPage extends StatefulWidget {
  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit'), backgroundColor: Colors.blueGrey[800],),
      body: _editPage(),
    );
  }

  _createTimeChooser({String name, int timerLen, String prefsName}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: Colors.blueGrey,
      child: Column(
        children: [
          Text('$name', style: TextStyle(fontSize: 16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(20),
                child: IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () async {
                    if (timerLen > 1) {
                      setState(() {
                        timerLen--;
                      });
                      await prefs.setInt('$prefsName', timerLen);
                    }
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5),
                child: Text('$timerLen', style: TextStyle(fontSize: 26)),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () async {
                    setState(() {
                      timerLen++;
                    });
                    await prefs.setInt('$prefsName', timerLen);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _editPage() {
    int pomodoro = prefs.getInt('pomodoro');
    int shortBreak = prefs.getInt('short_break');
    int longBreak = prefs.getInt('long_break');
    int untilLongBreak = prefs.getInt('until_long_break');

    return Column(
      children: [
        _createTimeChooser(name: 'POMODORO \n DURATION', timerLen: pomodoro, prefsName: 'pomodoro'),
        _createTimeChooser(name: 'SHORT BREAK \n  DURATION', timerLen: shortBreak, prefsName: 'short_break'),
        _createTimeChooser(name: 'LONG BREAK \n  DURATION', timerLen: longBreak, prefsName: 'long_break'),
        _createTimeChooser(name: 'POMODOROS UNTIL \n  LONG BREAK', timerLen: untilLongBreak, prefsName: 'until_long_break'),
      ],
    );
  }
}
