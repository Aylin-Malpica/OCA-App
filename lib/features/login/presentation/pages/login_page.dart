import 'package:flutter/material.dart';
import '../../data/repositories/login_repository.dart';
import '../../data/datasources/login_local_datasource.dart';
import '../../data/datasources/login_remote_datasource.dart';
import '../../../../core/network/api_client.dart';

import 'password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController employeeController = TextEditingController();

  late LoginRepository repo;

  bool loading = false;

  @override
  void initState() {
    super.initState();

    final apiClient = ApiClient();

    repo = LoginRepository(
      LoginRemoteDatasource(apiClient),
      LoginLocalDatasource(),
    );
  }

  Future<void> verifyEmployee() async {

    final employee = employeeController.text.trim();

    if (employee.isEmpty) {
      showMsg("Ingresa tu número de empleado");
      return;
    }

    setState(() => loading = true);

    try {

      final result = await repo.verifyEmployee(employee);

      if (!mounted) return;

      setState(() => loading = false);

      /// ✅ LOGIN NORMAL O OFFLINE
      if (
      (result.status == "requires_login" ||
          result.status == "offline_login") &&
          result.user != null
      ) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PasswordPage(user: result.user!),
          ),
        );
        return;
      }

      /// 🔥 REGISTRO INICIADO
      if (result.status == "registration_started") {
        await showRegistrationStartedDialog();
        return;
      }

      /// ❌ USUARIO NO EXISTE
      if (result.status == "not_exists") {
        showMsg("El número de empleado no existe.");
        return;
      }

      /// ❌ SIN INTERNET Y SIN USUARIO LOCAL
      if (result.status == "no_internet_no_user") {
        showNoInternetDialog();
        return;
      }

      /// ❌ ERROR GENERAL
      showConnectionErrorDialog();

    } catch (e) {

      print("ERROR VERIFY EMPLOYEE: $e");

      if (!mounted) return;

      setState(() => loading = false);

      showConnectionErrorDialog();
    }
  }

  /// 🔔 MENSAJES
  void showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> showRegistrationStartedDialog() async {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Registro pendiente"),
        content: const Text(
          "Tu registro ya fue iniciado.\n\n"
              "Por favor revisa tu correo y completa el proceso antes de iniciar sesión.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Aceptar"),
          ),
        ],
      ),
    );
  }

  void showNoInternetDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Sin conexión"),
        content: const Text(
          "No tienes conexión a internet y este usuario no ha iniciado sesión previamente en este dispositivo.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Aceptar"),
          ),
        ],
      ),
    );
  }

  void showConnectionErrorDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: const Text(
          "No fue posible validar el usuario.\nIntenta nuevamente.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Aceptar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,

      body: Stack(
        children: [

          Center(
            child: Container(
              width: width > 500 ? 400 : width * 0.9,
              padding: const EdgeInsets.all(24),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  Image.asset(
                    "assets/images/observa.png",
                    height: 250,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Bienvenido",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Ingresa tu número de empleado",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 30),

                  TextField(
                    controller: employeeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Número de empleado",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: loading ? null : verifyEmployee,
                      child: const Text("Continuar"),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// 🔥 LOADING
          if (loading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}