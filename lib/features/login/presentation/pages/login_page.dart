import 'package:flutter/material.dart';
import '../../../internal_register/pages/internal_register_preview_page.dart';
import '../../data/repositories/login_repository.dart';
import '../../data/datasources/login_local_datasource.dart';
import '../../data/datasources/login_remote_datasource.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/app_theme.dart';
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
      if ((result.status == "requires_registration" ||
          result.status == "registration_started") &&
          result.empleadoData != null) {
        final empleadoData = result.empleadoData!;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InternalRegisterPreviewPage(
              empleado: empleadoData,
            ),
          ),
        );
        return;
      }


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

    final blueColor2 = AppTheme.azulOscuro;
    final blueColor = AppTheme.azul;
    final goldColor = AppTheme.dorado;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned(
            top: -90,
            right: -70,
            child: _DecorativeCircle(
              size: 190,
              color: blueColor.withOpacity(0.12),
            ),
          ),

          Positioned(
            top: 120,
            left: -60,
            child: _DecorativeCircle(
              size: 120,
              color: goldColor.withOpacity(0.10),
            ),
          ),

          Positioned(
            bottom: -80,
            right: -55,
            child: _DecorativeCircle(
              size: 150,
              color: goldColor.withOpacity(0.08),
            ),
          ),

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
                      child: SizedBox(
                        width: isTablet ? 420 : double.infinity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 16,
                              ),

                              child: Image.asset(
                                "assets/images/observa.png",
                                height: isSmallPhone
                                    ? 130
                                    : isTablet
                                    ? 220
                                    : 170,
                                fit: BoxFit.contain,
                              ),
                            ),

                            SizedBox(height: isSmallPhone ? 18 : 26),

                            Text(
                              "Bienvenido",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isSmallPhone ? 25 : 30,
                                fontWeight: FontWeight.bold,
                                color: blueColor2,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              "Ingresa tu nombre de usuario para continuar.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: textColor.withOpacity(0.55),
                                fontSize: 15,
                                height: 1.3,
                              ),
                            ),

                            SizedBox(height: isSmallPhone ? 22 : 32),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: goldColor.withOpacity(0.20),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: goldColor.withOpacity(0.08),
                                    blurRadius: 18,
                                    offset: const Offset(0, 7),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  TextField(
                                    controller: employeeController,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) {
                                      if (!loading) {
                                        verifyEmployee();
                                      }
                                    },
                                    decoration: InputDecoration(
                                      labelText: "Nombre de usuario",
                                      prefixIcon: Icon(
                                        Icons.person_outline,
                                        color: goldColor,
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFF9FAFC),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide(
                                          color: blueColor.withOpacity(0.18),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide(
                                          color: blueColor.withOpacity(0.18),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide(
                                          color: goldColor,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 18),

                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: loading ? null : verifyEmployee,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: goldColor,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                      ),
                                      child: const Text(
                                        "Continuar",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 18),

                            TextButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(
                                Icons.arrow_back,
                                color: goldColor,
                                size: 18,
                              ),
                              label: Text(
                                "Volver",
                                style: TextStyle(
                                  color: goldColor,
                                  fontWeight: FontWeight.w600,
                                ),
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
              color: Colors.black.withOpacity(0.25),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: CircularProgressIndicator(
                    color: goldColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
class _DecorativeCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _DecorativeCircle({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}