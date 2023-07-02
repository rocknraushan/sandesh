import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sandesh/Database/realtime_database_service.dart';
import 'package:sandesh/widgets/custom_loaader.dart';
import 'package:sandesh/widgets/message_bubble.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IndividualConversationScreen extends StatefulWidget {
  const IndividualConversationScreen(
      {super.key,
      required this.phoneNumber,
      required this.name,
      required this.profilePicUrl,
      required this.room_id});
  final String room_id;
  final String profilePicUrl;
  final String name;
  final String phoneNumber;

  @override
  _IndividualState createState() => _IndividualState();
}

class _IndividualState extends State<IndividualConversationScreen> {

 final ScrollController _scrollController = ScrollController();
  final DatabaseReference _roomRef =
      FirebaseDatabase.instance.ref().child('rooms');
 final TextEditingController _messageController = TextEditingController();
 final FirebaseRealtimeDatabaseService rtdb = FirebaseRealtimeDatabaseService();

  late String? myPhoneNumber;
  Future<void> getPhone() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? savedPhone = preferences.getString('phoneNumber');
    setState(() {
      myPhoneNumber = savedPhone!;
    });
  }




  @override
  void initState() {
    // TODO: implement initState
    getPhone();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    super.dispose();
  }
 @override
 Widget build(BuildContext context) {
   return Scaffold(
     backgroundColor: Colors.blueGrey,
     appBar: AppBar(
       backgroundColor: const Color.fromRGBO(0, 93, 75, 20),
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
     body: Column(
       children: [
         Expanded(
           child: StreamBuilder(
             stream: _roomRef.child(widget.room_id).onValue,
             builder: (context, snapshot) {
               if (snapshot.hasData) {
                 final chatTileList = <MessageBubble>[];
                 final chatData =
                 snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                 final chatListData =
                 chatData['chat_list'] as Map<dynamic, dynamic>;

                 chatListData.forEach((key, value) {
                   final messageData = value as Map<dynamic, dynamic>;
                   final isMe =
                       messageData['sender_id'] != widget.phoneNumber;

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

                 WidgetsBinding.instance!.addPostFrameCallback((_) {
                   _scrollController.animateTo(
                     _scrollController.position.maxScrollExtent,
                     duration: const Duration(milliseconds: 100),
                     curve: Curves.easeInOut,
                   );
                 });
                 rtdb.updateMsgCounterToZero(widget.phoneNumber, myPhoneNumber!);

                 // Display the sorted chat messages in a reversed ListView
                 return ListView.builder(
                   // reverse: true, // Scroll from bottom to top
                   controller: _scrollController,
                   itemCount: chatTileList.length,
                   itemBuilder: (context, index) {
                     return chatTileList[index];
                   },
                 );
               } else if (snapshot.hasError) {
                 return const Center(
                   child: Text("Something went wrong!"),
                 );
               } else {
                 // If no data or data is still loading, show a loading indicator
                 return const Center(
                   child: CustomLoader(),
                 );
               }
             },
           ),
         ),
         Container(
           padding: const EdgeInsets.symmetric(horizontal: 8),
           decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(20),
             color: const Color.fromRGBO(31, 44, 52, 30),
           ),
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
                 icon: const Icon(
                   Icons.send,
                   color: Colors.white,
                 ),
                 onPressed: () {
                   if (_messageController.text.isNotEmpty) {
                     rtdb.sendMessage(
                       widget.room_id,
                       myPhoneNumber!,
                       _messageController.text,
                       widget.phoneNumber
                     );
                     print(_messageController.text);
                     _messageController.clear();
                   }
                 },
               ),
             ],
           ),
         ),
       ],
     ),
   );
 }

}
