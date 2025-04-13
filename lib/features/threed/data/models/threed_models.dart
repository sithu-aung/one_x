// Base classes for common features in ThreeD models
class ThreeDSelection {
  final String number;
  final double amount;
  final String? isTape;
  final String? isHot;

  ThreeDSelection({
    required this.number,
    required this.amount,
    this.isTape,
    this.isHot,
  });

  factory ThreeDSelection.fromJson(Map<String, dynamic> json) {
    return ThreeDSelection(
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

// ThreeD Play Info
class ThreeDPlayInfo {
  final Map<String, dynamic> data;

  ThreeDPlayInfo({required this.data});

  factory ThreeDPlayInfo.fromJson(Map<String, dynamic> json) {
    return ThreeDPlayInfo(data: json);
  }
}

// ThreeD History
class ThreeDHistory {
  final List<Map<String, dynamic>> historyItems;

  ThreeDHistory({required this.historyItems});

  factory ThreeDHistory.fromJson(Map<String, dynamic> json) {
    final List<Map<String, dynamic>> items = [];

    if (json['three_d_history'] != null) {
      for (var item in json['three_d_history']) {
        items.add(Map<String, dynamic>.from(item));
      }
    }

    return ThreeDHistory(historyItems: items);
  }
}

// ThreeD Winning Numbers
class ThreeDWinningNumbers {
  final List<Map<String, dynamic>> winningNumbers;

  ThreeDWinningNumbers({required this.winningNumbers});

  factory ThreeDWinningNumbers.fromJson(Map<String, dynamic> json) {
    final List<Map<String, dynamic>> numbers = [];

    if (json['winning_numbers'] != null) {
      for (var number in json['winning_numbers']) {
        numbers.add(Map<String, dynamic>.from(number));
      }
    }

    return ThreeDWinningNumbers(winningNumbers: numbers);
  }
}

// ThreeD Play Data
class ThreeDPlayData {
  final Map<String, dynamic> playData;

  ThreeDPlayData({required this.playData});

  factory ThreeDPlayData.fromJson(Map<String, dynamic> json) {
    return ThreeDPlayData(playData: json);
  }
}

// ThreeD Manual Play Data
class ThreeDManualPlayData {
  final Map<String, dynamic> manualPlayData;

  ThreeDManualPlayData({required this.manualPlayData});

  factory ThreeDManualPlayData.fromJson(Map<String, dynamic> json) {
    return ThreeDManualPlayData(manualPlayData: json);
  }
}

// ThreeD Copy Paste Data
class ThreeDCopyPasteData {
  final Map<String, dynamic> copyPasteData;

  ThreeDCopyPasteData({required this.copyPasteData});

  factory ThreeDCopyPasteData.fromJson(Map<String, dynamic> json) {
    return ThreeDCopyPasteData(copyPasteData: json);
  }
}

// ThreeD Submit Request
class ThreeDSubmitRequest {
  final List<ThreeDSelection> selections;
  final String digits;
  final String betTime;
  final double totalAmount;
  final int userId;
  final String name;

  ThreeDSubmitRequest({
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

// ThreeD Submit Response
class ThreeDSubmitResponse {
  final String message;
  final int? slipId;

  ThreeDSubmitResponse({required this.message, this.slipId});

  factory ThreeDSubmitResponse.fromJson(Map<String, dynamic> json) {
    return ThreeDSubmitResponse(
      message: json['message'] ?? '',
      slipId: json['slip_id'],
    );
  }
}

// ThreeD Daily History
class ThreeDDailyHistory {
  final List<Map<String, dynamic>> dailyHistoryItems;

  ThreeDDailyHistory({required this.dailyHistoryItems});

  factory ThreeDDailyHistory.fromJson(Map<String, dynamic> json) {
    final List<Map<String, dynamic>> items = [];

    if (json['daily_history'] != null) {
      for (var item in json['daily_history']) {
        items.add(Map<String, dynamic>.from(item));
      }
    }

    return ThreeDDailyHistory(dailyHistoryItems: items);
  }
}

// ThreeD Daily Record
class ThreeDDailyRecord {
  final List<Map<String, dynamic>> dailyRecords;

  ThreeDDailyRecord({required this.dailyRecords});

  factory ThreeDDailyRecord.fromJson(Map<String, dynamic> json) {
    final List<Map<String, dynamic>> records = [];

    if (json['daily_records'] != null) {
      for (var record in json['daily_records']) {
        records.add(Map<String, dynamic>.from(record));
      }
    }

    return ThreeDDailyRecord(dailyRecords: records);
  }
}

// ThreeD Monthly History
class ThreeDMonthlyHistory {
  final List<Map<String, dynamic>> monthlyHistoryItems;

  ThreeDMonthlyHistory({required this.monthlyHistoryItems});

  factory ThreeDMonthlyHistory.fromJson(Map<String, dynamic> json) {
    final List<Map<String, dynamic>> items = [];

    if (json['monthly_history'] != null) {
      for (var item in json['monthly_history']) {
        items.add(Map<String, dynamic>.from(item));
      }
    }

    return ThreeDMonthlyHistory(monthlyHistoryItems: items);
  }
}

// ThreeD Half Monthly History
class ThreeDHalfMonthlyHistory {
  final List<Map<String, dynamic>> halfMonthlyHistoryItems;

  ThreeDHalfMonthlyHistory({required this.halfMonthlyHistoryItems});

  factory ThreeDHalfMonthlyHistory.fromJson(Map<String, dynamic> json) {
    final List<Map<String, dynamic>> items = [];

    if (json['half_monthly_history'] != null) {
      for (var item in json['half_monthly_history']) {
        items.add(Map<String, dynamic>.from(item));
      }
    }

    return ThreeDHalfMonthlyHistory(halfMonthlyHistoryItems: items);
  }
}
