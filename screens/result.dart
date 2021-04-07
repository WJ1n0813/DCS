import 'dart:developer';
import 'dart:typed_data';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:flutter/material.dart';

class Result extends StatelessWidget {
  final int resultScore;
  final Function resetHandler;
  final String email;

  bool can = false;

  Result(this.resultScore, this.resetHandler, this.email);

//Remark Logic
  String get resultPhrase {
    String resultText;
    if (resultScore >= 40) {
      resultText = 'You are allowed to donate blood!';
      can = false;
      print(resultScore);
    }  else {
      can = true;
      resultText = 'You are disqualified for donating blood';
      print(resultScore);
    }
    return resultText;
  }


  UpdateCert() async{
    bool valid = false;
    if (resultScore >= 40){
      valid = true;
    }
    try {
      String item = '{"email":"' + email +
          '", "valid": "' + valid.toString() +
          '"}';

      RestOptions options = RestOptions(
          path: '/LambdaUpdateCert',
          body: Uint8List.fromList(item.codeUnits)
      );
      RestOperation restOperation = Amplify.API.post(
          restOptions: options
      );
      RestResponse response = await restOperation.response;
      await SaveSurvey(valid);
      print('UpdateCert call succeeded');
      print(new String.fromCharCodes(response.data));
    } on ApiException catch (e) {
      print('UpdateCert call failed: $e');
    }
  }

  SaveSurvey(bool valid) async{
    try {
      String item = '{"valid":"' + valid.toString() + '"}';

      RestOptions options = RestOptions(
          path: '/LambdaSaveSurveyResponse',
          body: Uint8List.fromList(item.codeUnits)
      );
      RestOperation restOperation = Amplify.API.post(
          restOptions: options
      );
      RestResponse response = await restOperation.response;
      print('SaveSurvey call succeeded');
      print(new String.fromCharCodes(response.data));
    } on ApiException catch (e) {
      print('SaveSurvey call failed: $e');
    }
  }

  // showAlertDialog(BuildContext context) {
  //   // set up the buttons
  //   Widget cancelButton = TextButton(
  //     child: Text("Cancel"),
  //     onPressed:  () {Navigator.pop(context);},
  //   );
  //   Widget continueButton = TextButton(
  //     child: Text("Done"),
  //     onPressed:  () {Navigator.pop(context);},
  //   );
  //   // set up the AlertDialog
  //   AlertDialog alert = AlertDialog(
  //     title: Text("Submitted"),
  //     content: Text("Your survey result had been recorded."),
  //     actions: [
  //       cancelButton,
  //       continueButton,
  //     ],
  //   );
  //   // show the dialog
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return alert;
  //     },
  //   );
  // }

  Widget _buildChild() {
    if (can) {
      return (TextButton(
        child: Text(
          'Restart Survey!',
          style: TextStyle(color: Colors.blue),
        ), //Text
        onPressed: resetHandler,
      ));
  }
    return (TextButton(
      child: Text(
        'No restart Survey!',
        style: TextStyle(color: Colors.blue),
      ), //Text
      onPressed: resetHandler,
    ));
  }

  @override
  Widget build(BuildContext context) {
    UpdateCert();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            resultPhrase,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ), //Text
          Text(
            'Score ' '$resultScore',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ), //Text
          // _buildChild(),
          // RaisedButton.icon(
          //   onPressed: (){ showAlertDialog(context); },
          //   shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.all(Radius.circular(10.0))),
          //   label: Text('Submit survey',
          //     style: TextStyle(color: Colors.white),),
          //   icon: Icon(Icons.where_to_vote_sharp, color:Colors.white,),
          //   textColor: Colors.white,
          //   splashColor: Colors.green,
          //   color: Colors.blue,),//FlatButton
        ], //<Widget>[]
      ), //Column
    ); //Center
  }
}
