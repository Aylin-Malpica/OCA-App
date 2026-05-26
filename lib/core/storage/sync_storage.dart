import 'package:shared_preferences/shared_preferences.dart';

class SyncStorage {

  String _lastSyncUiKey(String userId) => "last_sync_ui_date_$userId";
  String _lastBackendUpdateKey(String userId) => "last_backend_update_date_$userId";

  Future<void> saveLastSyncUiDate(String date, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncUiKey(userId), date);
  }

  Future<String?> getLastSyncUiDate(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastSyncUiKey(userId));
  }

  Future<void> saveLastBackendUpdateDate(String date, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastBackendUpdateKey(userId), date);
  }

  Future<String?> getLastBackendUpdateDate(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastBackendUpdateKey(userId));
  }
}