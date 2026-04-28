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
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(),

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

                  Text(
                    "Hola ${widget.user.nombreCompleto}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
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

                  const SizedBox(height: 40),

                  TextField(
                    controller: passwordController,
                    obscureText: obscure,
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

          /// 🔥 LOADING BONITO
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