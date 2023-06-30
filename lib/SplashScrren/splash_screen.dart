import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sandesh/authscreens/authentication_screen.dart';
import 'package:sandesh/utils/global1.dart';

import '../HomeScreen/homescreen.dart';



class SplashScreen extends StatefulWidget {
  static const id = 'SplashScreen';
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();

}


class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin{


  startTimer(){
    Timer(
      const Duration(seconds: 5),
        () async {
          final isLoggedIn = Globals.auth.currentUser != null;
         // await ref.child('users').set({
         //    'name' : 'raushan'
         //  });
         // await ref.child('users/user1').set({
         //    'msg': 'working!'
         //  });
            Navigator.pushReplacementNamed(context,
                isLoggedIn ? HomeScreen.id : AuthenticationScreen.id);
          }

    );
  }
  @override
  void initState() {
    // TODO: implement initState
    startTimer();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
   return Center(
     child: Lottie.asset(
       'assets/Lottie/chatAnimation.json',
           fit: BoxFit.cover
     ),
   );
  }
}