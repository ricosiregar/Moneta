import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// Data Model representing a user from Supabase
@freezed
abstract class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String id,
    required String email,
    String? fullName,
    String? avatarUrl,
  }) = _UserModel;

  /// Factory to construct UserModel from JSON Map
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Factory to construct UserModel from Supabase Auth [User]
  factory UserModel.fromSupabaseUser(User user) {
    final metadata = user.userMetadata ?? {};
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      fullName:
          metadata['full_name'] as String? ?? metadata['name'] as String?,
      avatarUrl:
          metadata['avatar_url'] as String? ?? metadata['picture'] as String?,
    );
  }

  /// Convert to domain [UserEntity]
  UserEntity toEntity() => UserEntity(
        id: id,
        email: email,
        fullName: fullName,
        avatarUrl: avatarUrl,
      );
}
