class Category {
  final String id;
  final String name;
  final String icon;
  final int color;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  // Convert Category to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
    };
  }

  // Create Category from Map (database retrieval)
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
      color: map['color'],
    );
  }

  @override
  String toString() {
    return 'Category{id: $id, name: $name, icon: $icon}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  // Default categories
  static List<Category> getDefaultCategories() {
    return [
      Category(id: '1', name: 'Food', icon: '🍔', color: 0xFFFF5722),
      Category(id: '2', name: 'Transport', icon: '🚗', color: 0xFF2196F3),
      Category(id: '3', name: 'Shopping', icon: '🛒', color: 0xFF9C27B0),
      Category(id: '4', name: 'Entertainment', icon: '🎬', color: 0xFFE91E63),
      Category(id: '5', name: 'Health', icon: '🏥', color: 0xFF4CAF50),
      Category(id: '6', name: 'Education', icon: '📚', color: 0xFF607D8B),
      Category(id: '7', name: 'Bills', icon: '💡', color: 0xFFFFC107),
      Category(id: '8', name: 'Other', icon: '📦', color: 0xFF795548),
    ];
  }
}
