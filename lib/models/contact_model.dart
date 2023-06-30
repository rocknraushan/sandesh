

class ContactModel{
  final String username;
  final String? message;
  final String? lastMsgTime;
  final int?  message_count;
  final String? profileImgUrl;
  final String phoneNumber;

  ContactModel({
    required this.username,
    this.message,
    this.lastMsgTime,
    this.message_count,
    this.profileImgUrl,
    required this.phoneNumber
  });



  factory ContactModel.fromJson(Map<String, dynamic> json){
    return ContactModel(
      username: json['userName'],
      message_count: json['message_count'],
      message: json['message'],
      lastMsgTime: json['lastMsgTime'],
      phoneNumber: json['phoneNumber'],
      profileImgUrl: json['profileImgUrl'],

    );
  }
}