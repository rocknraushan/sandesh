

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sandesh/Database/realtime_database_service.dart';
import 'package:sandesh/widgets/group_chat_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/custom_loaader.dart';

class GroupScreen extends StatefulWidget{
  @override
  _GroupState createState() => _GroupState();

}

class _GroupState extends State<GroupScreen>{
  FirebaseRealtimeDatabaseService rtdb = FirebaseRealtimeDatabaseService();
  String? phoneNumber;
  final TextEditingController _groupNameController = TextEditingController();
  //getting userPhone
  Future<void> getPhone() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? savedPhone = preferences.getString('phoneNumber');
    setState(() {
      phoneNumber = savedPhone!;
    });
  }

  @override
  void initState() {
    getPhone();
    super.initState();
  }

  popUpDialog(BuildContext context, String myPhoneNumber) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: const Color.fromRGBO(0, 128, 106, 1),
            title: const Text(
              "Add Contact",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            content: Column(
              children: [
                TextField(
                    controller: _groupNameController,
                    decoration: InputDecoration(
                      hintText: "Name",
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color.fromRGBO(0, 128, 106, 1),
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.red,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color.fromRGBO(0, 128, 106, 1),
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    )),
                const SizedBox(
                  height: 20,
                ),

              ],
            ),
            actions: [
              TextButton(
                  onPressed: () async {
                    if(_groupNameController.text.isNotEmpty) {
                      rtdb.createGroup(phoneNumber!, _groupNameController.text, "")
                          .then((value) => Navigator.of(context).pop());
                    } else {
                      Fluttertoast.showToast(msg: "Please fill the field");
                    }
                  },
                  child: const Text(
                    "Create New",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    DatabaseReference groupRef =
    FirebaseDatabase.instance.ref('users/$phoneNumber/groups');
// print(phoneNumber);
    final DatabaseReference _groupRef = FirebaseDatabase.instance.ref('users/$phoneNumber/groups');


    //building dialog to create group:



    return Scaffold(
      backgroundColor: Colors.grey.shade900,

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          popUpDialog(context, phoneNumber!);
        },
        elevation: 10,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),

      body: StreamBuilder(
        stream:_groupRef.onValue,
        builder: (context, snapshot) {
          final tilesList = <GroupChatItem>[];
          if (kDebugMode) {
            print('printed==$snapshot');
          }
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            final sData =
            snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            sData.forEach((key, value) {
              final json = value as Map<dynamic, dynamic>;
              if (kDebugMode) {
                print(phoneNumber);
              }
             if (kDebugMode) {
               print("icon url -------  ${json['iconUrl']}");
             }
              // print(nextData);
              // print(snapshot.data!.snapshot.value.toString());
              // print(nextData['dpurl']);
              final newTile = GroupChatItem.fromJson(json);
              // ChatList(
              //   username: nextData['name'],
              //   profileImgUrl: nextData['dpurl'],
              //   message_count: nextData['message_count'] ?? 0,
              //   lastMsgTime: "lsfjjs",
              //   message: "sfjlajsf", room_id: nextData['room_id'],
              //
              // );
              tilesList.add(newTile);
            });
          } else {
            return const Center(child: CustomLoader(color: Colors.grey,));
          }
          return ListView(
            children: tilesList,

          );
          // Return your widget with tilesList
          // ...
        },
      ),
    );
  }

}