import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sandesh/Database/realtime_database_service.dart';

class SearchItem extends StatelessWidget {
  const SearchItem(
      {super.key,
      required this.groupIconUrl,
      required this.groupName,
      required this.groupId,
      required this.isJoined,
      required this.myId});

  final String groupIconUrl;
  final String groupName;
  final String groupId;
  final bool isJoined;
  final String myId;

  @override
  Widget build(BuildContext context) {
    final FirebaseRealtimeDatabaseService rtdb =
        FirebaseRealtimeDatabaseService();

    return ListTile(
      // selectedTileColor: Colors.grey[800],
      textColor: Colors.black,
      leading: Container(
        child: (groupIconUrl != "")
            ? SizedBox(
                height: 50,
                width: 50,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(groupIconUrl),
                ),
              )
            : const Icon(Icons.group, color: Colors.green,),
      ),
      title: Text(groupName),
      tileColor: Colors.white,
      trailing: TextButton(
        onPressed: () async {
          if (!isJoined) {
            await rtdb.joinGroup(groupId, myId, groupIconUrl, groupName);
            Fluttertoast.showToast(msg: 'Joined The group!');

          }
        },
        style: TextButton.styleFrom(elevation: 2,backgroundColor: Colors.green[800],
        padding: const EdgeInsets.all(1)),
        child: !isJoined
            ? const Text(
                'Join',
                style: TextStyle(color: Colors.white),
              )
            : const Text('Joined'),
      ),
    );
  }
}
