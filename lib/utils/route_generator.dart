import 'dart:developer';

import 'package:flutter/material.dart';

import '../Authscreens/authentication_screen.dart';
import '../Authscreens/profile_set.dart';
import '../HomeScreen/homescreen.dart';
import '../SplashScrren/splash_screen.dart';
import '../global/global.dart';
import 'package:sandesh/authscreens/verify_phone_number.dart';

class RouteGenerator {
  static const _id = 'RouteGenerator';
  final String? phoneNumber = sharedPreferences?.getString('phoneNumber');

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as dynamic;
    log(_id, name: "Pushed ${settings.name}(${args ?? ''})");
    switch (settings.name) {
      case SplashScreen.id:
        return _route(const SplashScreen());
      case AuthenticationScreen.id:
        return _route(const AuthenticationScreen());
      case VerifyPhoneNumberScreen.id:
        return _route(VerifyPhoneNumberScreen(phoneNumber: args));
      case HomeScreen.id:
        return _route(  HomeScreen());
      case SetProfile.id:
        return _route( const SetProfile());
      default:
        return _errorRoute(settings.name);
    }
  }

  static MaterialPageRoute _route(Widget widget) =>
      MaterialPageRoute(builder: (context) => widget);

  static Route<dynamic> _errorRoute(String? name) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text('ROUTE \n\n$name\n\nNOT FOUND'),
        ),
      ),
    );
  }
}