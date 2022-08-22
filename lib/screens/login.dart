import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'FirstScreen.dart';
import 'LastScreen.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['profile', 'email']
);

class SignInDemo extends StatefulWidget {
  @override
  _SignInDemoState createState() => _SignInDemoState();
}
class _SignInDemoState extends State<SignInDemo> {
  var disable=true;
  GoogleSignInAccount _currentUser;



  final String assetName = 'assets/Vector.svg';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });
    }
    );
    _googleSignIn.signInSilently();
  }
  String storeDate;
  String today;

  Future<void> readStoreData() async {
    final prefs = await SharedPreferences.getInstance();
    storeDate = prefs.getString('TodayDate') ?? "";
    today = DateFormat("MMMM dd yyyy").format(DateTime.now());

  }
  @override
  Widget build(BuildContext context) {
    print('name is $_currentUser');
    if(_currentUser!=null) {
      readStoreData().then((value) async {
        print("name inside currentuser$_currentUser");
        if(today==storeDate){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LastScreen()));
        }
        else {
          if(_currentUser.email.toLowerCase().endsWith('@coffeebeans.io')) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>FirstScreen()));

          }
          else {
            showDialog(context: context, builder: (BuildContext context)=>_buildPopupDialog(context));
            await _googleSignIn.signOut();
          }
        }
      });
    }

    else {
      return Scaffold(
        body:Stack(
          children: [
            Positioned.fill(
              child: Container(
                child: Image(
                image: AssetImage("assets/loginpage.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            ),
            Positioned.fill(
              left: 30,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      margin: EdgeInsets.only(top: 150),
                      child: Image.asset('assets/logo.png', height: 120,)
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 70),
                    child: Text(
                      'Sign in with your CoffeeBeans \nemail to continue',
                      style: TextStyle(fontFamily: 'Montserrat',
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                        color: const Color(0xFFFFFFFF),

                      ),),

                  ),

                  Container(
                    margin: EdgeInsets.only(top: 20),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          fixedSize: const Size(330, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          )),
                      onPressed: () async {
                        await _handleSignIn();

                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/google.png', height: 38, width: 38,),
                          Text('SIGN IN', style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: const Color(0xFF757575),
                          ),),
                          // <-- Text
                          SizedBox(
                            width: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }


  Future<void> _handleSignIn() async {
    try {
      print("check login page");
      await _googleSignIn.signIn();


      // Position position = await _getGeoLocationPosition();
      // location =
      // 'Lat: ${position.latitude} , Long: ${position.longitude}';
      // GetAddressFromLatLong(position);
    } catch (error) {
      print(error);
    }
  }

  Widget _buildPopupDialog(BuildContext context) {
    return AlertDialog(

      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          Container(
              margin: EdgeInsets.only(top: 20),
              child: Text("Please Login With Coffeebeans GmailId.",
                style: TextStyle(fontSize: 18,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF553205)),)),

        ],
      ),
      actions: <Widget>[
        ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },

            child: Text("close", style: TextStyle(color: Colors.blue),)
          // child: const Text('Close'),

        ),
      ],
    );
  }




}
