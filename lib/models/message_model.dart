


class MessageModel{
  final String senderId;
   final String   recieverId;
  final String  message;
  final String timeStamp;
  final String status;

  MessageModel({
   required this.status,
    required this.senderId,
    required this.recieverId,
    required this.message,
    required this.timeStamp});

  Map<String, dynamic> toJson(){
    return {
      "senderId": senderId,
      "recieverId": recieverId,
      "message": message,
      "timeStamp": timeStamp,
      "status":status
    };


}
  factory MessageModel.fromJson(Map<String, dynamic> json){
    return MessageModel(
        senderId: json['senderId'],
        recieverId:json['recieverId'],
        message:json['message'],
        timeStamp:json['timeStamp'],
      status: json['status']
    );
  }
}