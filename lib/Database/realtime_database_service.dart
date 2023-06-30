
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:sandesh/models/profiledata.dart';

class FirebaseRealtimeDatabaseService {
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref().child('users');
  final DatabaseReference _roomRef = FirebaseDatabase.instance.ref().child('rooms');
  final DatabaseReference _messagesRef = FirebaseDatabase.instance.ref('chats');
  final DatabaseReference _groupRef =  FirebaseDatabase.instance.ref().child('groups');
  
  Future<void> createUserWithPhone(String phone, String userid, String username, String? dpurl) async{
    await _usersRef.child(phone).child('profileData').set(ProfileData(name: username,userid: userid,dpUrl:dpurl!, phoneNumber: phone ));
  }

  Future<void> createChatRoom(String phone1, String phone2) async{
    DatabaseReference key = _roomRef.push();
    await key.set({
      phone1: true,
      phone2: true,
    }).then((value) async {
      await _usersRef.child(phone1).child('contact').child(phone2).child('room_id').set(key.key);
     await _usersRef.child(phone2).child('contact').child(phone1).child('room_id').set(key.key);
    });

  }

  Future<void> updateUserOnlineStatus(String userId, bool onlineStatus) async {
    await _usersRef.child(userId).child('online_status').set(onlineStatus);
  }

  Future<void> updateUserTypingStatus(String userId, bool typingStatus) async {
    await _usersRef.child(userId).child('typing_status').set(typingStatus);
  }

  Future<void> updateLastActiveTimestamp(String userId, int timestamp) async {
    await _usersRef.child(userId).child('last_active').set(timestamp);
  }

  Stream<DatabaseEvent> listenToUserOnlineStatus(String userId) {
    return _usersRef.child(userId).child('online_status').onValue;
  }

  Stream<DatabaseEvent> listenToUserTypingStatus(String userId) {
    return _usersRef.child(userId).child('typing_status').onValue;
  }

  Stream<DatabaseEvent> listenToUserLastActiveTimestamp(String userId) {
    return _usersRef.child(userId).child('last_active').onValue;
  }
  //
  Future<void> sendMessage(String roomId, String senderId, String content, int timestamp) async {
    DatabaseReference newMessageRef = _messagesRef.push();
    String? chatId = newMessageRef.key;
    await newMessageRef.set({
      'sender_id': senderId,
      'content': content,
      'timestamp': timestamp,
      'status': 'sent',
    }).then(
            (value) async =>
            await _roomRef.child('$roomId/chat_list/$chatId')
                .set(true));
  }
  
  Future<void> addContact(String contactPhone, String name, String myPhoneNumber)async {
    // final DataSnapshot snapshot = await _usersRef.child(phoneNumber).get();
      String? dpurl;
     await _usersRef.child(contactPhone).child("profileData").orderByKey().get().then((DataSnapshot snapshot) {
        if (snapshot.value != null) {
         dpurl = snapshot.child('dpurl').value?.toString();
          // final uid = snapshot.value!['uid']?? "";
          // Use the name value as needed
          if (kDebugMode) {
            print(snapshot.child('dpurl').value?.toString());
          }
        }
      }).catchError((error) {
        if (kDebugMode) {
          print('Error retrieving data: $error');
        }
      });

      String? myDpUrl;
      String? myName;
     await _usersRef.child(myPhoneNumber).child("profileData").orderByKey().get().then((DataSnapshot snapshot) {
        if (snapshot.value != null) {
          myDpUrl = snapshot.child('dpurl').value?.toString();
          myName = snapshot.child('name').value?.toString();
          // final uid = snapshot.value!['uid']?? "";
          // Use the name value as needed
        }
      }).catchError((error) {
        if (kDebugMode) {
          print('Error retrieving data: $error');
        }
      });
      final roomKey =
              "$myPhoneNumber%$contactPhone";
     await _roomRef.child(roomKey).set({
        contactPhone: true,
        myPhoneNumber:true,
        "chat_ids": [],
        "group": false
      });


      await _usersRef.child(myPhoneNumber).child("contact").child(contactPhone).set({

        "typing_status": false,
        "online_status": false,
        "last_message": "",
        "latest_chatId": "",
        "dpurl": dpurl ?? "",
        "message_count": 0,
        "room_id":roomKey,
        "name": name
      });


   await _usersRef.child(contactPhone).child("contact").child(myPhoneNumber).set({

      "typing_status": false,
      "online_status": false,
      "last_message": "",
     "latest_chatId": "",
      "dpurl": myDpUrl ?? "",
     "message_count": 0,
     "room_id":roomKey,
     "name": myName
    });
  }

  Stream<DatabaseEvent> listenUserContacts(String phoneNumber){
    return _usersRef.child("$phoneNumber/contact").onValue;
  }


  Future<void> updateMessageStatus(String chatId, String messageId, String status) async {
    await _messagesRef.child(chatId).child(messageId).child('status').set(status);
  }

  Stream<DatabaseEvent> listenToChatMessage(String chatId) {
    return _messagesRef.child(chatId).child('message').onValue;
  }

  Stream<DatabaseEvent> listenToChatMessageTimestamp(String chatId) {
    return _messagesRef.child(chatId).child('timestamp').onValue;
  }
}
