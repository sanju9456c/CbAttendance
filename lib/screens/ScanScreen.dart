import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'LastScreen.dart';
GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['profile', 'email']);

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>  {

  GoogleSignInAccount _currentUser;
  var qrstr = " ";
  bool scanButtonDisable=true;
  bool submitButtonDisable=false;

  bool checkboxImageDisable=false;
  bool scanImageDisable=false;
  bool failqrcode=false;
  bool hightemp=false;

  String location = 'Null, Press Button';
  String Address = 'search';
  TextEditingController Textcontroller = TextEditingController();
  String qrcode;
  var listdata;
  var data;
  String localdate = DateFormat("EEEEE, MMMM, dd").format(DateTime.now());
  var apidate;

  var enable;

  @override
  void initState() {
    super.initState();
    // _fetchPost();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser=account;
      });
    });
    _googleSignIn.signInSilently();

    Textcontroller.addListener(() {
      enable=Textcontroller.text.isNotEmpty;
      setState(() {

      });

    });

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 30,
            child: Column(
              children: [
                Container(
                    margin: EdgeInsets.only(),
                    child: Image.asset('assets/shelf2.png',height: 140,)),
              ],
            ),
          ),
          Positioned(
            left: 30,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(top:250),
                  child: Text('Check in',style: TextStyle(fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF553205)),),
                ),
              ],
            ),
          ),
          Positioned(
            left: 30,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top:310),
                  child: Text('Record your body temperature',style: TextStyle(fontFamily: 'Montserrat',
                    fontStyle: FontStyle.normal,
                    fontWeight:FontWeight.w500 ,
                    fontSize: 18,
                    color:const Color(0xFF553205),
                  ),),
                )
              ],
            ),
          ),

          Positioned(
            left: 30,
            width: 150,
            child: Container(
              margin: EdgeInsets.only(top:350,),
              child: TextField(
                  controller : Textcontroller,

                  style: TextStyle(fontSize: 16,height:1,fontWeight: FontWeight.bold,color: const Color(0xFF553205) ),

                  decoration:
                  InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF553205),width: 3),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: const  BorderSide(color: const Color(0xFF553205),width: 3),
                    ),
                    prefixText: "\t",
                    suffixIcon:Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text("°F",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700,
                          color: const Color(0xFFCAB9A3)),),
                    ),
                  ),
                  onSubmitted: (String value){
                    if (double.parse(value)>= 90 && double.parse(value) <=100) {
                      checkboxImageDisable = true;
                      hightemp=false;
                      print("check range temperature");
                    }
                    else if(double.parse(value)>100){
                      checkboxImageDisable=false;
                      showDialog(context: context, builder: (BuildContext context)=>_buildPopupDialog(context));
                    }
                    else {
                      print("check temperature out of range");
                      showDialog(context: context, builder: (BuildContext context)=>_buildPopupDialog(context));
                    }
                  },
                  keyboardType: TextInputType.numberWithOptions(decimal: true),

                  onChanged: (String value) {
                    try {
                      if(Textcontroller.text.isEmpty){
                        checkboxImageDisable=false;
                        hightemp=false;
                      }
                      else if (int.parse(value) >= 90 && int.parse(value) <=100) {
                        checkboxImageDisable = true;
                        hightemp=false;
                        print("check range temperature");
                      }
                      else if(int.parse(value)>100){
                        checkboxImageDisable=false;
                        // showDialog(context: context, builder: (BuildContext context)=>_buildPopupDialog(context));

                      }
                      // // else if(int.parse(value)<90) {
                      // //   checkboxImageDisable=false;
                      // //   showDialog(context: context, builder: (BuildContext context)=>_buildPopupDialog(context));
                      // //
                      // // }
                    }
                    catch (e) {}
                  }

              ),
            ),
          ),

          // textfeild check image
          Positioned(
            left: 190,
            child: Column(
              children: [
                GestureDetector(
                  child: Visibility(
                    visible: checkboxImageDisable,
                    child: Container(
                      margin: EdgeInsets.only(top:360),
                      child: Image(
                          image: Image.asset("assets/small-check.png").image
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          //out of range temp value
          Positioned(
            left: 190,
            child: Column(
              children: [
                GestureDetector(
                  child: Visibility(
                    visible: hightemp,
                    child: Container(
                      margin: EdgeInsets.only(top:360),
                      child: Image(
                          image: Image.asset("assets/fail.png").image
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            left: 30,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top:430),
                  child: Text('Scan the QR code at the entrance',style :TextStyle(fontFamily: 'Montserrat',
                    fontStyle: FontStyle.normal,
                    fontWeight:FontWeight.w500 ,
                    fontSize: 18,
                    color:const Color(0xFF553205),
                  )),
                )
              ],
            ),
          ),
          Positioned(
            left: 30,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top:470),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: const Color(  0xFFE9CFAB),
                        fixedSize: const Size(150, 50),
                        onSurface:const Color.fromRGBO(255, 179, 102, 1),
                      ),
                      onPressed:scanButtonDisable?() {
                        setState(()=>scanButtonDisable=true);
                        _fetchPost();
                        scanQr();
                      }:null,
                      child:
                      Text(scanButtonDisable ? ('SCAN') : ('SCANNED'),style: TextStyle(fontWeight: FontWeight.w700,fontSize: 16,  color: scanButtonDisable ? const Color(0xFF654113):const Color(0xFFC0A17A),),)),
                ),
              ],
            ),
          ),

          // scan check image
          Positioned(
            left: 190,
            child: Column(
              children: [
                GestureDetector(
                  child:Visibility(
                    visible: scanImageDisable,
                    child: Container(
                      margin: EdgeInsets.only(top:480),
                      child: Image(
                        image: Image.asset("assets/small-check.png").image,
                      ),
                    ),
                  ),

                ),
              ],
            ),
          ),

          Positioned(
            top: 490,
            left: 190,
            child: Column(
              children: [
                GestureDetector(
                  child:Visibility(
                    visible: failqrcode,
                    child: Image(
                      image: Image.asset("assets/fail.png").image,
                    ),
                  ),

                ),
              ],
            ),
          ),

          Positioned(
            top: 490,
            left: 210,
            child: Column(
              children: [
                Text(qrstr,style: TextStyle(color:const Color(0xFF553205),fontSize: 13,fontWeight: FontWeight.w400),),
              ],
            ),
          ),
          Positioned(
            top: 570,
            left: 30,
            child: Column(
              children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(primary:Color(0xFF422501),fixedSize: const Size(340, 50),),
                    onPressed:(checkboxImageDisable && scanImageDisable)? () async {
                      setState(()=>submitButtonDisable=false);
                      await saveAttendanceData();
                      await saveTodayDate();
                      // Navigator.push(context, MaterialPageRoute(builder: (context)=>LastScreen()));
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>LastScreen()),(route) => false);

                    }:null, child: Text("DONE",style: TextStyle(fontFamily:'Montserrat',fontStyle: FontStyle.normal ,color: const Color(0xFFF6EEE3),fontWeight: FontWeight.w700,fontSize: 16),)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _data;


  Future _fetchPost() async  {
    print('print 1');
    http.Response response = await http.get(Uri.parse("https://cbattendanceapp.herokuapp.com/qrcode/uniqueId"));
    setState(() {
      _data = jsonEncode(response.body.toString());
      print("api data is: "+_data.toString());

    });
    return "Success";
  }


  Future <void>scanQr()async{
    try {

      FlutterBarcodeScanner.scanBarcode('#2A99CF', 'cancel', true, ScanMode.QR)
          .then((value) async {
        setState(() {

          print("camera reading value is :  $value");
        });

        print("qrcode data is "+_data.toString());


        if(value=="-1") {
          failqrcode=false;
          Text(qrstr=" ");
        }
        else if(value==_data) {
          print("main qrcode string");
          scanButtonDisable=false;
          scanImageDisable=true;
          failqrcode=false;
          Text(qrstr=" ");
          // scanImageDisable=!scanImageDisable;
        }
        else if(value!=_data) {
          await _fetchPost();
          print("update string value");
          print("new api string :"+_data);
          if(value==_data){
            scanButtonDisable=false;
            scanImageDisable=true;
            failqrcode=false;
            Text(qrstr=" ");

          }
          else {
            Text(qrstr="Invalid QR. Please retry.");
            submitButtonDisable=false;
            failqrcode=true;
          }
        }
        else {
          Text(qrstr="Invalid QR. Please retry.");
          submitButtonDisable=false;
          failqrcode=true;
        }
      });
    }
    catch(e){
      setState(() {
        qrstr='unable to read this';
      });
    }
  }


  Future<void> saveTodayDate() async {
    final prefs = await SharedPreferences.getInstance();
    String date = DateFormat("MMMM dd yyyy").format(DateTime.now());
// set value
    await prefs.setString('TodayDate', date);
    print("check store data in dateformat :$date");
  }



  Future saveAttendanceData() async {
    print("check save data in database or not ");
    Position position = await _getGeoLocationPosition();
    data =  http.post(Uri.parse("https://cbattendanceapp.herokuapp.com/attendance/save"), headers:<String,String>{
      'Content-Type': 'application/json;charset=UTF-8'
    },
      body:jsonEncode({
        'email' : _currentUser.email,
        'temperature' : Textcontroller.text,
        'longitude' : position.longitude,
        'latitude' : position.latitude,
      }),
    ).then((response) => print(response.body)).catchError((error) => print(error));
    print('json data : '+data.toString());
    print("save data in json format");
  }

  Widget _buildPopupDialog(BuildContext context) {
    return AlertDialog(

      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              margin: EdgeInsets.only(left:100),
              child: Image.asset('assets/yellow.png', height: 67, width: 67,)),
          Container(
              margin: EdgeInsets.only(top: 20),
              child: Text("Your body temperature is outside the safe range.",style: TextStyle(fontSize: 18,fontStyle: FontStyle.normal,fontWeight: FontWeight.w500,color: Color(0xFF553205)),)),
          Container(
              margin: EdgeInsets.only(top: 16),
              child: Text("Please contact the People Team for further guidance.",style: TextStyle(fontSize: 18,fontStyle: FontStyle.normal,fontWeight: FontWeight.w700,color: Color(0xFF553205)),)),

        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },

            child: Text("close",style: TextStyle(color: Colors.blue),)
          // child: const Text('Close'),

        ),
      ],
    );
  }
}
