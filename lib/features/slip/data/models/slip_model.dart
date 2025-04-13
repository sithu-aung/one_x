class SlipModel {
  final int id;
  final int userId;
  final String name;
  final String betTime;
  final double totalAmount;
  final String status;
  final List<SlipItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  SlipModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.betTime,
    required this.totalAmount,
    required this.status,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SlipModel.fromJson(Map<String, dynamic> json) {
    List<SlipItem> items = [];
    if (json['items'] != null) {
      items =
          (json['items'] as List)
              .map((item) => SlipItem.fromJson(item))
              .toList();
    }

    return SlipModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      name: json['name'] ?? '',
      betTime: json['bet_time'] ?? '',
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      items: items,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'bet_time': betTime,
      'total_amount': totalAmount,
      'status': status,
      'items': items.map((item) => item.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class SlipItem {
  final int id;
  final int slipId;
  final String number;
  final double amount;
  final String? isTape;
  final String? isHot;
  final String? result;
  final DateTime createdAt;
  final DateTime updatedAt;

  SlipItem({
    required this.id,
    required this.slipId,
    required this.number,
    required this.amount,
    this.isTape,
    this.isHot,
    this.result,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SlipItem.fromJson(Map<String, dynamic> json) {
    return SlipItem(
      id: json['id'] ?? 0,
      slipId: json['slip_id'] ?? 0,
      number: json['permanent_number'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      isTape: json['is_tape'],
      isHot: json['is_hot'],
      result: json['result'],
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slip_id': slipId,
      'permanent_number': number,
      'amount': amount,
      'is_tape': isTape,
      'is_hot': isHot,
      'result': result,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
