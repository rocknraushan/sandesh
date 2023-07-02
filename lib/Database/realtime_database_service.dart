import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:sandesh/models/profiledata.dart';

class FirebaseRealtimeDatabaseService {
  final DatabaseReference _usersRef =
      FirebaseDatabase.instance.ref().child('users');
  final DatabaseReference _roomRef =
      FirebaseDatabase.instance.ref().child('rooms');
  final DatabaseReference _groupRef =
      FirebaseDatabase.instance.ref().child('groups');
  final DatabaseReference _searchRef =
      FirebaseDatabase.instance.ref().child('search');

  Future<void> createUserWithPhone(
      String phone, String userid, String username, String? dpurl) async {
    await _usersRef.child(phone).child('profileData').set(ProfileData(
        name: username, userid: userid, dpUrl: dpurl!, phoneNumber: phone));
  }

  Future<void> createChatRoom(String phone1, String phone2) async {
    DatabaseReference key = _roomRef.push();
    await key.set({
      phone1: true,
      phone2: true,
    }).then((value) async {
      await _usersRef
          .child(phone1)
          .child('contact')
          .child(phone2)
          .child('room_id')
          .set(key.key);
      await _usersRef
          .child(phone2)
          .child('contact')
          .child(phone1)
          .child('room_id')
          .set(key.key);
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

  Future<void> sendMessage(
    String roomId,
    String senderId,
    String content,
      String receiverId
  ) async {
    DatabaseReference newMessageRef =
        _roomRef.child('$roomId/chat_list').push();
    String? chatId = newMessageRef.key;
    String time = DateTime.now().toString();
    await newMessageRef.set({
      'sender_id': senderId,
      'content': content,
      'timestamp': time,
      'status': 'sent',
    }).then((value) async {
      // DatabaseReference ref = FirebaseDatabase.instance.ref("posts/123");
     DatabaseReference contactNode = _usersRef.child("$receiverId/contact/$senderId");

      TransactionResult result = await contactNode.runTransaction((Object? message_count) {
        // Ensure a post at the ref exists.
        if (message_count == null) {
          return Transaction.abort();
        }

        Map<String, dynamic> _newCount = Map<String, dynamic>.from(message_count as Map);
        _newCount['message_count'] = (_newCount['message_count'] ?? 0) + 1;

        // Return the new data.
        return Transaction.success(_newCount);
      });
      await contactNode.update({
        "latest_messageTime" : time,
        "latest_chatId" : chatId,
        "message" : content

      });

    });
    // .then(
    //     (value) async {
    //
    //     // Retrieve the current value from the Realtime Database
    //     // databaseReference.child('your_node').once().then((DataSnapshot snapshot) {
    //     //   int currentValue = snapshot.value ?? 0;
    //     //
    //     //   // Increment the retrieved value by one
    //     //   int incrementedValue = currentValue + 1;
    //     //
    //     //   // Update the incremented value back to the Realtime Database
    //     //   databaseReference.child('your_node').set(incrementedValue);
    //     // await _usersRef.child(senderId).child('contact').child("last_message").set(content);
    //     // await _usersRef.child(senderId).child('contact').child("latest_messageTime").set(timestamp);
    //
    //     });
  }

  Future<void> addContact(
      String contactPhone, String name, String myPhoneNumber) async {
    // final DataSnapshot snapshot = await _usersRef.child(phoneNumber).get();
    String? dpurl;
    await _usersRef
        .child(contactPhone)
        .child("profileData")
        .orderByKey()
        .get()
        .then((DataSnapshot snapshot) {
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
    await _usersRef
        .child(myPhoneNumber)
        .child("profileData")
        .orderByKey()
        .get()
        .then((DataSnapshot snapshot) {
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
    final roomKey = "$myPhoneNumber%$contactPhone";
    await _roomRef.child(roomKey).set({
      // contactPhone: true,
      // myPhoneNumber:true,
      "chat_ids": [],
    });

    await _usersRef
        .child(myPhoneNumber)
        .child("contact")
        .child(contactPhone)
        .set({
      "typing_status": false,
      "online_status": false,
      "last_message": "",
      "latest_messageTime": "",
      "dpurl": dpurl ?? "",
      "message_count": 0,
      "room_id": roomKey,
      "name": name,
      "phoneNumber": contactPhone,
      "message" : ""
    });

    await _usersRef
        .child(contactPhone)
        .child("contact")
        .child(myPhoneNumber)
        .set({
      "typing_status": false,
      "online_status": false,
      "latest_messageTime": "",
      "latest_chatId": "",
      "dpurl": myDpUrl ?? "",
      "message_count": 0,
      "room_id": roomKey,
      "name": myName,
      "phoneNumber": myPhoneNumber,
      "message" : ""
    });
    sendMessage(roomKey, myPhoneNumber, "", contactPhone);
  }

  Stream<DatabaseEvent> listenUserContacts(String phoneNumber) {
    return _usersRef.child("$phoneNumber/contact").onValue;
  }

  Future<void> updateMessageStatus(
      String chatId, String roomId, String status) async {
    await _roomRef
        .child(roomId)
        .child('chat_list/$chatId')
       .update({"status" : status});
  }
Future<void> updateMsgCounterToZero(String senderId, String myId)async {
    DatabaseReference contactRef = _usersRef.child("$myId/contact/$senderId");

    TransactionResult result = await contactRef.runTransaction((Object? messageCount) {
      // Ensure a post at the ref exists.
      if (messageCount == null) {
        return Transaction.abort();
      }

      Map<String, dynamic> newCount = Map<String, dynamic>.from(messageCount as Map);
      newCount['message_count'] = 0;

      // Return the new data.
      return Transaction.success(newCount);
    });
}


  //Methods for Groups conversations

  Future<void> listToSearch(String userName, String phone) async {
    await _searchRef.child(userName).set(phone);
    await _searchRef.child(phone).set(true);
  }

// List<InfoCard> fetchedResult(String info) async{
//      dynamic data = await _searchRef.get();
// }

  Future<void> createGroup(String adminId, String groupName, String groupIconUrl) async {
    var key = _groupRef.push().key;
    _groupRef.child(key!).set({
      "members" : {adminId: true},
      "iconUrl": "",
      "group_name": groupName,
      "admin": adminId,
      "roomId": key,
      "latestMessage" : "",
      "messageTime" : "",
      "senderName" : ""
    }).then((value) async {
      await _usersRef.child('$adminId/groups/$key').set({

          "groupId": key,
          "lastMessage": "",
          "lastSenderName": "",
          "lastTimeStamp": "",
          "msgCount": 0,
          "iconUrl": "",
          "groupName": groupName

      });
      await _searchRef.child(key).set({
        "groupName" : groupName,
        "groupId" : key,
        "groupIconUrl" : groupIconUrl
      });
      // await _roomRef.child(key).set({
      //   // "admin": adminId,
      // });
    });
    sendMessageToGroup(key, adminId, "", "");
  }

  Future<void> sendMessageToGroup(
      String roomId, String senderId, String content, String senderName) async {
    DatabaseReference newMessageRef = _roomRef.child('$roomId/chatList').push();
    String? chatId = newMessageRef.key;
    String time =  DateTime.now().toString();
    await newMessageRef.set({
      'sender_id': senderId,
      'content': content,
      'timestamp':time,
      'status': 'sent',
      'senderName': senderName
    }).then((value) async {
      await _groupRef.child(roomId).update({
        "latestMessage" : content,
        "messageTime" : time,
        "senderName" : senderName
      });

    });
  }
  Future<void> joinGroup(String groupId, String myId, String groupIconUrl,
      String groupName)async {
   await _roomRef.child('$groupId/members/$myId').set(true);
   await _usersRef.child('$myId/groups/$groupId').set({
     "groupId" : groupId,
     "groupName" : groupName,
     "iconUrl" : groupIconUrl
   });
   await _groupRef.child('$groupId/members/$myId').set(true);
  }

  Future<void> leaveGroup(String groupId, String myId) async {
    await _roomRef.child('$groupId/members/$myId').set(null);
    await _usersRef.child('$myId/groups/$groupId').remove();
    await _groupRef.child('$groupId/members/$myId').remove();
  }

Future<List> getGroupInfo(String groupId) async {
    List<dynamic>? memberList;
    await _groupRef.child(groupId).once().then((event) {
    if (event.snapshot.value != null) {
    Map<dynamic, dynamic> groupData = event.snapshot.value as Map;
    // Access the group information from the groupData map
    String admin = groupData['admin'];
    String groupName = groupData['group_name'];
    String iconUrl = groupData['iconUrl'];
    String latestMessage = groupData['latestMessage'];
    String roomId = groupData['roomId'];
    String senderName = groupData['senderName'];

    // Accessing the 'members' map
    Map<dynamic, dynamic> membersMap = groupData['members'];

    // Extracting member phone numbers
     memberList = membersMap.keys.toList();

    // Displaying the extracted information
    // print('Admin: $admin');
    // print('Group Name: $groupName');
    // print('Icon URL: $iconUrl');
    // print('Latest Message: $latestMessage');
    // print('Room ID: $roomId');
    // print('Sender Name: $senderName');
    // print('Members: $memberList');
    } else {
    if (kDebugMode) {
      print('Group does not exist in the database');
    }
    }
    }).catchError((error) {
    if (kDebugMode) {
      print('Error retrieving group information: $error');
    }
    });
    await Future.delayed(const Duration(seconds: 1));
    return memberList!;
  }





}
