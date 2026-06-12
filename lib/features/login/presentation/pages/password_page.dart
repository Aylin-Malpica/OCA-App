import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';
import 'home_page.dart';
import '../../../../core/security/password_hasher.dart';
import '../../data/datasources/login_local_datasource.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/app_theme.dart';

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

      final storedHash = widget.user.contrasenia;

      final valid = await PasswordHasher.verify(password, storedHash);

      if (!valid) {
        showMsg("Contraseña incorrecta");
        return;
      }

      final hasInternet = await NetworkInfo().hasInternet();

      if (hasInternet) {
        final local = LoginLocalDatasource();

        final updatedUser = User(
          usuarioId: widget.user.usuarioId,
          nombreUsuario: widget.user.nombreUsuario,
          nombreCompleto: widget.user.nombreCompleto,
          correo: widget.user.correo,
          contrasenia: storedHash,
          departamento: widget.user.departamento,
          localidad: widget.user.localidad,
          unidadNegocioId: widget.user.unidadNegocioId,
          activo: widget.user.activo,
          numeroEmpleado: widget.user.numeroEmpleado,
        );

        await local.saveUser(updatedUser);

        print("💾 USER ACTUALIZADO PARA OFFLINE");
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(user: widget.user),
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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
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