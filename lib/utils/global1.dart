import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Globals {
  const Globals._();

  static final auth = FirebaseAuth.instance;

  static User? get firebaseUser => auth.currentUser;

  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
}