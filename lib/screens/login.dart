import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

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


    if(_currentUser!=null) {
      readStoreData().then((value){
        if(today==storeDate){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LastScreen()));
        }
        else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>FirstScreen()));
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
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (
                            context) => FirstScreen()));
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
      // showDialog(context: context, builder: (BuildContext context)=>_buildPopupDialog(context));

      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
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
      await _googleSignIn.signIn();
      Position position = await _getGeoLocationPosition();
      location =
      'Lat: ${position.latitude} , Long: ${position.longitude}';
      GetAddressFromLatLong(position);
    } catch (error) {
      print(error);
    }
  }
  // https://cbattendanceapp.herokuapp.com/employee/save
// Future<void> saveEmployeeData() {
//
//   var data =  http.post(Uri.parse("https://attendance-application-spring.herokuapp.com/employee/save"), headers:<String,String>{
//     'Content-Type': 'application/json;charset=UTF-8'
//   },
//     body:jsonEncode({
//       'email':_currentUser.email,
//       'name':_currentUser.displayName
//     }),
//
//   ).then((response) => print(response.body)).catchError((error) => print(error));
//
//   print(data);
//
// }

  // Widget _buildPopupDialog(BuildContext context) {
  //   return AlertDialog(
  //     content: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: <Widget>[
  //
  //         Container(
  //             margin: EdgeInsets.only(top: 20),
  //             child: Text("Permission required",style: TextStyle(fontSize: 18,fontStyle: FontStyle.normal,fontWeight: FontWeight.w900,color: Color(0xFF553205)),)),
  //         Container(
  //             margin: EdgeInsets.only(top: 16),
  //             child: Text("Please allow location access for marking your attendance accurately.",style: TextStyle(fontSize: 18,fontStyle: FontStyle.normal,fontWeight: FontWeight.w500,color: Color(0xFF553205)),)),
  //
  //       ],
  //     ),
  //     actions: <Widget>[
  //       FlatButton(
  //         onPressed: () {
  //           Navigator.of(context).pop();
  //         },
  //         textColor: Theme.of(context).primaryColor,
  //         child: const Text('Close'),
  //       ),
  //     ],
  //   );
  // }
}
