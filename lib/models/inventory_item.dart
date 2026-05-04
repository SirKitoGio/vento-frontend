class InventoryItem {
  final String name;
  final int quantity;
  final double price;
  final String productType;
  final String inventoryPlace;
  final String date;
  final DateTime? startTime;
  final int? x;
  final int? y;

  InventoryItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.productType,
    required this.inventoryPlace,
    required this.date,
    this.startTime,
    this.x,
    this.y,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      name: json['name'] ?? json['item_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0.0).toDouble(),
      productType: json['product_type'] ?? '',
      inventoryPlace: json['inventory_place'] ?? '',
      date: json['date'] ?? '',
      startTime: json['start_time'] != null ? DateTime.tryParse(json['start_time']) : null,
      x: json['x'],
      y: json['y'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item': name,
      'qty': quantity,
      'price': price,
      'product_type': productType,
      'inventory_place': inventoryPlace,
      'date': date,
      'action': 'ADD',
    };
  }
}

class ActionLog {
  final String item;
  final int qty;
  final double price;
  final String productType;
  final String date;
  final String action;
  final int x;
  final int y;
  final DateTime timestamp;

  ActionLog({
    required this.item,
    required this.qty,
    required this.price,
    required this.productType,
    required this.date,
    required this.action,
    required this.x,
    required this.y,
    required this.timestamp,
  });

  factory ActionLog.fromJson(Map<String, dynamic> json) {
    return ActionLog(
      item: json['item'] ?? '',
      qty: json['qty'] ?? 0,
      price: (json['price'] ?? 0.0).toDouble(),
      productType: json['product_type'] ?? '',
      date: json['date'] ?? '',
      action: json['action'] ?? '',
      x: json['x'] ?? 0,
      y: json['y'] ?? 0,
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}
