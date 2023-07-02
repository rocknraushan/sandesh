import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// enum MessageStatus { sent, delivered, read }

class MessageBubble extends StatelessWidget {
  final dynamic message;
  final bool isMe;
  final dynamic timeStamp;
  final dynamic status;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.status,
    required this.timeStamp
  });



  // bool? read;
  // const MessageBubble({super.key, required this.isMe, required this.message, required this.timeStamp});

  // @override
  // Widget build(BuildContext context) {
  //   return Row(
  //     mainAxisAlignment: isMe ? MainAxisAlignment.end:MainAxisAlignment.start,
  //     children: [
  //       Container(
  //         decoration: BoxDecoration(
  //           color: isMe ? Colors.green: Colors.black54,
  //           borderRadius:  BorderRadius.only(
  //             bottomLeft: isMe ? const Radius.circular(12): const Radius.circular(0),
  //             bottomRight: isMe ? const Radius.circular(0): const Radius.circular(12),
  //             topRight: const Radius.circular(12),
  //             topLeft: const Radius.circular(12)
  //             )
  //           ),
  //         margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
  //         child: Padding(
  //           padding: EdgeInsets.fromLTRB(isMe ?16:24, 10, isMe ? 24 : 16, 10),
  //           child: Text(message,
  //           style: const TextStyle(
  //             color: Colors.white
  //           ),),
  //         ),
  //
  //
  //         ),
  //       SizedBox(
  //         child: Text(
  //           timeStamp,
  //           style: const TextStyle(
  //               color: Colors.grey
  //           ),
  //         ),
  //       )
  //
  //   ]
  //       );
  //
  //
  // }

  // MessageBubble({
  // required this.message,
  // required this.isMe,
  // required this.timeStamp,
  // required this.status,
  // });

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final chatWidth = (screenwidth/1.5);
    final String formattedTime = DateFormat('h:mm a').format(DateTime.parse(timeStamp));
    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isMe ? const Color(0x00128C7E): Colors.grey.shade700,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: !isMe ? const Radius.circular(0) : const Radius.circular(12),
              bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(12),
            ),
          ),
          width: chatWidth,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: const TextStyle(
                 color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment:
                  isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                children:[
                  Text(
                  formattedTime, // Format timestamp as desired
                  style: TextStyle(
                    fontSize: 12,
                    color: isMe ? Colors.white70 : Colors.black54,
                  ),
                ),
                  if(isMe)
                  Icon(
                    status == "sent" ? Icons.done : (status=="read")?Icons.done_all_outlined:Icons.upload,
                    size: 16,
                    color: status == "seen" ? Colors.blue : Colors.grey,
                  )
                ]
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Row(
          // mainAxisAlignment:
          //     isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [],
        ),
      ],
    );
  }
}
