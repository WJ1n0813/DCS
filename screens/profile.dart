import 'dart:convert';
import 'dart:typed_data';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Details details;
  TextEditingController NameController = TextEditingController();
  // TextEditingController GenderController = TextEditingController();
  TextEditingController EmailController = TextEditingController();
  // TextEditingController PhoneController = TextEditingController();
  TextEditingController ICController = TextEditingController();
  bool isLoading = false;
  AuthUser _user;
  bool _displayNameValid = true;
  // bool _GenderValid = true;
  bool _emailValid = true;
  // bool _phoneValid = true;
  bool _icValid = false;
  String updatemsg = "Error Occured, Profile Not Updated";

  @override
  void initState() {
    super.initState();
    Amplify.Auth.getCurrentUser().then((user) {
      setState(() {
        getProfile(user.username);
        _user = user;
      });
    }).catchError((error) {
      print((error as AuthException).message);
    });

  }

  getProfile(String email) async {
    try {
      String item = '{"email":"' + email + '"}';

      RestOptions options = RestOptions(
          path: '/LambdaGetProfile',
          // body: Uint8List.fromList('{\'name\':\'Mow the lawn\'}'.codeUnits)
          body: Uint8List.fromList(item.codeUnits)
      );
      RestOperation restOperation = Amplify.API.post(
          restOptions: options
      );
      RestResponse response = await restOperation.response;
      print('GET call succeeded');
      print(new String.fromCharCodes(response.data));
      details = Details.fromMap(json.decode(new String.fromCharCodes(response.data)));

      EmailController.value = TextEditingValue(
        text: details.email,
        selection: TextSelection.fromPosition(
          TextPosition(offset: details.email.length),
        ),
      );

      NameController.value = TextEditingValue(
        text: details.name,
        selection: TextSelection.fromPosition(
          TextPosition(offset: details.name.length),
        ),
      );

      ICController.value = TextEditingValue(
        text: details.ic,
        selection: TextSelection.fromPosition(
          TextPosition(offset: details.ic.length),
        ),
      );

    } on ApiException catch (e) {
      print('GET call failed: $e');
    }
  }

  bool isEmail(String string) {
    // Null or empty string is invalid
    if (string == null || string.isEmpty) {
      return false;
    }

    const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    final regExp = RegExp(pattern);

    if (!regExp.hasMatch(string)) {
      return false;
    }
    return true;
  }

  // bool isValidPhoneNumber(String string) {
  //   // Null or empty string is invalid phone number
  //   if (string == null || string.isEmpty) {
  //     return false;
  //   }
  //
  //   // You may need to change this pattern to fit your requirement.
  //   // I just copied the pattern from here: https://regexr.com/3c53v
  //   const pattern = r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$';
  //   final regExp = RegExp(pattern);
  //
  //   if (!regExp.hasMatch(string)) {
  //     return false;
  //   }
  //
  //   return true;
  // }

  bool isValidIC(String string){
    if (string == null || string.isEmpty) {
      return false;
    }

    const pattern =r'^\\d{6}\\-\\d{2}\\-\\d{4}$';
    final regExp = RegExp(pattern);

    if(!regExp.hasMatch(string)){
      return false;
    }
    return true;
  }


  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget continueButton = TextButton(
      child: Text("Okay"),
      onPressed:  () {Navigator.pop(context);},
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Update Details"),
      content: Text(updatemsg),
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

  Future<void> post(BuildContext context) async {
    try {
      String item = '{"email":"' + EmailController.text.trim()
          + '", "name" : "' + NameController.text.trim()
          + '", "ic" :"' + ICController.text.trim() +
          '"}';
      RestOptions options = RestOptions(
          path: '/LambdaUpdateProfile',
          // body: Uint8List.fromList('{\'name\':\'Mow the lawn\'}'.codeUnits)
          body: Uint8List.fromList(item.codeUnits)
      );
      RestOperation restOperation = Amplify.API.post(
          restOptions: options
      );
      RestResponse response = await restOperation.response;
      print('POST call succeeded');
      print(new String.fromCharCodes(response.data));
      setState(() {
        updatemsg = new String.fromCharCodes(response.data);
      });
    } on ApiException catch (e) {
      setState(() {
        updatemsg = "Error Occured, Profile Not Updated";
      });
      print('POST call failed: $e');
    }

    showAlertDialog(context);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
      appBar:  new AppBar(
        title: new Text("Profile"),
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
      body: profileView(context)
    );
  }

  updateProfileData(BuildContext context){
    setState(() {
      NameController.text.trim().length < 3 || NameController.text.isEmpty ? _displayNameValid = false : _displayNameValid = true;
      // GenderController.text.isEmpty || GenderController.text.trim().length > 10 ? _GenderValid = false : _GenderValid = true;
      (EmailController.text.isEmpty || EmailController.text.trim().length < 10) && isEmail(EmailController.text) ? _emailValid = false : _emailValid = true;
      // (PhoneController.text.isEmpty || PhoneController.text.trim().length < 10) && isValidPhoneNumber(PhoneController.text) ? _phoneValid = false : _phoneValid = true;
      (ICController.text.isEmpty || ICController.text.trim().length != 14) && isValidIC(ICController.text) ? _icValid = false : _icValid = true;
    });

    // if(_displayNameValid && _GenderValid && _emailValid && _phoneValid && _icValid) {
    if(_displayNameValid && _emailValid && _icValid) {
      post(context);
    }
    else {
      showAlertDialog(context);
    }

  }

  Widget profileView(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(30, 50, 30, 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(height: 50, width: 50, child: Icon(Icons.account_circle_sharp,size: 24,color: Colors.black54,),decoration: BoxDecoration(border: Border.all(color: Colors.black54), borderRadius: BorderRadius.all(Radius.circular(10))),),
              Text('Profile',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, ),),
              Container(height:24,width:24)
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
          child: Stack(
            children: <Widget>[
              CircleAvatar(
                radius: 70,
                child: ClipOval(child: Image.asset('images/img.png',height: 150,width: 150,fit: BoxFit.cover,),),
              ),
              Positioned(bottom: 1,right: 1,child: Container(
                height: 40, width: 40,
                child: Icon(Icons.add_a_photo, color: Colors.white,),
                decoration: BoxDecoration(
                  color: Colors.deepOrange,
                  borderRadius: BorderRadius.all(Radius.circular(20))
                ),
              ))
            ],
          ),
        ),
        Expanded(
          flex: 3,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius:  BorderRadius.only(topLeft: Radius.circular(30),topRight: Radius.circular(30)),
                    gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [Colors.black54, Color.fromRGBO(0, 41, 102, 1)]
                    )
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20,25,20,4),
                        child: Container(
                          height: 60,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(controller: NameController, style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(hintText: "Your name",
                              errorText: _displayNameValid ? null : "Display Name too short",
                              ),
                              ),
                            ),
                          ), decoration: BoxDecoration(border: Border.all(color: Colors.white70), borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.fromLTRB(20,5,20,4),
                      //   child: Container(
                      //     height: 60,
                      //     child: Align(
                      //       alignment: Alignment.centerLeft,
                      //       child: Padding(
                      //         padding: const EdgeInsets.all(8.0),
                      //         child: TextField(controller: GenderController, style: TextStyle(color: Colors.white),
                      //           decoration: InputDecoration(hintText: "Your Gender",
                      //             errorText: _displayNameValid ? null : "Display Name too short",
                      //           ),
                      //         ),
                      //       ),
                      //     ), decoration: BoxDecoration(border: Border.all(color: Colors.white70), borderRadius: BorderRadius.all(Radius.circular(20)),
                      //   ),
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20,5,20,4),
                        child: Container(
                          height: 60,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(controller: EmailController, style: TextStyle(color: Colors.white), readOnly: true,
                                decoration: InputDecoration(hintText: "Your Email",
                                  errorText: _displayNameValid ? null : "Wrong Email format",
                                ),
                              ),
                            ),
                          ), decoration: BoxDecoration(border: Border.all(color: Colors.white70), borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.fromLTRB(20,5,20,4),
                      //   child: Container(
                      //     height: 60,
                      //     child: Align(
                      //       alignment: Alignment.centerLeft,
                      //       child: Padding(
                      //         padding: const EdgeInsets.all(8.0),
                      //         child: TextField(controller: PhoneController, style: TextStyle(color: Colors.white),
                      //           decoration: InputDecoration(hintText: "Your Phone Number",
                      //             errorText: _displayNameValid ? null : "Wrong Phone number format",
                      //           ),
                      //         ),
                      //       ),
                      //     ), decoration: BoxDecoration(border: Border.all(color: Colors.white70), borderRadius: BorderRadius.all(Radius.circular(20)),
                      //   ),
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20,5,20,4),
                        child: Container(
                          height: 60,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(controller: ICController, style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(hintText: "Your Identity Number",
                                  errorText: _displayNameValid ? null : "Wrong Identify Number format",
                                ),
                              ),
                            ),
                          ), decoration: BoxDecoration(border: Border.all(color: Colors.white70), borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        ),
                      ),
                      ElevatedButton(
                          // onPressed: updateProfileData,
                          onPressed: (){ updateProfileData(context); },
                      child: Text("Update",style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.bold),
                      ),
                      )
                    ],
                  ),
                ),
              ),
        ),
      ],
    );
  }
}

class Details {
  String email;
  String ic;
  String name;


  Details(this.email, this.name, this.ic);
  factory Details.fromMap(Map<String, dynamic> json) {
    return Details(
      json['email'],
      json['name'],
      json['ic'],
    );
  }
}