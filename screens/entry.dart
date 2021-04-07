import 'package:flutter/material.dart';

import '../widgets/login.dart';

class EntryScreen extends StatefulWidget {
  @override
  _EntryScreenState createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(
        /*child: Container(
            child: Login())*/
        child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                height: 600,
                child: Login()
                ),
              ],
            )
        )
      ),
    );
  }
}
