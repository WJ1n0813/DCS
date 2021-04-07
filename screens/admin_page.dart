import 'dart:typed_data';

import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminState createState() => _AdminState();
}

class _AdminState extends State<AdminScreen> {

  AuthUser _user;
  String email = "";
  bool posted = false;
  String msg = "Blood Donation Request Post Fail";

  @override
  void initState() {
    super.initState();
    Amplify.Auth.getCurrentUser().then((user) {
      setState(() {
        email = user.username;
        _user = user;
      });
    }).catchError((error) {
      print((error as AuthException).message);
    });
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget continueButton = TextButton(
      child: Text("Okay"),
      onPressed:  () {Navigator.pop(context);},
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Request Details"),
      content: Text(msg),
      actions: [
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Post(BuildContext context) async {
    try {
      String item = '{"email":"' + email + '"}';

      RestOptions options = RestOptions(
          path: '/LambdaLocationSNS',
          body: Uint8List.fromList(item.codeUnits)
      );
      RestOperation restOperation = Amplify.API.post(
          restOptions: options
      );
      RestResponse response = await restOperation.response;
      print('Post DonateBlood call succeeded');
      print(new String.fromCharCodes(response.data));
      setState(() {
        posted = new String.fromCharCodes(response.data).toLowerCase() == 'true';
        msg = "Blood Donation Request Posted";
      });
    } on ApiException catch (e) {
      setState(() {
        posted = false;
        msg = "Blood Donation Request Post Fail";
      });
      print('Post DonateBlood call failed: $e');
    }

    showAlertDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Page'),
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
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                Text(
                  'Hello 👋🏾',
                  style: Theme.of(context).textTheme.headline2,
                ),
              Text(email),
              SizedBox(height: 10),
              // Text(_user.userId),
              // SizedBox(height: 100),
              Container(
                width: 150.0,
                height: 60.0,
                child: RaisedButton.icon(
                  onPressed: (){ Post(context); },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  label: Text('Post Request',
                    style: TextStyle(color: Colors.white),),
                  icon: Icon(Icons.post_add_rounded, color:Colors.white,),
                  textColor: Colors.white,
                  splashColor: Colors.green,
                  color: Colors.indigoAccent,),
              ),
            ],
          ),
        ),
      ),
    );
  }
}