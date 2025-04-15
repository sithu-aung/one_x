class ThreeDLiveResultResponse {
  List<ThreeDLiveResult>? results;

  ThreeDLiveResultResponse({this.results});

  ThreeDLiveResultResponse.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <ThreeDLiveResult>[];
      json['results'].forEach((v) {
        results!.add(ThreeDLiveResult.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (results != null) {
      data['results'] = results!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ThreeDLiveResult {
  String? date;
  String? formattedDate;
  String? number;
  String? updatedAt;

  ThreeDLiveResult({
    this.date,
    this.formattedDate,
    this.number,
    this.updatedAt,
  });

  ThreeDLiveResult.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    formattedDate = json['formatted_date'];
    number = json['number'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['formatted_date'] = formattedDate;
    data['number'] = number;
    data['updated_at'] = updatedAt;
    return data;
  }
}
