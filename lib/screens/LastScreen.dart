import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
class LastScreen extends StatefulWidget {
  @override
  LastScreenState createState() => LastScreenState();
}
class LastScreenState extends State<LastScreen> {
  @override
  void initState() {
// TODO: implement initState
    super.initState();
  }
  String date = DateFormat("EEEEE, MMMM dd").format(DateTime.now());
  @override
  Widget build(BuildContext context) {
//
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 30,
            child: Column(
              children: [
                Container(
                    child: Image.asset('assets/shelf2.png')),
              ],
            ),
          ),
          Positioned(
            left: 85,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    margin: EdgeInsets.only(top: 300,),
                    child: Image.asset('assets/big-check.png',height: 80,width: 80,)),
                Container(
                  margin: EdgeInsets.only(top: 24),
                  child: Text('Attendance marked',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Montserrat',color: const Color(0xFF553205),
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),),
                ),
                Text(date,style: TextStyle(fontWeight: FontWeight.w500,color:const Color(0xFFA1887F),fontSize: 18,
                ),),
              ],
            ),
          ),
        ],
      ),
    );
  }
}