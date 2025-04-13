class PlaySessionResponse {
  PlayTime? playTime;
  List<TwoDigits>? twoDigits;
  String? totalBetAmount;
  String? hotPer;

  PlaySessionResponse({
    this.playTime,
    this.twoDigits,
    this.totalBetAmount,
    this.hotPer,
  });

  PlaySessionResponse.fromJson(Map<String, dynamic> json) {
    playTime =
        json['play_time'] != null ? PlayTime.fromJson(json['play_time']) : null;
    if (json['twoDigits'] != null) {
      twoDigits = <TwoDigits>[];
      json['twoDigits'].forEach((v) {
        twoDigits!.add(TwoDigits.fromJson(v));
      });
    }
    totalBetAmount = json['totalBetAmount'];
    hotPer = json['hot_per'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (playTime != null) {
      data['play_time'] = playTime!.toJson();
    }
    if (twoDigits != null) {
      data['twoDigits'] = twoDigits!.map((v) => v.toJson()).toList();
    }
    data['totalBetAmount'] = totalBetAmount;
    data['hot_per'] = hotPer;
    return data;
  }
}

class PlayTime {
  int? id;
  String? playTimeKey;
  String? startTime;
  String? endTime;
  String? sessionName;
  String? route;
  String? hotLimit;
  bool? status;
  String? session;
  String? type;

  PlayTime({
    this.id,
    this.playTimeKey,
    this.startTime,
    this.endTime,
    this.sessionName,
    this.route,
    this.hotLimit,
    this.status,
    this.session,
    this.type,
  });

  PlayTime.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    playTimeKey = json['play_timeKey'];
    startTime = json['start_time '];
    endTime = json['end_time'];
    sessionName = json['session_name'];
    route = json['route'];
    hotLimit = json['hot_limit'];
    status = json['status'];
    session = json['session'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['play_timeKey'] = playTimeKey;
    data['start_time '] = startTime;
    data['end_time'] = endTime;
    data['session_name'] = sessionName;
    data['route'] = route;
    data['hot_limit'] = hotLimit;
    data['status'] = status;
    data['session'] = session;
    data['type'] = type;
    return data;
  }
}

class TwoDigits {
  int? id;
  String? permanentNumber;
  dynamic percentage;
  String? isTape;
  String? isHot;
  String? status;
  String? digitLimit;

  TwoDigits({
    this.id,
    this.permanentNumber,
    this.percentage,
    this.isTape,
    this.isHot,
    this.status,
    this.digitLimit,
  });

  TwoDigits.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    permanentNumber = json['permanent_number'];

    if (json['percentage'] is int) {
      percentage = json['percentage'];
    } else if (json['percentage'] is String) {
      percentage = int.tryParse(json['percentage']) ?? 0;
    } else {
      percentage = 0;
    }

    isTape = json['is_tape'];
    isHot = json['is_hot'];
    status = json['status'];
    digitLimit = json['digit_limit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['permanent_number'] = permanentNumber;

    if (percentage is int) {
      data['percentage'] = percentage;
    } else if (percentage is String) {
      data['percentage'] = int.tryParse(percentage) ?? 0;
    } else {
      data['percentage'] = 0;
    }

    data['is_tape'] = isTape;
    data['is_hot'] = isHot;
    data['status'] = status;
    data['digit_limit'] = digitLimit;
    return data;
  }
}
