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
  void dispose() {
    employeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    final bool isSmallPhone = height < 700;
    final bool isTablet = width > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,

      body: Stack(
        children: [
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 16,
                    bottom: keyboardHeight + 24,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: Container(
                        width: isTablet ? 420 : double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallPhone ? 12 : 24,
                          vertical: isSmallPhone ? 16 : 24,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              "assets/images/observa.png",
                              height: isSmallPhone
                                  ? 140
                                  : isTablet
                                  ? 250
                                  : 190,
                              fit: BoxFit.contain,
                            ),

                            SizedBox(height: isSmallPhone ? 12 : 20),

                            const Text(
                              "Bienvenido",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            const Text(
                              "Ingresa tu número de empleado",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),

                            SizedBox(height: isSmallPhone ? 20 : 30),

                            TextField(
                              controller: employeeController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) {
                                if (!loading) {
                                  verifyEmployee();
                                }
                              },
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
                  ),
                );
              },
            ),
          ),

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