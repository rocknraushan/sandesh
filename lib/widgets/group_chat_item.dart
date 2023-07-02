import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sandesh/ConversationScreen/group_conversation.dart';

class GroupChatItem extends StatelessWidget {
  const GroupChatItem(
      {super.key,
      this.groupIconUrl,
      required this.groupName,
      this.lastMessage,
      required this.roomId,
      this.lastMsgTime,
       this.messageCount,
      this.lastSender});

  final String? groupIconUrl;
  final String groupName;
  final String? lastMessage;
  final String roomId;
  final String? lastSender;
  final String? lastMsgTime;
  final int? messageCount;

  factory GroupChatItem.fromJson(Map<dynamic, dynamic> json) {
    return GroupChatItem(
      groupName: json["groupName"],
      roomId: json['groupId'],
      // messageCount: json["msgCount"] ?? "",
      // lastMsgTime: json["lastTimeStamp"] ?? "",
      groupIconUrl: json["iconUrl"],
      // lastMessage: json["lastMessage"] ?? "",
      // lastSender: json["lastSenderName"] ?? "",
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        height: 50,
        width: 50,
        child: (groupIconUrl == null || groupIconUrl != "")
            ? CircleAvatar(
                backgroundImage: NetworkImage(groupIconUrl!),
              )
            : const Icon(
                Icons.group_outlined,
                color: Colors.green,
              ),
      ),
      title: Text(
        groupName,
        style: const TextStyle(color: Colors.white),
      ),
      // subtitle: Text(
      //   "${lastSender!}:${lastMessage!}",
      //   maxLines: 1,
      //   style: const TextStyle(color: Colors.grey),
      // ),
      onTap: () {
        // Navigate to conversation screen for this user
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => GroupConversation(roomId: roomId, groupName: groupName,
              groupIconUrl: groupIconUrl,)),
        );
      },
      // trailing: Column(children: [
      //   Text(
      //     lastMsgTime!,
      //     style: TextStyle(
      //         color: (messageCount != 0) ? Colors.green : Colors.grey[200],
      //         fontSize: 12),
      //   ),
      //   // const SizedBox(
      //   //   height: 3,
      //   // ),
      //   // if (messageCount != 0)
      //   //   Container(
      //   //     constraints:
      //   //         const BoxConstraints(maxWidth: 35, minWidth: 10, minHeight: 10),
      //   //     decoration: BoxDecoration(
      //   //       shape: BoxShape.circle,
      //   //       color: (messageCount != 0) ? Colors.green : Colors.white,
      //   //     ),
      //   //     padding: const EdgeInsets.all(5),
      //   //     child: Center(
      //   //       child: ((messageCount! > 99)
      //   //           ? const Text(
      //   //               '99+',
      //   //               textAlign: TextAlign.center,
      //   //               style: TextStyle(fontSize: 14),
      //   //             )
      //   //           : Text(
      //   //               messageCount.toString(),
      //   //               textAlign: TextAlign.center,
      //   //               style: const TextStyle(fontSize: 14),
      //   //             )),
      //   //     ),
      //   //   )
      // ]),
    );
  }
}
