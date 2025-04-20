class AvailableResponse {
  bool? available;
  String? information;
  int? countdown;

  AvailableResponse({this.available, this.information, this.countdown});

  AvailableResponse.fromJson(Map<String, dynamic> json) {
    available = json['available'];
    information = json['information'];
    countdown = json['countdown'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['available'] = available;
    data['information'] = information;
    data['countdown'] = countdown;
    return data;
  }
}
