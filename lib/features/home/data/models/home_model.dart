import 'dart:convert';

class HomeResponse {
  final List<Banner> banners;
  final BannerText? bannerText;
  final User user;
  final List<Game> games;

  HomeResponse({
    required this.banners,
    this.bannerText,
    required this.user,
    required this.games,
  });

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    return HomeResponse(
      banners: List<Banner>.from(
        json['banners'].map((x) => Banner.fromJson(x)),
      ),
      bannerText:
          json['bannerText'] != null
              ? BannerText.fromJson(json['bannerText'])
              : null,
      user: User.fromJson(json['user']),
      games: List<Game>.from(json['games'].map((x) => Game.fromJson(x))),
    );
  }
}

class BannerText {
  final int id;
  final String description;
  final String bannerType;

  BannerText({
    required this.id,
    required this.description,
    required this.bannerType,
  });

  factory BannerText.fromJson(Map<String, dynamic> json) {
    return BannerText(
      id: json['id'],
      description: json['description'],
      bannerType: json['banner_type'],
    );
  }
}

class Banner {
  final int id;
  final String bannerKey;
  final int userId;
  final String imageName;
  final String imagePath;
  final String imageLocation;

  Banner({
    required this.id,
    required this.bannerKey,
    required this.userId,
    required this.imageName,
    required this.imagePath,
    required this.imageLocation,
  });

  factory Banner.fromJson(Map<String, dynamic> json) {
    return Banner(
      id: json['id'],
      bannerKey: json['bannerKey'],
      userId: json['user_id'],
      imageName: json['image_name'],
      imagePath: json['image_path'],
      imageLocation: json['image_location'],
    );
  }

  String getFullImageUrl() {
    return 'http://13.212.81.56/storage/$imageLocation';
  }
}

class User {
  final int id;
  final String userKey;
  final String username;
  final String userCode;
  final int agree;
  final int parentId;
  final dynamic oddId;
  final bool status;
  final int balance;
  final String phone;
  final dynamic referral;
  final String dateOfBirth;
  final String? myReferral;
  final String hiddenPhone;
  final dynamic email;
  final String? profilePhoto;
  final dynamic address;
  final dynamic country;
  final dynamic emailVerifiedAt;
  final int digitUsage;
  final String createdAtHuman;
  final List<Role> roles;
  final List<dynamic> permissions;

  User({
    required this.id,
    required this.userKey,
    required this.username,
    required this.userCode,
    required this.agree,
    required this.parentId,
    this.oddId,
    required this.status,
    required this.balance,
    required this.phone,
    this.referral,
    required this.dateOfBirth,
    this.myReferral,
    required this.hiddenPhone,
    this.email,
    this.profilePhoto,
    this.address,
    this.country,
    this.emailVerifiedAt,
    required this.digitUsage,
    required this.createdAtHuman,
    required this.roles,
    required this.permissions,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      userKey: json['userKey'],
      username: json['username'],
      userCode: json['user_code'],
      agree: json['agree'],
      parentId: json['parent_id'],
      oddId: json['odd_id'],
      status: json['status'],
      balance: json['balance'],
      phone: json['phone'],
      referral: json['referral'],
      dateOfBirth: json['date_of_birth'],
      myReferral: json['my_referral'],
      hiddenPhone: json['hidden_phone'],
      email: json['email'],
      profilePhoto: json['profile_photo']?.toString(),
      address: json['address'],
      country: json['country'],
      emailVerifiedAt: json['email_verified_at'],
      digitUsage: json['digit_usage'],
      createdAtHuman: json['created_at_human'],
      roles: List<Role>.from(json['roles'].map((x) => Role.fromJson(x))),
      permissions: List<dynamic>.from(json['permissions']),
    );
  }
}

class Role {
  final int id;
  final int userId;
  final String name;
  final String guardName;

  Role({
    required this.id,
    required this.userId,
    required this.name,
    required this.guardName,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      guardName: json['guard_name'],
    );
  }
}

class Game {
  final String game;
  final String status;

  Game({required this.game, required this.status});

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(game: json['game'], status: json['status']);
  }

  bool isActive() {
    return status.toLowerCase() == 'active';
  }
}
