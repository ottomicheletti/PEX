import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, employee }

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final bool isActive;
  final List<String> positionIds;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    required this.positionIds
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    List<String> positions = [];
    if (json['user_position'] != null) {
      if (json['user_position'] is List) {
        positions = (json['user_position'] as List)
            .map((pos) => pos['position_id'] as String)
            .toList();
      }
    }

    return UserModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] == 'admin' ? UserRole.admin : UserRole.employee,
      isActive: json['is_active'] ?? true,
      positionIds: positions
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] == 'admin' ? UserRole.admin : UserRole.employee,
      isActive: data['is_active'] ?? true,
      positionIds: List<String>.from(data['position_ids'] ?? [])
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role == UserRole.admin ? 'admin' : 'employee',
      'is_active': isActive
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role == UserRole.admin ? 'admin' : 'employee',
      'is_active': isActive,
      'position_ids': positionIds
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    bool? isActive,
    List<String>? positionIds
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      positionIds: positionIds ?? this.positionIds
    );
  }
}
