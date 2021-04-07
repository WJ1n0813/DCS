import 'dart:typed_data';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class BloodScreen extends StatefulWidget {
  @override
  _BloodScreenState createState() => _BloodScreenState();
}

class _BloodScreenState extends State<BloodScreen> {
  AuthUser _user;
  File _image;
  File _image2;
  String output;

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

  _imgFromCamera() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50
    );

    setState(() {
      _image = image;
    });
  }

  _imgFromGallery() async {
    File image = await  ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50
    );

    setState(() {
      _image = image;
    });
  }
  _imgFromCamera2() async {
    File image2 = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50
    );

    setState(() {
      _image2 = image2;
    });
  }

  _imgFromGallery2() async {
    File image2 = await  ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50
    );

    setState(() {
      _image2 = image2;
    });
  }
  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        }
    );
  }
  void _showPicker2(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery2();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera2();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  Upload(BuildContext context) async{
    UploadFileResult result = await Amplify.Storage.uploadFile(
        key: "Image1",
        local: _image
    );
    UploadFileResult result2 = await Amplify.Storage.uploadFile(
        key: "Image2",
        local: _image2
    );

    if (result.key.isNotEmpty && result2.key.isNotEmpty) {
      try {
        String item = '{"email":"' + _user.username + '"}';

        RestOptions options = RestOptions(
            path: '/Compare',
            // body: Uint8List.fromList('{\'name\':\'Mow the lawn\'}'.codeUnits)
            body: Uint8List.fromList(item.codeUnits)
        );
        RestOperation restOperation = Amplify.API.post(
            restOptions: options
        );
        RestResponse response = await restOperation.response;
        print('Compare call succeeded');
        setState(() {
          output = new String.fromCharCodes(response.data);
        });
        print(new String.fromCharCodes(response.data));
      } on ApiException catch (e) {
        setState(() {
          output = "Error Occured";
        });
        print('Compare call failed: $e');
      }

      showAlertDialog(context);
    }
  }

  Request(BuildContext context) async{
    try {
      String item = '{"email":"' + _user.username + '"}';
      RestOptions options = RestOptions(
          path: '/LambdaRequestReport ',
          // body: Uint8List.fromList('{\'name\':\'Mow the lawn\'}'.codeUnits)
          body: Uint8List.fromList(item.codeUnits)
      );
      RestOperation restOperation = Amplify.API.post(
          restOptions: options
      );
      RestResponse response = await restOperation.response;
      print('Compare call succeeded');
      setState(() {
        output = new String.fromCharCodes(response.data);
      });
      print(new String.fromCharCodes(response.data));
    } on ApiException catch (e) {
      setState(() {
        output = "Error Occured";
      });
      print('Compare call failed: $e');
    }

    showAlertDialog(context);
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget continueButton = TextButton(
      child: Text("Okay"),
      onPressed:  () {Navigator.pop(context);},
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Comparing"),
      content: Text(output),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blood Report'),
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
              if (_user == null)
                Text(
                  'Loading...',
                )
              else ...[
                Text(
                  'Hello 👋🏾',
                  style: Theme.of(context).textTheme.headline2,
                ),
                Text(_user.username),
                SizedBox(height: 10),
                Text(_user.userId),
              ],
              SizedBox(height: 50),
              Container(
                width: 150.0,
                height: 60.0,
                child: RaisedButton.icon(
                  onPressed: (){ Request(context); },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  label: Text('Post Request',
                    style: TextStyle(color: Colors.white),),
                  icon: Icon(Icons.post_add_rounded, color:Colors.white,),
                  textColor: Colors.white,
                  splashColor: Colors.green,
                  color: Colors.indigoAccent,),
              ),
              SizedBox(
                height: 32,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _showPicker(context);
                        },
                        child: _image != null
                            ? Container(
                          width: 150,
                          height: 150,
                          child: Image.file(
                            _image,
                            width: 150,
                            height: 150,
                            fit: BoxFit.fitHeight,
                          ),)
                            : Container(
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(50)),
                          width: 100,
                          height: 100,
                          child: Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      SizedBox(height: 10,),
                      Text("IC Pic",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),)
                    ],
                  ),
                    /*child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Color(0xffFDCF09),
                      child: _image != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.file(
                          _image,
                          width: 100,
                          height: 100,
                          fit: BoxFit.fitHeight,
                        ),
                      )
                          : Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(50)),
                        width: 100,
                        height: 100,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),*/
                  SizedBox(width: 40),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _showPicker2(context);
                        },
                        child: _image2 != null
                            ? Container(
                          width: 150,
                          height: 150,
                          child: Image.file(
                            _image2,
                            width: 150,
                            height: 150,
                            fit: BoxFit.fitHeight,
                          ),)
                            : Container(
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(50)),
                          width: 100,
                          height: 100,
                          child: Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      SizedBox(height: 10,),
                      Text("Profile Pic",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),)
                    ],
                  ),
                  ]

              ),
                  SizedBox(height: 20,),
                  Center(child: RaisedButton.icon(
                    onPressed: (){
                      Upload(context);
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    label: Text('Compare Pic',
                      style: TextStyle(color: Colors.black),),
                    icon: Icon(Icons.camera_alt_rounded, color:Colors.black,),
                    textColor: Colors.white,
                    splashColor: Colors.green,
                    color: Colors.amber,),)

                  /*GestureDetector(
                    onTap: () {
                      _showPicker2(context);
                    },
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Color(0xffFDCF09),
                      child: _image2 != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.file(
                          _image2,
                          width: 100,
                          height: 100,
                          fit: BoxFit.fitHeight,
                        ),
                      )
                          : Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(50)),
                        width: 100,
                        height: 100,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ),*/
                ],
              )
        ),
          ),
        );
  }
}