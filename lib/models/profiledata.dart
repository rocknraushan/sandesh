
class ProfileData{
  String name;
  String userid;
  String dpUrl;
  String phoneNumber;

  ProfileData({
    required this.name,
    required this.userid,
    required this.dpUrl,
    required this.phoneNumber

});

  Map<String, dynamic> toJson(){
    return {
      "name": name,
      "userid": userid,
      "dpurl": dpUrl,
      "phoneNumber" : phoneNumber
    };
  }

  factory ProfileData.fromJson(String userid, Map<String, dynamic> Json){
    return ProfileData(
        name: Json['name'],
        userid: userid,
        dpUrl: Json['dpUrl'],
        phoneNumber: Json['phoneNumber']);
  }

}