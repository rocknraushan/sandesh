



import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sandesh/Database/realtime_database_service.dart';
import 'package:sandesh/widgets/custom_loaader.dart';
import 'package:sandesh/widgets/message_bubble.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IndividualConversationScreen extends StatefulWidget{
  const IndividualConversationScreen({super.key,required this.phoneNumber, required this.name, required this.profilePicUrl, required this.room_id});
final String room_id;
final String profilePicUrl;
final String name;
final String phoneNumber;



  @override
  _IndividualState createState() => _IndividualState();

}

class _IndividualState extends State<IndividualConversationScreen>{
  final chatIdList = <dynamic>[];

  late List<dynamic> initalChats;


void processInitialData(dynamic data, List<dynamic> initialchilds){

}
  late String myPhoneNumber;
  Future<void> getPhone() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? savedPhone = preferences.getString('phoneNumber');
    setState(() {
      myPhoneNumber = savedPhone!;
    });
  }

  final DatabaseReference _roomRef = FirebaseDatabase.instance.ref().child('rooms');

  TextEditingController _messageController = TextEditingController();
  FirebaseRealtimeDatabaseService rtdb = FirebaseRealtimeDatabaseService();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPhone();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.profilePicUrl),
            ),
            const SizedBox(width: 8),
            Text(widget.name),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Type a message...',
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                // Handle sending the message here
                // DateTime sentTime = DateTime.now();
                // String formattedTime = DateFormat('h:mm a').format(sentTime);
                if (_messageController.text.isNotEmpty) {
                  rtdb.sendMessage(
                    widget.room_id,
                    myPhoneNumber,
                    _messageController.text,

                  );
                  print(_messageController.text);
                  _messageController.clear();
                }
              },
            ),
          ],
        ),
      ),
      body:StreamBuilder(
        stream: _roomRef.child(widget.room_id).onValue,
        builder: (context, snapshot) {
          final chatTileList = <MessageBubble>[];
          if (snapshot.hasData) {
            final chatData = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

            final chatListData = chatData['chat_list'] as Map<dynamic, dynamic>;

            chatListData.forEach((key, value) {
              final messageData = value as Map<dynamic, dynamic>;

              final dynamic isMe = (messageData['sender_id'] == widget.phoneNumber) ? false : true;

              final newMessageTile = MessageBubble(
                message: messageData['content'],
                isMe: isMe,
                status: messageData['status'],
                timeStamp: messageData['timestamp'],
              );

              chatTileList.add(newMessageTile);
            });

            // Sort the chat messages based on timestamps in ascending order
            chatTileList.sort((a, b) {
              final DateTime aTimestamp = DateTime.parse(a.timeStamp);
              final DateTime bTimestamp = DateTime.parse(b.timeStamp);
              return aTimestamp.compareTo(bTimestamp);
            });

            // Display the sorted chat messages in a reversed ListView
            return ListView(
              children: chatTileList,
            );
          } else {
            // If no data or data is still loading, show a loading indicator
            return const Center(
              child: CustomLoader(),
            );
          }
        },
      )

    );
  }



}