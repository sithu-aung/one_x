class HolidayListResponse {
  List<Holidays>? holidays;

  HolidayListResponse({this.holidays});

  HolidayListResponse.fromJson(Map<String, dynamic> json) {
    if (json['holidays'] != null) {
      holidays = <Holidays>[];
      json['holidays'].forEach((v) {
        holidays!.add(Holidays.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (holidays != null) {
      data['holidays'] = holidays!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Holidays {
  int? id;
  String? name;
  String? holidayKey;
  String? holidayDate;

  Holidays({this.id, this.name, this.holidayKey, this.holidayDate});

  Holidays.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    holidayKey = json['holidayKey'];
    holidayDate = json['holidayDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['holidayKey'] = holidayKey;
    data['holidayDate'] = holidayDate;
    return data;
  }
}
