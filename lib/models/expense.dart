class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String categoryId;
  final String? description;
  final String? imageUrl;

  final String paymentMethod;
  final String? location;
  final String? currency;
  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
    this.description,
    this.imageUrl,
    required this.paymentMethod,
    this.location,
    this.currency,
  });

  // Convert Expense to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'categoryId': categoryId,
      'description': description,
      'imageUrl': imageUrl,
      'paymentMethod': paymentMethod,
      'location': location,
      'currency': currency,
    };
  }

  // Create Expense from Map (database retrieval)
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      categoryId: map['categoryId'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      paymentMethod: map['paymentMethod'],
      location: map['location'],
      currency: map['currency'],
    );
  }

  // Create a copy of expense with updated fields
  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    String? categoryId,
    String? description,
    String? imageUrl,
    String? paymentMethod,
    String? location,
    String? currency,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      location: location ?? this.location,
      currency: currency ?? this.currency,
    );
  }

  @override
  String toString() {
    return 'Expense{id: $id, title: $title, amount: $amount, date: $date, categoryId: $categoryId, paymentMethod: $paymentMethod, location: $location, currency: $currency}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Expense &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
