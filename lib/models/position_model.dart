import 'package:cloud_firestore/cloud_firestore.dart';

class PositionModel {
  final String id;
  final String name;
  final bool isActive;
  final int? iconCodePoint;

  PositionModel({
    required this.id,
    required this.name,
    required this.isActive,
    this.iconCodePoint
  });

  factory PositionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PositionModel(
      id: doc.id,
      name: data['name'] ?? '',
      isActive: data['is_active'] ?? true,
      iconCodePoint: data['icon_code_point'] as int?
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'is_active': isActive,
      'icon_code_point': iconCodePoint
    };
  }

  PositionModel copyWith({
    String? id,
    String? name,
    bool? isActive,
    int? iconCodePoint
  }) {
    return PositionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint
    );
  }
}