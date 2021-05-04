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
      appBar: AppBar(
        title: Text('Edit'),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: _editPage(),
    );
  }

  _createTimeChooser({String name, int timerLen, String prefsName, bool section=false}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
      ),
      color: Colors.blueGrey[900],
      child: ExpansionTile(
        title: Text(
          '$name',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        leading: Icon(Icons.arrow_drop_down_circle),

        //if section=true, trailing should show intervals not min
        //eg: Sections 8 intervals not Sections 8 min
        trailing: Text(section == false ? '$timerLen  min' : '$timerLen intervals',
            style: TextStyle(fontSize: 20, color: Colors.grey[400])),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(20),
                child: IconButton(
                  icon: Icon(Icons.remove),
                  color: Colors.grey[350],
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
                child: Text('$timerLen', style: TextStyle(fontSize: 26, color: Colors.grey[350]),),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: IconButton(
                  icon: Icon(Icons.add),
                  color: Colors.grey[350],
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
        _createTimeChooser(
            name: 'Pomodoro ', timerLen: pomodoro, prefsName: 'pomodoro'),
        _createTimeChooser(
            name: 'Short break',
            timerLen: shortBreak,
            prefsName: 'short_break'),
        _createTimeChooser(
            name: 'Long break', timerLen: longBreak, prefsName: 'long_break'),
        _createTimeChooser(
            name: 'Sections',
            timerLen: untilLongBreak,
            prefsName: 'until_long_break',
            section: true),
      ],
    );
  }
}
