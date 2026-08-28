import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_entity.dart';

/// Data Model representing a user from Supabase
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.fullName,
    super.avatarUrl,
  });

  /// Factory to construct UserModel from Supabase Auth [User]
  factory UserModel.fromSupabaseUser(User user) {
    final metadata = user.userMetadata ?? {};
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      fullName: metadata['full_name'] as String? ?? metadata['name'] as String?,
      avatarUrl: metadata['avatar_url'] as String? ?? metadata['picture'] as String?,
    );
  }

  /// Factory to construct UserModel from JSON Map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  /// Convert UserModel to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
    };
  }

  /// Convert to domain [UserEntity]
  UserEntity toEntity() => UserEntity(
        id: id,
        email: email,
        fullName: fullName,
        avatarUrl: avatarUrl,
      );
}
