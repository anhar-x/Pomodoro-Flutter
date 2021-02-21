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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
            )),
      ],
    );
  }
}
