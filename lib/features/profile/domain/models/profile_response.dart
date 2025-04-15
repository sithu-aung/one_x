import 'package:one_x/features/profile/domain/models/user_response_field.dart';

class UserResponse {
  User? user;

  UserResponse({this.user});

  UserResponse.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class User {
  int? id;
  String? userKey;
  String? username;
  String? userCode;
  int? agree;
  int? parentId;
  dynamic oddId;
  bool? status;
  int? balance;
  String? phone;
  dynamic referral;
  String? dateOfBirth;
  String? myReferral;
  String? hiddenPhone;
  dynamic email;
  dynamic profilePhoto;
  dynamic address;
  dynamic country;
  dynamic emailVerifiedAt;
  int? digitUsage;
  String? createdAtHuman;
  List<Roles>? roles;
  UserResponseField? userResponseField;

  User({
    this.id,
    this.userKey,
    this.username,
    this.userCode,
    this.agree,
    this.parentId,
    this.oddId,
    this.status,
    this.balance,
    this.phone,
    this.referral,
    this.dateOfBirth,
    this.myReferral,
    this.hiddenPhone,
    this.email,
    this.profilePhoto,
    this.address,
    this.country,
    this.emailVerifiedAt,
    this.digitUsage,
    this.createdAtHuman,
    this.roles,
    this.userResponseField,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userKey = json['userKey'];
    username = json['username'];
    userCode = json['user_code'];
    agree = json['agree'];
    parentId = json['parent_id'];
    oddId = json['odd_id'];
    status = json['status'];
    balance = json['balance'];
    phone = json['phone'];
    referral = json['referral'];
    dateOfBirth = json['date_of_birth'];
    myReferral = json['my_referral'];
    hiddenPhone = json['hidden_phone'];
    email = json['email'];
    profilePhoto = json['profile_photo'];
    address = json['address'];
    country = json['country'];
    emailVerifiedAt = json['email_verified_at'];
    digitUsage = json['digit_usage'];
    createdAtHuman = json['created_at_human'];
    if (json['roles'] != null) {
      roles = <Roles>[];
      json['roles'].forEach((v) {
        roles!.add(Roles.fromJson(v));
      });
    }
    userResponseField =
        json['user_response'] != null
            ? UserResponseField.fromJson(json['user_response'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userKey'] = userKey;
    data['username'] = username;
    data['user_code'] = userCode;
    data['agree'] = agree;
    data['parent_id'] = parentId;
    data['odd_id'] = oddId;
    data['status'] = status;
    data['balance'] = balance;
    data['phone'] = phone;
    data['referral'] = referral;
    data['date_of_birth'] = dateOfBirth;
    data['my_referral'] = myReferral;
    data['hidden_phone'] = hiddenPhone;
    data['email'] = email;
    data['profile_photo'] = profilePhoto;
    data['address'] = address;
    data['country'] = country;
    data['email_verified_at'] = emailVerifiedAt;
    data['digit_usage'] = digitUsage;
    data['created_at_human'] = createdAtHuman;
    if (roles != null) {
      data['roles'] = roles!.map((v) => v.toJson()).toList();
    }
    if (userResponseField != null) {
      data['user_response'] = userResponseField!.toJson();
    }

    return data;
  }
}

class Roles {
  int? id;
  int? userId;
  String? name;
  String? guardName;

  Roles({this.id, this.userId, this.name, this.guardName});

  Roles.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    name = json['name'];
    guardName = json['guard_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['name'] = name;
    data['guard_name'] = guardName;
    return data;
  }
}
