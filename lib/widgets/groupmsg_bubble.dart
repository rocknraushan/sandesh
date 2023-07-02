import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GroupMessageBubble extends StatelessWidget {
  final String message;
  final String senderName;
  final String timeStamp;
  final bool isMe;
  final String status;

  const GroupMessageBubble(
      {super.key,
      required this.message,
      required this.senderName,
      required this.timeStamp,
      required this.isMe,
      required this.status});

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final chatWidth = (screenwidth / 1.5);
    final String formattedTime =
        DateFormat('h:mm a').format(DateTime.parse(timeStamp));
    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        IntrinsicWidth(
          child: Card(
            color: isMe
                ? const Color.fromRGBO(0, 93, 75, 1)
                : const Color.fromRGBO(31, 44, 52, 30),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: !isMe
                    ? const Radius.circular(0)
                    : const Radius.circular(12),
                bottomRight:
                    isMe ? const Radius.circular(0) : const Radius.circular(12),
              ),
            ),
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // if (isMe)
                  // const Row(
                  //   mainAxisAlignment: MainAxisAlignment.end,
                  //   children: [
                  isMe
                      ? const Text(
                          'you',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          //   ),
                          // ],
                        )
                      : Text("$senderName :"),
                  const SizedBox(height: 6,),
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
                    children: [
                      Text(
                        formattedTime, // Format timestamp as desired
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white70),
                      ),
                      if (isMe)
                        Icon(
                          status == "sent"
                              ? Icons.done
                              : (status == "read")
                                  ? Icons.done_all_outlined
                                  : Icons.upload,
                          size: 16,
                          color: status == "seen" ? Colors.blue : Colors.grey,
                        ),
                    ],
                  ),


                ],
              ),
            ),
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
