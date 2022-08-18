import 'dart:convert';
import 'package:attendanceapp/main.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
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


  String location = 'Null, Press Button';
  String Address = 'search';
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
            Position position = await _getGeoLocationPosition();
            location =
            'Lat: ${position.latitude} , Long: ${position.longitude}';
            GetAddressFromLatLong(position);
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
        body: Stack(
          children: [
            Positioned.fill(child: Image(
              image: AssetImage("assets/loginpage.jpg"),
              fit: BoxFit.cover,
            ),
            ),
            Positioned(
              left: 30,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {

      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        print("permission denied by user");
        return showDialog(context: context, builder: (BuildContext context)=>_buildPopupDialog(context));

        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> GetAddressFromLatLong(Position position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, position.longitude);
    print(placemarks);
    Placemark place = placemarks[0];
    Address = '${place.street}, ${place.subLocality}, ${place.locality}, ${place
        .postalCode}, ${place.country}';
    setState(() {});
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
              child: Text("Login with coffeebeans Gmail ID",style: TextStyle(fontSize: 18,fontStyle: FontStyle.normal,fontWeight: FontWeight.w900,color: Color(0xFF553205)),)),
          Container(
              margin: EdgeInsets.only(top: 16),
              // child: Text("Please allow location access for marking your attendance accurately.",style: TextStyle(fontSize: 18,fontStyle: FontStyle.normal,fontWeight: FontWeight.w500,color: Color(0xFF553205)),)),
          ),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () async {
            // Navigator.of(context).pop();
            Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>SignInDemo()));

          },
          child: const Text('Close'),
        ),
      ],
    );
  }



}
