class UserModel {
  String? name;
  String? email;
  String? avatarUrl;
  String? uid;
  String? plan;

  UserModel({
    this.name,
    this.email,
    this.uid,
    this.avatarUrl,
    this.plan,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    avatarUrl = json['avatarUrl'];
    uid = json['uid'];

    plan = json['plan'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['email'] = email;
    data['avatarUrl'] = avatarUrl;
    data['uid'] = uid;
    data['plan'] = plan;

    return data;
  }
}
