import 'package:Moneta/core/backup/backup_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ProfileLocalDataSource {
  Future<({String name, String email})> getCachedProfile();
  Future<void> exportJson();
  Future<void> exportCsv();
  Future<int> importJson(String source);
  Future<void> clearAll();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final BackupService backup;
  ProfileLocalDataSourceImpl({required this.backup});

  @override
  Future<({String name, String email})> getCachedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      name: prefs.getString('user_name') ?? '',
      email: prefs.getString('saved_email') ?? '',
    );
  }

  @override
  Future<void> exportJson() => backup.shareJson();

  @override
  Future<void> exportCsv() => backup.shareCsv();

  @override
  Future<int> importJson(String source) => backup.importJson(source);

  @override
  Future<void> clearAll() => backup.clearAll();
}
