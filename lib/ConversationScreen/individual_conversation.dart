

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IndividualConversationScreen extends StatefulWidget{
  const IndividualConversationScreen({super.key, required this.roomId});
final String roomId;


  @override
  _IndividualState createState() => _IndividualState();

}

class _IndividualState extends State<IndividualConversationScreen>{
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(),

      ),
    );
  }

}