class WinnerListResponse {
  List<UserListItem>? top3Lists;
  List<UserListItem>? winners;

  WinnerListResponse({this.top3Lists, this.winners});

  WinnerListResponse.fromJson(Map<String, dynamic> json) {
    if (json['top3_lists'] != null) {
      top3Lists = <UserListItem>[];
      json['top3_lists'].forEach((v) {
        top3Lists!.add(UserListItem.fromJson(v));
      });
    }
    if (json['winners'] != null) {
      winners = <UserListItem>[];
      json['winners'].forEach((v) {
        winners!.add(UserListItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (top3Lists != null) {
      data['top3_lists'] = top3Lists!.map((v) => v.toJson()).toList();
    }
    if (winners != null) {
      data['winners'] = winners!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UserListItem {
  int? id;
  String? prizeAmount;
  String? winnerNumber;
  String? amount;
  String? createdAt;
  int? userId;
  User? user;

  UserListItem({
    this.id,
    this.prizeAmount,
    this.winnerNumber,
    this.amount,
    this.createdAt,
    this.userId,
    this.user,
  });

  UserListItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    prizeAmount = json['prize_amount'];
    winnerNumber = json['winner_number'];
    amount = json['amount'];
    createdAt = json['created_at'];
    userId = json['user_id'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['prize_amount'] = prizeAmount;
    data['winner_number'] = winnerNumber;
    data['amount'] = amount;
    data['created_at'] = createdAt;
    data['user_id'] = userId;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class User {
  int? id;
  String? username;
  Null profilePhoto;
  String? hiddenPhone;
  String? createdAtHuman;

  User({
    this.id,
    this.username,
    this.profilePhoto,
    this.hiddenPhone,
    this.createdAtHuman,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    profilePhoto = json['profile_photo'];
    hiddenPhone = json['hidden_phone'];
    createdAtHuman = json['created_at_human'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['profile_photo'] = profilePhoto;
    data['hidden_phone'] = hiddenPhone;
    data['created_at_human'] = createdAtHuman;
    return data;
  }
}
