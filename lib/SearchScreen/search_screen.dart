import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sandesh/widgets/search_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
  // final TextEditingController _searchController = TextEditingController();
  List<SearchItem> searchResults = [];

  String? myId;
  Future<void> getPhone() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? savedPhone = preferences.getString('phoneNumber');
    setState(() {
      myId = savedPhone!;
    });
  }

  @override
  void initState() {
    getPhone();
    super.initState();
  }

  Future<bool> joinedGroup(String myId, String groupId) async {
    print('inside joingroup method');
    print(groupId);
    bool isjoined = false;
    await databaseRef
        .child("users/$myId/groups")
        .orderByValue()
        .equalTo(groupId)
        .once()
        .then((value) {
      if (value.snapshot.exists) {
        if (kDebugMode) {
          print("###########----$value");
          print(value.snapshot);
        }
        isjoined = true;
      } else {
        isjoined = false;
        if (kDebugMode) {
          print(" not exists########--${value.snapshot.value}$value");
        }
      }
      return value.snapshot;
    });
    return isjoined;
  }

  Future<void> queryData(String query) async {
    if (kDebugMode) {
      print(myId);
      print(query);
    }
    databaseRef
        .child('groups')
        .orderByChild('group_name')
        .equalTo(query.trim())
        .onValue
        .listen((event) {
      final DataSnapshot snapshot = event.snapshot;
      if (snapshot.exists) {
        // Data found matching the query
        Map<dynamic, dynamic> groupData = snapshot.value as Map;
        groupData.forEach((key, value) async {
          if (kDebugMode) {
            print('Group ID: $key');
            print('Group Name: ${value['group_name']}');
          }
          // Process the retrieved data as needed

            final bool isJoined = await joinedGroup(myId!, key);
            if (kDebugMode) {
              print(isJoined);
            }
            final searchItem = SearchItem(
              groupIconUrl: value['iconUrl'],
              groupId: key,
              groupName: value['group_name'],
              isJoined: isJoined,
              myId: myId!,
            );
            setState(() {
            searchResults.add(searchItem);
            });

        });
      } else {
        // No data found matching the query
        if (kDebugMode) {
          print('No groups found matching the query');
        }
      }
    }, onError: (Object? error) {
      // Handle any errors that occur during the query
      if (kDebugMode) {
        print('Error querying groups: $error');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (query) {
                setState(() {
                  searchResults = []; // Clear previous search results
                queryData(query);
                });
              },
              decoration: const InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                return searchResults[index];
              },
            ),
          ),
        ],
      ),
    );
  }
}
