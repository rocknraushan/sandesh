// import 'package:firebase_database/firebase_database.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class FirebaseManager {
//   final DatabaseReference _database = FirebaseDatabase.instance.ref();
//   final CollectionReference _usersCollection =
//   FirebaseFirestore.instance.collection('users');
//   final CollectionReference _conversationsCollection =
//   FirebaseFirestore.instance.collection('conversations');
//
//   Future<UserModel?> getUser(String userId) async {
//     DocumentSnapshot userSnapshot =
//     await _usersCollection.doc(userId).get();
//     if (userSnapshot.exists) {
//       Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;
//       return UserModel(
//         id: userId,
//         name: userData?['name'],
//         profilePictureUrl: userData?['profilePictureUrl'],
//       );
//     }
//     return null;
//   }
//
//   Future<List<UserModel>> getAllUsers() async {
//     QuerySnapshot usersSnapshot = await _usersCollection.get();
//     List<UserModel> users = [];
//     for (DocumentSnapshot userSnapshot in usersSnapshot.docs) {
//       Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;
//       UserModel user = UserModel(
//         id: userSnapshot.id,
//         name: userData?['name'],
//         profilePictureUrl: userData?['profilePictureUrl'],
//       );
//       users.add(user);
//     }
//     return users;
//   }
//
//   Future<List<ConversationModel>> getUserConversations(String userId) async {
//     QuerySnapshot conversationsSnapshot =
//     await _conversationsCollection.where('participants', arrayContains: userId).get();
//     List<ConversationModel> conversations = [];
//     for (DocumentSnapshot conversationSnapshot in conversationsSnapshot.docs) {
//       Map<String, dynamic>? conversationData = conversationSnapshot.data() as Map<String, dynamic>?;
//       ConversationModel conversation = ConversationModel(
//         id: conversationSnapshot.id,
//         participantIds: List<String>.from(conversationData?['participants']),
//         lastMessage: conversationData?['lastMessage']['content'],
//         lastMessageTime: DateTime.parse(conversationData?['lastMessage']['timestamp']),
//       );
//       conversations.add(conversation);
//     }
//     return conversations;
//   }
//
//   Future<void> sendMessage(String conversationId, MessageModel message) async {
//     await _conversationsCollection
//         .doc(conversationId)
//         .collection('messages')
//         .add({
//       'content': message.content,
//       'senderId': message.senderId,
//       'timestamp': message.timestamp.toIso8601String(),
//     });
//     await _conversationsCollection.doc(conversationId).update({
//       'lastMessage': {
//         'content': message.content,
//         'senderId': message.senderId,
//         'timestamp': message.timestamp.toIso8601String(),
//       },
//     });
//   }
//
//   Future<void> setTypingStatus(String conversationId, String userId, bool isTyping) async {
//     await _conversationsCollection.doc(conversationId).update({
//       'typingStatus': {
//         userId: isTyping,
//       },
//     });
//   }
//
//   Future<void> setOnlineStatus(String userId, bool isOnline) async {
//     await _usersCollection.doc(userId).update({
//       'onlineStatus': isOnline,
//     });
//   }
//
//   Future<List<ContactModel>> getUserContacts(String userId) async {
//     QuerySnapshot contactsSnapshot =
//     await _usersCollection.doc(userId).collection('contacts').get();
//     List<ContactModel> contacts = [];
//     for (DocumentSnapshot contactSnapshot in contactsSnapshot.docs) {
//       Map<String, dynamic>? contactData = contactSnapshot.data() as Map<String, dynamic>?;
//       ContactModel contact = ContactModel(
//         id: contactSnapshot.id,
//         name: contactData?['name'],
//         profilePictureUrl: contactData?['profilePictureUrl'],
//       );
//       contacts.add(contact);
//     }
//     return contacts;
//   }
//
// // Other methods for handling contact list, user presence, etc.
//
// // ...
// }
//
// class UserModel {
//   final String id;
//   final String name;
//   final String profilePictureUrl;
//
//   UserModel({
//     required this.id,
//     required this.name,
//     required this.profilePictureUrl,
//   });
// }
//
// class ConversationModel {
//   final String id;
//   final List<String> participantIds;
//   final String lastMessage;
//   final DateTime lastMessageTime;
//
//   ConversationModel({
//     required this.id,
//     required this.participantIds,
//     required this.lastMessage,
//     required this.lastMessageTime,
//   });
// }
//
// class MessageModel {
//   final String senderId;
//   final String content;
//   final DateTime timestamp;
//
//   MessageModel({
//     required this.senderId,
//     required this.content,
//     required this.timestamp,
//   });
// }
//
// class ContactModel {
//   final String id;
//   final String name;
//   final String profilePictureUrl;
//
//   ContactModel({
//     required this.id,
//     required this.name,
//     required this.profilePictureUrl,
//   });
// }
