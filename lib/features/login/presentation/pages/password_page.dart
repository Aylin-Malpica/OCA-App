import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';
import 'home_page.dart';
import '../../../../core/security/password_hasher.dart';
import '../../data/datasources/login_local_datasource.dart';
import '../../../../core/network/network_info.dart';

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

      /// 🔥 VERIFICAR INTERNET
      final hasInternet = await NetworkInfo().hasInternet();

      /// 🔥 SOLO GUARDAR SI HAY INTERNET (usuario confiable)
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

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),

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
                                  ? 120
                                  : isTablet
                                  ? 250
                                  : 180,
                              fit: BoxFit.contain,
                            ),

                            SizedBox(height: isSmallPhone ? 12 : 20),

                            Text(
                              "Hola ${widget.user.nombreCompleto}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isSmallPhone ? 20 : 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            const Text(
                              "Por favor ingresa tu contraseña",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),

                            SizedBox(height: isSmallPhone ? 24 : 40),

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
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscure
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      obscure = !obscure;
                                    });
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: loading ? null : login,
                                child: const Text("Ingresar"),
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