import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'ScanScreen.dart';


GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['profile', 'email']);
class FirstScreen extends StatefulWidget {
  @override
  FirstScreenState createState() => FirstScreenState();
}

class FirstScreenState extends State<FirstScreen> {
  GoogleSignInAccount _currentUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently();
  }
  // String date = DateFormat("EEEEE, MMMM dd").format(DateTime.now());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 30,

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    child: Image.asset('assets/shelf2.png',height: 140,)),
              ],
            ),
          ),
          Positioned(
            top: 390,
            left: 30,
            child: Column(
              children: [
                Container(
                    child: Text("Hi, "+_currentUser.displayName?? '',style: TextStyle(fontSize: 22,color: const Color(0xFF3E2723),fontWeight:FontWeight.w700),)),
              ],
            ),
          ),
          Positioned(
            top: 420,
            left: 30,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Are you at the office today?",style: TextStyle(fontSize: 18,color: Colors.brown[300]),),
              ],
            ),
          ),

          Positioned(
            top: 470,
            left: 30,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                ElevatedButton(
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
                      SizedBox(
                        width: 5,
                      ),
                      SvgPicture.asset('assets/Vector.svg',height: 10,),
                      // Image.asset('assets/Vector.png',height: 20,)

                    ],
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
