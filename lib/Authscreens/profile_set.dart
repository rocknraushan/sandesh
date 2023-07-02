import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sandesh/Database/realtime_database_service.dart';
import 'package:sandesh/HomeScreen/homescreen.dart';
import 'package:sandesh/global/global.dart';
import 'package:sandesh/widgets/custom_text_field.dart';
import 'package:firebase_storage/firebase_storage.dart' as fstorage;

import '../models/profiledata.dart';

class SetProfile extends StatefulWidget {
  static const id = 'SetProfile';

  const SetProfile({super.key});
//ignore:
  @override
  _SetProfileState createState() => _SetProfileState();
}

class _SetProfileState extends State<SetProfile> {
  TextEditingController nameController = TextEditingController();

  bool isLoading = false;

  final String? userId = sharedPreferences?.getString('uid');
  final String? phoneNumber = sharedPreferences?.getString('phoneNumber');

//image picker
  XFile? imageXFile;
  final ImagePicker _picker = ImagePicker();

//seller image url
  String userImageUrl = "";

//function for getting image
  Future<void> _getImage() async {
    imageXFile = await _picker.pickImage(source: ImageSource.gallery);
    Fluttertoast.showToast(msg: phoneNumber!);
    Fluttertoast.showToast(msg: userId!);

    setState(() {
      imageXFile;
    });
  }

  Future<void> saveProfileData(String name) async {
    setState(() {
      isLoading = true;
    });
    //save user name to SharedPreference.
    await sharedPreferences!.setString("userName", name);

    //Saving profile image to firebase Storage
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    fstorage.Reference reference =
        fstorage.FirebaseStorage.instance.ref().child("users").child(fileName);
    fstorage.UploadTask uploadTask = reference.putFile(File(imageXFile!.path));
    fstorage.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
    await taskSnapshot.ref.getDownloadURL().then((url) async {
      userImageUrl = url;
    });

    //listing user to searchList
    FirebaseRealtimeDatabaseService rtdb = FirebaseRealtimeDatabaseService();
    rtdb.listToSearch(name, phoneNumber!);

    //Setting Profile info to the database.
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    ProfileData profileData =
        ProfileData(name: name, userid: userId!, dpUrl: userImageUrl, phoneNumber: phoneNumber!);
    await ref
        .child('users')
        .child(phoneNumber!)
        .child('profileData')
        .set(profileData.toJson())
        .then((value) {
      isLoading = false;
      Navigator.pushNamedAndRemoveUntil(
          context, HomeScreen.id, (route) => false);
    });
    // .then(() => Navigator.pushNamedAndRemoveUntil(context, HomeScreen.id, (route) => false));
    // frtdb.createUserWithPhone(phoneNumber!, userId!, name, userImageUrl)
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
if (kDebugMode) {
  print(phoneNumber);
}
    return MaterialApp(

      home: Scaffold(
        appBar: AppBar(
          title: const Text('WhatsApp'),
          backgroundColor: const Color.fromRGBO(0, 128, 106, 1),
          primary: true,
          actions: [
            // SizedBox(height: 40),

            IconButton(
              icon: const Icon(
                Icons.done_outline,
              ),
              onPressed: () {
                saveProfileData(nameController.text);
              },
            ),
          ],
        ),
        body: isLoading ? Container(
                     color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(),
             ),
        ) :
        SingleChildScrollView(
            child:

          Column(
            children: [
              const SizedBox(height: 20),
              Center(

                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  margin: const EdgeInsets.fromLTRB(25, 50, 25, 10),
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.center,
                  child: InkWell(
                    onTap: _getImage,
                    child: CircleAvatar(
                      radius: screenWidth * 0.20,
                      backgroundColor: const Color.fromRGBO(0, 128, 106, 120),
                      backgroundImage: imageXFile == null
                          ? null
                          : FileImage(
                              File(imageXFile!.path),
                            ),
                      child: imageXFile == null
                          ? const Icon(
                              Icons.person_add_alt_1,
                              // size: MediaQuery.of(context).size.width * 0.20,
                              color: Color.fromRGBO(0, 128, 106, 1),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              CustomTextField(
                controller: nameController,
                hintText: 'Name',
                data: Icons.account_circle,
                enabled: true,
                isObsecre: false,
              ),

            ],

          ),


            )),
      );
  }
}
