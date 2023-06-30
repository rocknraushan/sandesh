

import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:flutter/material.dart';
import 'package:sandesh/SplashScrren/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sandesh/utils/app_theme.dart';
import 'package:sandesh/utils/global1.dart';
import 'package:sandesh/utils/route_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
  );
    runApp(MainApp(sharedPreferences: sharedPreferences));
  // runApp(const MainApp());
}

class MainApp extends StatelessWidget{
  // const MainApp({super.key});
  const MainApp({super.key, required this.sharedPreferences});
  final SharedPreferences sharedPreferences;


  @override
  Widget build(BuildContext context) {
    return FirebasePhoneAuthProvider(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FirebasePhoneAuthHandler Demo',
        scaffoldMessengerKey: Globals.scaffoldMessengerKey,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        onGenerateRoute: RouteGenerator.generateRoute,
        initialRoute: SplashScreen.id,
      ),
    );


    //
    // return  MaterialApp(
    //   title: 'testing',
    //   home: HomeScreen(),
    // );
  }
  
}
