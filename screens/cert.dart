import 'dart:developer';
import 'dart:typed_data';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify.dart';

class Certificate extends StatefulWidget {
  @override
  _CertificateState createState() => _CertificateState();
}

class _CertificateState extends State<Certificate> {

  bool valid = false;
  // False = Error/Timeout/Invalid Donor , True = Valid Donor, Valid Cert

  AuthUser _user;
  @override
  void initState() {
    super.initState();
    Amplify.Auth.getCurrentUser().then((user) {
      GetCert(user.username);
      setState(() {
        _user = user;
      });
    }).catchError((error) {
      print((error as AuthException).message);
    });

  }

  GetCert(String email) async {
    try {
      String item = '{"email":"' + email + '"}';

      RestOptions options = RestOptions(
          path: '/LambdaGetCert',
          body: Uint8List.fromList(item.codeUnits)
      );
      RestOperation restOperation = Amplify.API.post(
          restOptions: options
      );
      RestResponse response = await restOperation.response;
      print('GetCert call succeeded');
      print(new String.fromCharCodes(response.data));
      setState(() {
        valid = new String.fromCharCodes(response.data).toLowerCase() == 'true';
      });
    } on ApiException catch (e) {
      setState(() {
        valid = false;
      });
      print('GetCert call failed: $e');
    }
  }

  Widget _buildChild(){
    if (valid == true ) {
      return (Padding(
        padding: const EdgeInsets.only(top: 150.0),
        child: Center(
          child: Container(
              width: 350,
              height: 250,
              child: Image.asset('images/Pass.png')),
        ),
      ));
    }
    return (Padding(
      padding: const EdgeInsets.only(top: 150.0),
      child: Center(
        child: Container(
            // width: 350,
            // height: 250,
            child: Image.asset('images/cert.jpg'),
        ),
      ),
    ));

  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Certificate"),
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
      body: new SingleChildScrollView(
        child: _buildChild(),
      ),
    );
  }
}
