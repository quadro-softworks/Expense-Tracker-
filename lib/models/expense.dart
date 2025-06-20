enum RecurrenceType { none, daily, weekly, monthly, yearly }

class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String categoryId;
  final String? description;
  final String? imageUrl;
  final RecurrenceType recurrenceType;
  final DateTime? nextDueDate;
  final String? currency; // Add currency field

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
    this.description,
    this.imageUrl,
    this.recurrenceType = RecurrenceType.none,
    this.nextDueDate,
    this.currency = 'ETB', // Default to ETB
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'categoryId': categoryId,
      'description': description,
      'imageUrl': imageUrl,
      'recurrenceType': recurrenceType.index,
      'nextDueDate': nextDueDate?.millisecondsSinceEpoch,
      'currency': currency,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      categoryId: map['categoryId'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      recurrenceType: RecurrenceType.values[map['recurrenceType'] ?? 0],
      nextDueDate:
          map['nextDueDate'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['nextDueDate'])
              : null,
      currency: map['currency'] ?? 'ETB', // Default to ETB if missing
    );
  }

  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    String? categoryId,
    String? description,
    String? imageUrl,
    RecurrenceType? recurrenceType,
    DateTime? nextDueDate,
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
      recurrenceType: recurrenceType ?? this.recurrenceType,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      currency: currency ?? this.currency,
    );
  }

  @override
  String toString() {
    return 'Expense{id: $id, title: $title, amount: $amount, date: $date, categoryId: $categoryId, recurrenceType: $recurrenceType, nextDueDate: $nextDueDate, currency: $currency}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Expense && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
