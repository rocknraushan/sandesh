import 'package:flutter/material.dart';
import 'package:sandesh/Database/realtime_database_service.dart';

class GroupInfoScreen extends StatelessWidget {
  GroupInfoScreen(
      {super.key,
      required this.groupIconUrl,
      required this.groupName,
      required this.groupId});
  final String groupIconUrl;
  final String groupName;
  // final List<dynamic> memberList;
  final String groupId;

  final FirebaseRealtimeDatabaseService rtdb =
      FirebaseRealtimeDatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Details'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          (groupIconUrl != "")
              ? CircleAvatar(
                  radius: 50, backgroundImage: NetworkImage(groupIconUrl))
              : const Icon(Icons.group),
          const SizedBox(height: 20),
          Text(
            groupName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            'Members:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: FutureBuilder<List>(
              future: rtdb.getGroupInfo(groupId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  final data = snapshot.data;
                  if (data == null || data.isEmpty) {
                    return const Center(
                      child: Text('No data available'),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final item = data[index];
                        return ListTile(
                          title: Text(item),
                        );
                      },
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
