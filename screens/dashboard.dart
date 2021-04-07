import 'package:sbd/screens/cert.dart';
import 'package:sbd/screens/profile.dart';
import 'package:sbd/screens/survey.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:sbd/screens/blood_report.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    Profile(),
    Survey(),
    Certificate(),
    BloodScreen(),
  ];
  AuthUser _user;

  @override
  void initState() {
    super.initState();
    Amplify.Auth.getCurrentUser().then((user) {
      setState(() {
        _user = user;
      });
    }).catchError((error) {
      print((error as AuthException).message);
    });
  }


  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          MaterialButton(
            onPressed: () {
              Amplify.Auth.signOut().then((_) {
                Navigator.pushReplacementNamed(context, '/');
              });
            },
            child: Icon(
              Icons.logout,
              color: Colors.white,
            ),
          )
        ],
      ),*/
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_rounded),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_rounded),
            label: 'Survey',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.ballot),
            label: 'Certificate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'Blood Report',
          ),
        ],
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.black,

      ),


    );
  }
}
