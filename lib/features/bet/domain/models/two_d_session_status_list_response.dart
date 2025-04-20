class TwoDSessionStatusListResponse {
  bool? available;
  String? information;
  List<Session>? session;

  TwoDSessionStatusListResponse({
    this.available,
    this.information,
    this.session,
  });

  TwoDSessionStatusListResponse.fromJson(Map<String, dynamic> json) {
    available = json['available'];
    information = json['information'];
    if (json['session'] != null) {
      session = <Session>[];
      json['session'].forEach((v) {
        session!.add(Session.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['available'] = available;
    data['information'] = information;
    if (session != null) {
      data['session'] = session!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Session {
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
  int? countdown;

  Session({
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
    this.countdown,
  });

  Session.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    playTimeKey = json['play_timeKey'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    sessionName = json['session_name'];
    route = json['route'];
    hotLimit = json['hot_limit'];
    status = json['status'];
    session = json['session'];
    type = json['type'];
    countdown = json['countdown'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['play_timeKey'] = playTimeKey;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    data['session_name'] = sessionName;
    data['route'] = route;
    data['hot_limit'] = hotLimit;
    data['status'] = status;
    data['session'] = session;
    data['type'] = type;
    data['countdown'] = countdown;
    return data;
  }
}
