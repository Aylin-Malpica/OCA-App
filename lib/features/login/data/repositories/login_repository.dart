import '../../../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../datasources/login_local_datasource.dart';
import '../datasources/login_remote_datasource.dart';

class LoginResult {
  final String status;
  final User? user;

  LoginResult(this.status, this.user);
}

class LoginRepository {
  final LoginRemoteDatasource remote;
  final LoginLocalDatasource local;

  LoginRepository(this.remote, this.local);

  Future<LoginResult> verifyEmployee(String employeeId) async {

    final hasInternet = await NetworkInfo().hasInternet();

    /// 🔥 SI NO HAY INTERNET → SOLO LOCAL
    if (!hasInternet) {
      final localUser = await local.getUserByEmployee(employeeId);

      if (localUser != null) {
        return LoginResult("offline_login", localUser);
      }

      return LoginResult("no_internet_no_user", null);
    }

    /// 🔥 SI HAY INTERNET → FLUJO NORMAL
    final localUser = await local.getUserByEmployee(employeeId);

    if (localUser != null) {
      return LoginResult("requires_login", localUser);
    }

    final response = await remote.verifyEmployee(employeeId);

    if (response == null) {
      return LoginResult("error", null);
    }

    final data = response["data"];

    if (data == null) {
      return LoginResult("not_exists", null);
    }

    final requiresLogin = data["requiresLogin"];
    final registrationStarted = data["registrationStarted"];

    if (registrationStarted == true && requiresLogin == false) {
      return LoginResult("registration_started", null);
    }

    if (requiresLogin == true) {
      final userJson = data["userData"];
      final user = User.fromJson(userJson);

      await local.saveUser(user);

      return LoginResult("requires_login", user);
    }

    return LoginResult("error", null);
  }

  Future<User?> syncUser(String nombreUsuario) async {
    print("🔵 SYNC USER START");
    print("Empleado enviado a verifyEmployee: '$nombreUsuario'");

    if (nombreUsuario.trim().isEmpty) {
      print("❌ NUMERO EMPLEADO VACÍO");
      return null;
    }

    final response = await remote.verifyEmployee(nombreUsuario);

    print("🔵 RESPONSE RAW:");
    print(response);

    if (response == null) {
      print("❌ RESPONSE NULL");
      return null;
    }

    final data = response["data"];

    print("🔵 DATA:");
    print(data);

    if (data == null) {
      print("❌ DATA NULL");
      return null;
    }

    final requiresLogin = data["requiresLogin"];
    final registrationStarted = data["registrationStarted"];

    print("🔵 requiresLogin: $requiresLogin");
    print("🔵 registrationStarted: $registrationStarted");

    final userJson = data["userData"];

    if (userJson == null) {
      print("❌ userData NULL");
      return null;
    }

    print("🔵 USER JSON:");
    print(userJson);

    final updatedUser = User.fromJson(userJson);

    print("✅ USER PARSEADO:");
    print("ID: ${updatedUser.usuarioId}");
    print("Nombre: ${updatedUser.nombreCompleto}");
    print("Empleado: ${updatedUser.nombreUsuario}");
    print("Activo: ${updatedUser.activo}");


    await local.saveUser(updatedUser);

    print("💾 USER GUARDADO EN LOCAL");
    print("🟢 SYNC USER END OK");

    return updatedUser;
  }
}