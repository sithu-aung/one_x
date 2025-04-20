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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['available'] = this.available;
    data['information'] = this.information;
    data['countdown'] = this.countdown;
    return data;
  }
}
