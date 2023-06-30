import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:sandesh/Database/realtime_database_service.dart';
import 'package:sandesh/widgets/custom_loaader.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/chatlist.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  //ignore: Invalid use of a private type in a public API
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _contactPhone;

  late String phoneNumber;
  Future<void> getPhone() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? savedPhone = preferences.getString('phoneNumber');
    setState(() {
      phoneNumber = savedPhone!;
    });
  }

  // final String? phoneNumber = sharedPreferences?.getString('phoneNumber');
  // final String Phone = phoneNumber!;
  FirebaseRealtimeDatabaseService rtdb = FirebaseRealtimeDatabaseService();

  @override
  void initState() {
    super.initState();
    getPhone();
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
                    controller: _nameController,
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
                IntlPhoneField(
                  autofocus: true,
                  invalidNumberMessage: 'Invalid Phone Number!',
                  textAlignVertical: TextAlignVertical.center,
                  style: const TextStyle(fontSize: 25),
                  onChanged: (phone) => _contactPhone = phone.completeNumber,
                  initialCountryCode: 'IN',
                  flagsButtonPadding: const EdgeInsets.only(right: 10),
                  showDropdownIcon: false,
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () async {
                    if(_contactPhone!=null) {
                      rtdb.addContact(_contactPhone!,
                            _nameController.text, myPhoneNumber)
                        .then((value) => Navigator.of(context).pop());
                    } else {
                      Fluttertoast.showToast(msg: "Please fill the field");
                    }
                  },
                  child: const Text(
                    "Add",
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
    DatabaseReference contactRef =
        FirebaseDatabase.instance.ref('users/$phoneNumber/contact');
// print(phoneNumber);

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          popUpDialog(context, phoneNumber);
        },
        elevation: 10,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: StreamBuilder(
        stream:contactRef.orderByKey().limitToLast(10).onValue,
        builder: (context, snapshot) {
          final tilesList = <ChatList>[];
          if (kDebugMode) {
            print('printed==$snapshot');
          }
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            final sData =
                snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            sData.forEach((key, value) {
              final nextData = value as Map<dynamic, dynamic>;
              if (kDebugMode) {
                print(phoneNumber);
              }
              // print(nextData);
              // print(snapshot.data!.snapshot.value.toString());
              // print(nextData['dpurl']);
              final newTile = ChatList.fromJson(nextData as Map<String, dynamic>);
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
