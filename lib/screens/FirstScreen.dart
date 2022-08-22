import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'ScanScreen.dart';


GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['profile', 'email']);
class FirstScreen extends StatefulWidget {

  @override
  FirstScreenState createState() => FirstScreenState();
}

class FirstScreenState extends State<FirstScreen> {
  GoogleSignInAccount _currentUser;
  String location = 'Null, Press Button';
  String Address = 'search';
  LocationPermission permission;

  @override
  void initState()  {
    // TODO: implement initState
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) async {
      setState(() {
        _currentUser = account;
      });
        Position position = await _getGeoLocationPosition();
        location =
        'Lat: ${position.latitude} , Long: ${position.longitude}';
        GetAddressFromLatLong(position);
    });
    _googleSignIn.signInSilently();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      margin: EdgeInsets.only(),
                      child: Image.asset('assets/shelf2.png', height: 140,)
                  ),

                  Container(
                    margin: EdgeInsets.only(top: 225,left: 20),
                      child: Text("Hi, "+_currentUser.displayName?? '',style: TextStyle(fontSize: 22,color: const Color(0xFF3E2723),fontWeight:FontWeight.w700),)
                        ,
                      ),

                  Container(
                      margin: EdgeInsets.only(top: 10,left: 20),
                      child: Text("Are you at the office today?",style: TextStyle(fontSize: 18,color: Colors.brown[300]),
                  )
                  ),

                  Container(
                    margin: EdgeInsets.only(top: 30,left: 20),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.brown[900],
                          fixedSize: const Size(335, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4))),
                      onPressed: () {

                        Navigator.push(context, MaterialPageRoute(builder: (context)=>ScanScreen()));
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('CHECK IN',style: TextStyle(fontFamily: 'Montserrat',
                            fontStyle: FontStyle.normal,
                            fontWeight:FontWeight.w700 ,
                            fontSize: 16,
                            color:const Color(0xFFF6EEE3),
                          ),), // <-- Text
                          // SizedBox(
                          //   width: 5,
                          // ),
                          SvgPicture.asset('assets/Vector.svg',height: 10,),
                          // Image.asset('assets/Vector.png',height: 20,)
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
  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;

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
        showDialog(context: context, builder: (BuildContext context)=>_buildlocationPopupDialog(context));
        return Future.error('Location permissions are denied');
      }
      if (permission == LocationPermission.denied) {
        print("permission denied by user");
        showDialog(context: context, builder: (BuildContext context)=>_buildlocationPopupDialog(context));
        return Future.error('Location permissions are denied');
      }
    }
     if (permission == LocationPermission.deniedForever) {
      print("permission denied by user");
      showDialog(context: context, builder: (BuildContext context)=>_buildlocationPopupDialog(context));
      permission = await Geolocator.requestPermission();
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



  Widget _buildlocationPopupDialog(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          Container(
              margin: EdgeInsets.only(top: 10),
              child: Text("Permission required",style: TextStyle(fontSize: 18,fontStyle: FontStyle.normal,fontWeight: FontWeight.w700,color: Color(0xFF553205)),)),
          Container(
            margin: EdgeInsets.only(top: 16),
            child: Text("Please allow location access for marking your attendance accurately.",style: TextStyle(fontSize: 18,fontStyle: FontStyle.normal,fontWeight: FontWeight.w500,color: Color(0xFF553205)),)
          ),
          Container(
              margin: EdgeInsets.only(top: 16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: Colors.brown[900],
                  fixedSize: const Size(335, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4))),
              onPressed: () async{
                Navigator.of(context).pop();
                permission = await Geolocator.requestPermission();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Grant permission',style: TextStyle(fontFamily: 'Montserrat',
                    fontStyle: FontStyle.normal,
                    fontWeight:FontWeight.w700 ,
                    fontSize: 16,
                    color:const Color(0xFFF6EEE3),
                  ),), // <-- Text
                  SizedBox(
                    width: 5,
                  ),
                  // Image.asset('assets/Vector.png',height: 20,)

                ],
              ),
            ),
          )
        ],
      ),

    );
  }

}
