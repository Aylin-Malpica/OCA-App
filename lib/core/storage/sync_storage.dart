import 'package:shared_preferences/shared_preferences.dart';

class SyncStorage {
  static const _lastSyncUiKey = "last_sync_ui_date";
  static const _lastBackendUpdateKey = "last_backend_update_date";

  Future<void> saveLastSyncUiDate(String date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncUiKey, date);
  }

  Future<String?> getLastSyncUiDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastSyncUiKey);
  }

  Future<void> saveLastBackendUpdateDate(String date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastBackendUpdateKey, date);
  }

  Future<String?> getLastBackendUpdateDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastBackendUpdateKey);
  }
}