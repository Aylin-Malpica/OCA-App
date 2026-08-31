import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../domain/entities/user.dart';
import 'home_page.dart';
import '../../../../core/security/password_hasher.dart';
import '../../data/datasources/login_local_datasource.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/app_theme.dart';

// IMPORTANTE: Asegúrate de que las rutas a estos archivos sean correctas en tu proyecto
import '../../data/datasources/login_remote_datasource.dart';
import '../../../../core/network/api_client.dart';

class PasswordPage extends StatefulWidget {
  final User user;

  const PasswordPage({
    super.key,
    required this.user,
  });

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final TextEditingController passwordController = TextEditingController();

  bool obscure = true;
  bool loading = false;

  Future<void> login() async {
    final password = passwordController.text.trim();

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ingresa tu contraseña")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      String currentHash = widget.user.contrasenia;
      final hasInternet = await NetworkInfo().hasInternet();

      if (hasInternet) {
        // 1. SINCRONIZAR HASH ONLINE USANDO TU DATASOURCE
        try {
          print("🌐 Validando online para empleado: ${widget.user.numeroEmpleado}");

          // NOTA: Instancia tu ApiClient según como lo manejes en tu arquitectura.
          // Si usas GetIt o Provider, obtén la instancia desde allí.
          final apiClient = ApiClient();
          final remoteDS = LoginRemoteDatasource(apiClient);

          final decodedData = await remoteDS.verifyEmployee(widget.user.numeroEmpleado.toString());

          if (decodedData != null && decodedData['success'] == true) {
            if (decodedData['data'] != null && decodedData['data']['userData'] != null) {
              final fetchedHash = decodedData['data']['userData']['contrasenia'];
              if (fetchedHash != null && fetchedHash.toString().isNotEmpty) {
                currentHash = fetchedHash;
                print("🔄 Hash actualizado exitosamente desde el servidor");
              }
            }
          } else {
            print("⚠️ Error del servidor o credenciales no válidas.");
          }
        } catch (e) {
          print("⚠️ Error en la validación remota: $e");
        }
      }

      // 2. VALIDAR CONTRASEÑA
      final isValid = await PasswordHasher.verify(password, currentHash);

      if (!isValid) {
        showMsg("Contraseña incorrecta");
        return;
      }

      if (!widget.user.activo) {
        showMsg("Tu usuario está inactivo. Contacta al administrador.");
        return;
      }

      if (widget.user.accesoPendiente) {
        await showAccessPendingDialog();
        return;
      }

      // 3. ACTUALIZAR BASE DE DATOS LOCAL
      final local = LoginLocalDatasource();
      final updatedUser = User(
        usuarioId: widget.user.usuarioId,
        nombreUsuario: widget.user.nombreUsuario,
        nombreCompleto: widget.user.nombreCompleto,
        correo: widget.user.correo,
        contrasenia: currentHash,
        departamento: widget.user.departamento,
        ubicacionTecnica: widget.user.ubicacionTecnica,
        unidadNegocioId: widget.user.unidadNegocioId,
        activo: widget.user.activo,
        numeroEmpleado: widget.user.numeroEmpleado,
        departamentoId: widget.user.departamentoId,
        ubicacionTecnicaId: widget.user.ubicacionTecnicaId,
        accesoPendiente: widget.user.accesoPendiente,
      );

      await local.saveUser(updatedUser);
      print("💾 USER ACTUALIZADO PARA OFFLINE");

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(user: updatedUser),
        ),
      );
    } catch (e) {
      print("ERROR LOGIN: $e");
      showMsg("Error al validar contraseña");
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> showAccessPendingDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        icon: const Icon(
          Icons.hourglass_top_rounded,
          color: Colors.orange,
          size: 36,
        ),
        title: const Text(
          "Acceso pendiente",
          textAlign: TextAlign.center,
        ),
        content: const Text(
          "Tu cuenta aún no ha sido habilitada.\n\n"
              "Espera a que tu encargado de zona apruebe tu acceso para poder ingresar.",
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Entendido"),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> requestPasswordRecovery(String email) async {
    try {
      final baseUrl = dotenv.env['BASE_URL'] ?? "";
      final url = Uri.parse("$baseUrl/auth/usuarios-moviles/solicitar-recuperacion");

      // Aquí mantenemos http.post porque es un endpoint de recuperación que probablemente no requiere token
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"correo": email}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        showMsg("Correo de recuperación enviado exitosamente.");
      } else {
        showMsg("Error al solicitar recuperación. Intenta más tarde.");
      }
    } catch (e) {
      print("ERROR RECOVERY: $e");
      showMsg("Error de conexión. Verifica tu internet.");
    }
  }

  Future<void> showForgotPasswordDialog() async {
    final TextEditingController emailController = TextEditingController(text: widget.user.correo);
    bool isSending = false;
    bool hasInternet = true;
    bool checkedInternet = false;
    final goldColor = AppTheme.dorado;

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            if (!checkedInternet) {
              NetworkInfo().hasInternet().then((value) {
                if (mounted) {
                  setStateDialog(() {
                    hasInternet = value;
                    checkedInternet = true;
                  });
                }
              });
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: const Text("Recuperar contraseña"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Ingresa tu correo electrónico y te enviaremos las instrucciones para recuperar tu contraseña.",
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: hasInternet && !isSending,
                    decoration: InputDecoration(
                      labelText: "Correo electrónico",
                      prefixIcon: Icon(Icons.email_outlined, color: hasInternet ? goldColor : Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: goldColor, width: 1.5),
                      ),
                    ),
                  ),
                  if (checkedInternet && !hasInternet)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Row(
                        children: [
                          Icon(Icons.wifi_off, color: Colors.red.shade400, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "No tienes conexión a internet. Inténtalo más tarde para recuperar tu contraseña.",
                              style: TextStyle(color: Colors.red.shade400, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSending ? null : () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: goldColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: (!hasInternet || isSending)
                      ? null
                      : () async {
                    final email = emailController.text.trim();
                    if (email.isEmpty) {
                      showMsg("Por favor ingresa un correo");
                      return;
                    }

                    setStateDialog(() => isSending = true);
                    await requestPasswordRecovery(email);
                    setStateDialog(() => isSending = false);

                    if (mounted) Navigator.pop(context);
                  },
                  child: isSending
                      ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text("Enviar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    passwordController.dispose();
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: blueColor,
      ),
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
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                            Image.asset(
                              "assets/images/observa.png",
                              height: isSmallPhone
                                  ? 120
                                  : isTablet
                                  ? 220
                                  : 165,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(height: isSmallPhone ? 18 : 26),
                            Text(
                              "Hola",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isSmallPhone ? 24 : 30,
                                fontWeight: FontWeight.bold,
                                color: blueColor2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.user.nombreCompleto,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: textColor,
                                fontSize: isSmallPhone ? 18 : 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Por favor ingresa tu contraseña para continuar.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: textColor.withOpacity(0.55),
                                height: 1.3,
                              ),
                            ),
                            SizedBox(height: isSmallPhone ? 24 : 34),
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
                                    controller: passwordController,
                                    obscureText: obscure,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) {
                                      if (!loading) {
                                        login();
                                      }
                                    },
                                    decoration: InputDecoration(
                                      labelText: "Contraseña",
                                      prefixIcon: Icon(
                                        Icons.lock_outline,
                                        color: goldColor,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          obscure
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: goldColor,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            obscure = !obscure;
                                          });
                                        },
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFF9FAFC),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide(
                                          color: goldColor.withOpacity(0.25),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide(
                                          color: goldColor.withOpacity(0.25),
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
                                      onPressed: loading ? null : login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: goldColor,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                      ),
                                      child: const Text(
                                        "Ingresar",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextButton(
                                    onPressed: showForgotPasswordDialog,
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppTheme.azulOscuro,
                                    ),
                                    child: const Text(
                                      "¿Olvidaste tu contraseña?",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
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