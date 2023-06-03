import 'package:flutter/material.dart';

class App_bar extends StatelessWidget{

  final String title;
  App_bar({required this.title});
  @override
  Widget build(BuildContext context) {

    return AppBar(
      title: Text(title) ,
    );
  }

}