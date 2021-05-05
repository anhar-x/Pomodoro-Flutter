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
      // appBar: AppBar(
      //   title: Text('Edit Pomodoro'),
      // ),

      body: _editPage(),
    );
  }

  _createTimeChooser(
      {String name, int timerLen, String prefsName, bool section = false}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
      ),
      color: Color(0xFF2d2c3e),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: ExpansionTile(
          title: Text(
            '$name',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          leading: Icon(Icons.arrow_drop_down),

          //if section=true, trailing should show intervals not min
          //eg: Sections 8 intervals not Sections 8 min
          trailing: Text(
              section == false ? '$timerLen  min' : '$timerLen intervals',
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
                  child: Text(
                    '$timerLen',
                    style: TextStyle(fontSize: 26, color: Colors.grey[350]),
                  ),
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
      ),
    );
  }

  _editPage() {
    int pomodoro = prefs.getInt('pomodoro');
    int shortBreak = prefs.getInt('short_break');
    int longBreak = prefs.getInt('long_break');
    int untilLongBreak = prefs.getInt('until_long_break');

    return SingleChildScrollView(
      child: Column(
        children: [
          //App bar title and go back button
          Padding(
            padding: EdgeInsets.only(top: 80.0, bottom: 100.0),
            child: IntrinsicHeight(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      iconSize: 30.0,
                      icon: Icon(Icons.keyboard_arrow_left_sharp),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Edit pomodoro',
                      style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
      ),
    );
  }
}
