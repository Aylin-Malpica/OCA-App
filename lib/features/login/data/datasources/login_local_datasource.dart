import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/user.dart';

class LoginLocalDatasource {

  final String boxName = "users";

  Box<User> get _box => Hive.box<User>(boxName);

  Future<void> saveUser(User user) async {

    final key = user.numeroEmpleado.trim();

    await _box.put(key, user);

    print("💾 USER GUARDADO:");
    print("KEY: $key");
    print("📦 USERS:");
    print(_box.keys);
  }

  Future<User?> getUserByEmployee(String numeroEmpleado) async {

    final key = numeroEmpleado.trim();

    print("🔍 BUSCANDO:");
    print("KEY: $key");
    print("📦 USERS:");
    print(_box.keys);

    return _box.get(key);
  }

  Future<void> clearUsers() async {
    await _box.clear();
  }
}