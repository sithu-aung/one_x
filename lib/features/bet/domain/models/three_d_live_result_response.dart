class ThreeDLiveResultResponse {
  String? message;
  List<Results>? results;

  ThreeDLiveResultResponse({this.message, this.results});

  ThreeDLiveResultResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['results'] != null) {
      results = <Results>[];
      json['results'].forEach((v) {
        results!.add(Results.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (results != null) {
      data['results'] = results!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Results {
  String? result;
  String? datetime;

  Results({this.result, this.datetime});

  Results.fromJson(Map<String, dynamic> json) {
    result = json['result'];
    datetime = json['datetime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['result'] = result;
    data['datetime'] = datetime;
    return data;
  }
}
