// Base classes for common features in TwoD models
class TwoDSelection {
  final String number;
  final double amount;
  final String? isTape;
  final String? isHot;

  TwoDSelection({
    required this.number,
    required this.amount,
    this.isTape,
    this.isHot,
  });

  factory TwoDSelection.fromJson(Map<String, dynamic> json) {
    return TwoDSelection(
      number: json['permanent_number'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      isTape: json['is_tape'] as String?,
      isHot: json['is_hot'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'permanent_number': number,
      'amount': amount,
      'is_tape': isTape ?? 'inactive',
      'is_hot': isHot ?? 'inactive',
    };
  }
}

// TwoD Session Status
class TwoDSessionStatus {
  final bool isMorningOpen;
  final bool isEveningOpen;
  final String? message;

  TwoDSessionStatus({
    required this.isMorningOpen,
    required this.isEveningOpen,
    this.message,
  });

  factory TwoDSessionStatus.fromJson(Map<String, dynamic> json) {
    return TwoDSessionStatus(
      isMorningOpen: json['morning_open'] ?? false,
      isEveningOpen: json['evening_open'] ?? false,
      message: json['message'],
    );
  }
}

// TwoD Submit Request
class TwoDSubmitRequest {
  final List<TwoDSelection> selections;
  final String digits;
  final String betTime;
  final double totalAmount;
  final int userId;
  final String name;

  TwoDSubmitRequest({
    required this.selections,
    required this.digits,
    required this.betTime,
    required this.totalAmount,
    required this.userId,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'selections': selections.map((selection) => selection.toJson()).toList(),
      'digits': digits,
      'bet_time': betTime,
      'totalAmount': totalAmount,
      'user_id': userId,
      'name': name,
    };
  }
}

// TwoD Submit Response
class TwoDSubmitResponse {
  final String message;
  final int? slipId;

  TwoDSubmitResponse({required this.message, this.slipId});

  factory TwoDSubmitResponse.fromJson(Map<String, dynamic> json) {
    return TwoDSubmitResponse(
      message: json['message'] ?? '',
      slipId: json['slip_id'],
    );
  }
}

// TwoD Calendar
class TwoDCalendar {
  final List<Map<String, dynamic>> days;

  TwoDCalendar({required this.days});

  factory TwoDCalendar.fromJson(Map<String, dynamic> json) {
    final List<Map<String, dynamic>> calendarDays = [];
    if (json['days'] != null) {
      for (var day in json['days']) {
        calendarDays.add(Map<String, dynamic>.from(day));
      }
    }
    return TwoDCalendar(days: calendarDays);
  }
}

// TwoD History
class TwoDHistory {
  final List<Map<String, dynamic>> historyItems;

  TwoDHistory({required this.historyItems});

  factory TwoDHistory.fromJson(Map<String, dynamic> json) {
    final List<Map<String, dynamic>> items = [];
    if (json['history'] != null) {
      for (var item in json['history']) {
        items.add(Map<String, dynamic>.from(item));
      }
    }
    return TwoDHistory(historyItems: items);
  }
}

// TwoD Session Play Data
class TwoDSessionPlayData {
  final Map<String, dynamic> playData;
  final String session;

  TwoDSessionPlayData({required this.playData, required this.session});

  factory TwoDSessionPlayData.fromJson(
    Map<String, dynamic> json,
    String session,
  ) {
    return TwoDSessionPlayData(playData: json, session: session);
  }
}

// TwoD Holiday
class TwoDHoliday {
  final List<String> holidays;
  final String? message;

  TwoDHoliday({required this.holidays, this.message});

  factory TwoDHoliday.fromJson(Map<String, dynamic> json) {
    final List<String> holidayDates = [];
    if (json['holidays'] != null) {
      for (var date in json['holidays']) {
        holidayDates.add(date.toString());
      }
    }
    return TwoDHoliday(holidays: holidayDates, message: json['message']);
  }
}

// TwoD Winners
class TwoDWinners {
  final List<Map<String, dynamic>> winnersList;

  TwoDWinners({required this.winnersList});

  factory TwoDWinners.fromJson(Map<String, dynamic> json) {
    final List<Map<String, dynamic>> winners = [];
    if (json['winners'] != null) {
      for (var winner in json['winners']) {
        winners.add(Map<String, dynamic>.from(winner));
      }
    }
    return TwoDWinners(winnersList: winners);
  }
}
