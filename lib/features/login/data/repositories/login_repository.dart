import '../../../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../datasources/login_local_datasource.dart';
import '../datasources/login_remote_datasource.dart';
import '../../domain/entities/internal_employee_data.dart';

class LoginResult {
  final String status;
  final User? user;
  final InternalEmployeeData? empleadoData;

  LoginResult(
      this.status,
      this.user, [
        this.empleadoData,
      ]);
}
class LoginRepository {
  final LoginRemoteDatasource remote;
  final LoginLocalDatasource local;

  LoginRepository(this.remote, this.local);

  Future<LoginResult> verifyEmployee(String employeeId) async {
    print("VERIFY EMPLOYEE INPUT: $employeeId");

    final hasInternet = await NetworkInfo().hasInternet();

    if (!hasInternet) {
      final localUser = await local.getUserByEmployee(employeeId);

      if (localUser != null) {
        return LoginResult("offline_login", localUser);
      }

      return LoginResult("no_internet_no_user", null);
    }

    final localUser = await local.getUserByEmployee(employeeId);

    if (localUser != null) {
      return LoginResult("requires_login", localUser);
    }

    final response = await remote.verifyEmployee(employeeId);

    print("VERIFY EMPLOYEE RESPONSE: $response");

    if (response == null) {
      return LoginResult("error", null);
    }

    final success = response["success"] == true;
    final data = response["data"];

    if (!success || data == null) {
      return LoginResult("not_exists", null);
    }

    final requiresLogin = data["requiresLogin"] == true;
    final registrationStarted = data["registrationStarted"] == true;
    final requiresRegistration = data["requiresRegistration"] == true;

    final userJson = data["userData"];
    final empleadoJson = data["empleadoData"];

    /// ✅ USUARIO YA EXISTE Y DEBE INICIAR SESIÓN
    if (requiresLogin && userJson != null) {
      final user = User.fromJson(userJson);

      await local.saveUser(user);

      return LoginResult("requires_login", user);
    }

    /// 🟡 EMPLEADO EXISTE, PERO AÚN NO TIENE USUARIO
    /// Aquí entra tu caso:
    /// requiresLogin: false
    /// registrationStarted: false
    /// requiresRegistration: true
    if (requiresRegistration && empleadoJson != null) {
      final empleadoData = InternalEmployeeData.fromJson(empleadoJson);

      return LoginResult(
        "requires_registration",
        null,
        empleadoData,
      );
    }

    /// 🔥 REGISTRO YA INICIADO
    /// También mandamos empleadoData a la vista.
    if (registrationStarted && !requiresLogin && empleadoJson != null) {
      final empleadoData = InternalEmployeeData.fromJson(empleadoJson);

      return LoginResult(
        "registration_started",
        null,
        empleadoData,
      );
    }

    return LoginResult("error", null);
  }

  Future<User?> syncUser(String nombreUsuario) async {
    print("🔵 SYNC USER START");
    print("Empleado enviado a verifyEmployee: '$nombreUsuario'");

    if (nombreUsuario.trim().isEmpty) {
      return null;
    }

    final response = await remote.verifyEmployee(nombreUsuario);


    if (response == null) {
      return null;
    }

    final data = response["data"];

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