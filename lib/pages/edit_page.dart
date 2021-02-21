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
      appBar: AppBar(title: Text('Edit')),
      body: _editPage(),
    );
  }

  _editPage() {
    int pomodoro = prefs.getInt('pomodoro');
    int shortBreak = prefs.getInt('short_break');
    int longBreak = prefs.getInt('long_break');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //POMODORO
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          color: Colors.pink,
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                color: Colors.pink[300],
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text('POMODORO \n DURATION',
                      style: TextStyle(fontSize: 24)),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () async {
                        if (pomodoro > 1) {
                          setState(() {
                            pomodoro--;
                          });
                          await prefs.setInt('pomodoro', pomodoro);
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('$pomodoro'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () async {
                        setState(() {
                          pomodoro++;
                        });
                        await prefs.setInt('pomodoro', pomodoro);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        //SHORT BREAK
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          color: Colors.pink,
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                color: Colors.pink[300],
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text('SHORT BREAK \n DURATION',
                      style: TextStyle(fontSize: 24)),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () async {
                        if (shortBreak > 1) {
                          setState(() {
                            shortBreak--;
                          });
                          await prefs.setInt('short_break', shortBreak);
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('$shortBreak'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () async {
                        setState(() {
                          shortBreak++;
                        });
                        await prefs.setInt('short_break', shortBreak);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        //LONG BREAK
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          color: Colors.pink,
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                color: Colors.pink[300],
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text('LONG BREAK \n DURATION',
                      style: TextStyle(fontSize: 24)),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () async {
                        if (longBreak > 1) {
                          setState(() {
                            longBreak--;
                          });
                          await prefs.setInt('long_break', longBreak);
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('$longBreak'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () async {
                        setState(() {
                          longBreak++;
                        });
                        await prefs.setInt('long_break', longBreak);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
