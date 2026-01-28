class Fragrance {
  final int? id;
  final String name;
  final String brand;
  final String? notes;
  final int? size;
  final String? imagePath;
  final String? description;

  Fragrance({
    this.id,
    required this.name,
    required this.brand,
    this.notes,
    this.size,
    this.imagePath,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'notes': notes,
      'size': size,
      'imagePath': imagePath,
      'description': description,
    };
  }

  factory Fragrance.fromMap(Map<String, dynamic> map) {
    return Fragrance(
      id: map['id'],
      name: map['name'],
      brand: map['brand'],
      notes: map['notes'],
      size: map['size'],
      imagePath: map['imagePath'],
      description: map['description'],
    );
  }

  Fragrance copyWith({
    int? id,
    String? name,
    String? brand,
    String? notes,
    int? size,
    String? imagePath,
    String? description,
  }) {
    return Fragrance(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      notes: notes ?? this.notes,
      size: size ?? this.size,
      imagePath: imagePath ?? this.imagePath,
      description: description ?? this.description,
    );
  }
}