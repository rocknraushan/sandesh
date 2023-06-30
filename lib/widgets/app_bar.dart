import 'package:flutter/material.dart';

class App_Bar extends StatelessWidget implements PreferredSizeWidget {
  final PreferredSizeWidget? bottom;
  final String title;
  const App_Bar({super.key, required this.title, this.bottom});
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => bottom == null
      ? Size(56, AppBar().preferredSize.height)
      : Size(56, 80 + AppBar().preferredSize.height);
}
