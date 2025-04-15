class UserWithdrawalDataResponse {
  List<WithdrawalProviders>? providers;

  UserWithdrawalDataResponse({this.providers});

  UserWithdrawalDataResponse.fromJson(Map<String, dynamic> json) {
    if (json['providers'] != null) {
      providers = <WithdrawalProviders>[];
      json['providers'].forEach((v) {
        providers!.add(WithdrawalProviders.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (providers != null) {
      data['providers'] = providers!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class WithdrawalProviders {
  int? id;
  String? providerKey;
  int? userId;
  String? providerName;
  String? providerSlug;
  String? imageName;
  String? imagePath;
  String? imageLocation;
  User? user;
  Billing? billing;

  WithdrawalProviders({
    this.id,
    this.providerKey,
    this.userId,
    this.providerName,
    this.providerSlug,
    this.imageName,
    this.imagePath,
    this.imageLocation,
    this.user,
    this.billing,
  });

  WithdrawalProviders.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    providerKey = json['providerKey'];
    userId = json['user_id'];
    providerName = json['provider_name'];
    providerSlug = json['provider_slug'];
    imageName = json['image_name'];
    imagePath = json['image_path'];
    imageLocation = json['image_location'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    billing =
        json['billing'] != null ? Billing.fromJson(json['billing']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['providerKey'] = providerKey;
    data['user_id'] = userId;
    data['provider_name'] = providerName;
    data['provider_slug'] = providerSlug;
    data['image_name'] = imageName;
    data['image_path'] = imagePath;
    data['image_location'] = imageLocation;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (billing != null) {
      data['billing'] = billing!.toJson();
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
  String? email;
  dynamic profilePhoto;
  dynamic address;
  dynamic country;
  dynamic emailVerifiedAt;
  int? digitUsage;
  String? createdAtHuman;

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
    return data;
  }
}

class Billing {
  int? id;
  String? billingKey;
  int? userId;
  int? providerId;
  String? providerName;
  String? providerPhone;
  String? status;

  Billing({
    this.id,
    this.billingKey,
    this.userId,
    this.providerId,
    this.providerName,
    this.providerPhone,
    this.status,
  });

  Billing.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    billingKey = json['billingKey'];
    userId = json['user_id'];
    providerId = json['provider_id'];
    providerName = json['provider_name'];
    providerPhone = json['provider_phone'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['billingKey'] = billingKey;
    data['user_id'] = userId;
    data['provider_id'] = providerId;
    data['provider_name'] = providerName;
    data['provider_phone'] = providerPhone;
    data['status'] = status;
    return data;
  }
}
