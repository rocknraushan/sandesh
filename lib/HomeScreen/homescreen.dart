// import 'dart:js';

import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sandesh/HomeScreen/chat_screen.dart';
import 'package:sandesh/SearchScreen/search_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'group_screen.dart';

class HomeScreen extends StatefulWidget {
  static const id = 'HomeScreen';
  const HomeScreen({super.key});
  //ignore: Invalid use of a private type in a public API
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
      String profilePic ="";
  final DatabaseReference _userRef = FirebaseDatabase.instance.ref('users');
  @override
  void initState() {
    super.initState();
    getFromSharedPref();
    _tabController = TabController(length: screens.length, vsync: this);

  }

  late String phoneNumber;
  late String? userName;

  Future<void> getFromSharedPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? savedPhone = preferences.getString('phoneNumber');
    String? saveduserName = preferences.getString("userName");
    setState(() {
      phoneNumber = savedPhone!;
      userName = saveduserName!;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  void getProfilepic(String myId) async{
    // print(myId);
    // print('inside profile');
    var picUrl = await _userRef.child("$myId/profileData/dpurl").once();
    // print(picUrl.snapshot.value);
     setState(() {
       profilePic = picUrl.snapshot.value.toString();
     });
  }

  late List<Widget> screens = [const ChatScreen(), GroupScreen()];

  @override
  Widget build(BuildContext context) {
    // if (kDebugMode) {
    //   print("user==$userName");
    // }
    getProfilepic(phoneNumber);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Sandesh',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 2,
        backgroundColor: const Color.fromRGBO(0, 128, 106, 1),
        primary: true,
        bottom: TabBar(controller: _tabController, tabs: const [
          Tab(
              icon: Icon(
            Icons.chat,
          )),
          Tab(
            icon: Icon(Icons.group),
          )
        ]),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
          const SizedBox(
            width: 20,
          ),
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SearchScreen()));
            },
          ),
          const SizedBox(
            width: 20,
          ),
          const Icon(
            Icons.more_vert,
            color: Colors.white,
          )
        ],
      ),
      drawer: Drawer(
        elevation: 0,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50),
          children: <Widget>[

            (profilePic != "")
               ?  CircleAvatar(
                radius: 100, backgroundImage: NetworkImage(profilePic))
:
            Icon(
              Icons.account_circle,
              size: 150,
              color: Colors.grey[700],

            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              userName!,
              style:
                  const TextStyle(color: Colors.green,
                      fontWeight: FontWeight.w800,
                  fontSize: 40),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: screens,
      ),
    );
  }
}
