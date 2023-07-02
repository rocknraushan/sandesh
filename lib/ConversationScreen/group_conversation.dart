import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sandesh/ConversationScreen/group_info.dart';
import 'package:sandesh/widgets/groupmsg_bubble.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Database/realtime_database_service.dart';
import '../widgets/custom_loaader.dart';
import '../widgets/message_bubble.dart';

class GroupConversation extends StatefulWidget {
  const GroupConversation(
      {super.key,
      required this.roomId,
      this.groupIconUrl,
      required this.groupName});
  final String roomId;
  final String? groupIconUrl;
  final String groupName;
  @override
  _GroupState createState() => _GroupState();
}

class _GroupState extends State<GroupConversation> {
  final DatabaseReference _roomRef = FirebaseDatabase.instance.ref('rooms');
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  FirebaseRealtimeDatabaseService rtdb = FirebaseRealtimeDatabaseService();
  String? myPhoneNumber;
  String? myName;
  Future<void> getPhone() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? savedPhone = preferences.getString('phoneNumber');
    String? savedname = preferences.getString('userName');
    setState(() {
      myPhoneNumber = savedPhone!;
      myName = savedname!;
    });
  }

  @override
  void initState() {
    getPhone();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 93, 75, 20),
        actions: [
          IconButton(
              onPressed: () async {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GroupInfoScreen(
                              groupIconUrl: widget.groupIconUrl!,
                              groupName: widget.groupName,
                              groupId: widget.roomId,
                            )));
              },
              icon: const Icon(Icons.info_rounded)),
          IconButton(onPressed: () async {
            await rtdb.leaveGroup(widget.roomId, myPhoneNumber!);
           await Future.delayed(const Duration(seconds: 2)).then((value) =>  Navigator.pop(context));

            },
              icon: const Icon(Icons.exit_to_app))
        ],
        title: Row(
          children: [
            (widget.groupIconUrl != "")
                ? CircleAvatar(
                    backgroundImage: NetworkImage(widget.groupIconUrl!),
                  )
                : const Icon(Icons.group),
            const SizedBox(width: 15),
            Text(widget.groupName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _roomRef.child('${widget.roomId}/chatList').onValue,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text("Welcome!"),
                  );
                } else if (snapshot.hasData) {
                  final chatTileList = <GroupMessageBubble>[];
                  final chatData =
                      snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  // final chatListData =
                  // chatData['chat_list'] as Map<dynamic, dynamic>;
                  if (kDebugMode) {
                    print("chatdata ------ $chatData");
                  }
                  chatData.forEach((key, value) {
                    final messageData = value as Map<dynamic, dynamic>;
                    final isMe = messageData['sender_id'] == myPhoneNumber;

                    final newMessageTile = GroupMessageBubble(
                      message: messageData['content'],
                      isMe: isMe,
                      status: messageData['status'],
                      timeStamp: messageData['timestamp'],
                      senderName: messageData['senderName'],
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
                      rtdb.sendMessageToGroup(widget.roomId, myPhoneNumber!,
                          _messageController.text, myName!);
                      if (kDebugMode) {
                        print(_messageController.text);
                      }
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
