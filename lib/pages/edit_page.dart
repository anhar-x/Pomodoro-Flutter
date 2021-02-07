import 'package:flutter/material.dart';
import './home.dart';

class EditPage extends StatefulWidget {
  int longBreak;
  EditPage({this.longBreak});
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
                    child:Text(
                    'POMODORO \n DURATION', 
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
                        onPressed: () {
                          setState(() {
                            widget.longBreak--;
                            MyHomePage();
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('${widget.longBreak}'),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            widget.longBreak++;
                          });
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
