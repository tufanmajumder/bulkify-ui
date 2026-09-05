class FruitItem {
  final int? id;
  final String name;
  final double price;
  final int quantity;
  final String note;

  FruitItem({
    this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.note = '',
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'note': note,
    };
  }

  factory FruitItem.fromMap(Map<String, dynamic> map) {
    return FruitItem(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      note: map['note'] as String? ?? '',
    );
  }

  FruitItem copyWith({
    int? id,
    String? name,
    double? price,
    int? quantity,
    String? note,
  }) {
    return FruitItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
    );
  }
}
