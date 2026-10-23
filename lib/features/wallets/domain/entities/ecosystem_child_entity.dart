import 'package:freezed_annotation/freezed_annotation.dart';

part 'ecosystem_child_entity.freezed.dart';

/// Dompet anak yang dibuat otomatis bersama wallet induk (mis. ekosistem bank).
@freezed
abstract class EcosystemChildEntity with _$EcosystemChildEntity {
  const factory EcosystemChildEntity({
    required String name,
    required String type,
    required String purpose,
    @Default(0) double openingBalance,
  }) = _EcosystemChildEntity;
}
