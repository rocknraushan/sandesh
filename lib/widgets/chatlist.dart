

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sandesh/ConversationScreen/individual_conversation.dart';

class ChatList extends StatelessWidget{
  final String username;
  final String? message;
  final String? lastMsgTime;
  final int?  message_count;
  final String? profileImgUrl;
  final String room_id;
  final String phoneNumber;
  // final String userid;

  const ChatList({super.key, required this.phoneNumber, required this.room_id,required this.username, this.message,  this.lastMsgTime, this.message_count,this.profileImgUrl,});

  factory ChatList.fromJson(Map<dynamic, dynamic> nextData){
    String time = nextData['latest_messageTime'] ?? "";
    final String formattedTime =
    (time !="") ? DateFormat('h:mm a').format(DateTime.parse(time)) : "";

    return ChatList(
      username: nextData['name'],
        profileImgUrl: nextData['dpurl'],
        message_count: nextData['message_count'] ?? 0,
        lastMsgTime: formattedTime,
        message: nextData['message'] ?? "",
      room_id: nextData['room_id'],
      phoneNumber: nextData['phoneNumber'],

    );
  }

  @override
  Widget build(BuildContext context) {

    return ListTile(
      leading: profileImgUrl != null ?
        SizedBox(
          height: 50,
          width: 50,
          child: CircleAvatar(
             backgroundImage: NetworkImage(profileImgUrl!),
      ),
        )
          :
      const Icon(Icons.account_circle),
      title: Text(username,
      style: const TextStyle(
        color: Colors.white
      ),),
      subtitle: Text(message!,
      maxLines: 1,style: const TextStyle(
          color: Colors.grey
        ),),
      onTap: () {
        // Navigate to conversation screen for this user
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => IndividualConversationScreen(
              room_id: room_id,
            name: username,
            profilePicUrl: profileImgUrl!,
            phoneNumber: phoneNumber,

          )),
        );
      },
      trailing: Column(

          children: [
          Text(lastMsgTime!,
            style: TextStyle(
                color: (message_count!=0)?Colors.green:Colors.grey[200]
           ,fontSize: 12
             ),
             ),
          const SizedBox(height: 3,),
          if(message_count!=0)
          Container(
            constraints: const BoxConstraints(
                maxWidth: 35,
                minWidth: 10,
                minHeight: 10
            ),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:  (message_count!=0)? Colors.green:Colors.white,

            ),
            padding: const EdgeInsets.all(5),
            child: Center(
                child: ((message_count!>99)?const Text('99+',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14
                  ),):Text(message_count.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14
                  ),)
            ),
          ),)
        ]),
    );
  }
}