import 'package:flutter/material.dart';

class ExternalRegisterPage extends StatefulWidget {
  const ExternalRegisterPage({super.key});

  @override
  State<ExternalRegisterPage> createState() => _ExternalRegisterPageState();
}

class _ExternalRegisterPageState extends State<ExternalRegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNamePController = TextEditingController();
  final TextEditingController lastNameMController = TextEditingController();
  final TextEditingController technicalLocationController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController businessUnitController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    usernameController.dispose();
    nameController.dispose();
    lastNamePController.dispose();
    lastNameMController.dispose();
    technicalLocationController.dispose();
    departmentController.dispose();
    businessUnitController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Registro externo"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isTablet = width > 600;

            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 620 : 420,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Image.asset(
                        "assets/images/Registro.png",
                        height: isTablet ? 180 : 140,
                        fit: BoxFit.contain,
                      ),

                      const SizedBox(height: 16),

                      Text(
                        "Crear cuenta externa",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isTablet ? 28 : 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        "Completa tus datos para solicitar acceso a la aplicación.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 28),

                      _SectionTitle(
                        title: "Datos de usuario",
                        color: primaryColor,
                      ),

                      const SizedBox(height: 12),

                      _CustomTextField(
                        controller: usernameController,
                        label: "Nombre de usuario",
                        icon: Icons.person_outline,
                      ),

                      const SizedBox(height: 16),

                      _CustomTextField(
                        controller: emailController,
                        label: "Correo",
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 16),

                      _CustomTextField(
                        controller: passwordController,
                        label: "Contraseña",
                        icon: Icons.lock_outline,
                        obscureText: obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      _CustomTextField(
                        controller: confirmPasswordController,
                        label: "Confirmar contraseña",
                        icon: Icons.lock_outline,
                        obscureText: obscureConfirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              obscureConfirmPassword =
                              !obscureConfirmPassword;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 28),

                      _SectionTitle(
                        title: "Datos personales",
                        color: primaryColor,
                      ),

                      const SizedBox(height: 12),

                      _CustomTextField(
                        controller: nameController,
                        label: "Nombre",
                        icon: Icons.badge_outlined,
                      ),

                      const SizedBox(height: 16),

                      _CustomTextField(
                        controller: lastNamePController,
                        label: "Apellido paterno",
                        icon: Icons.badge_outlined,
                      ),

                      const SizedBox(height: 16),

                      _CustomTextField(
                        controller: lastNameMController,
                        label: "Apellido materno",
                        icon: Icons.badge_outlined,
                      ),

                      const SizedBox(height: 28),

                      _SectionTitle(
                        title: "Datos laborales",
                        color: primaryColor,
                      ),

                      const SizedBox(height: 12),

                      _CustomTextField(
                        controller: technicalLocationController,
                        label: "Ubicación técnica",
                        icon: Icons.location_on_outlined,
                      ),

                      const SizedBox(height: 16),

                      _CustomTextField(
                        controller: departmentController,
                        label: "Departamento",
                        icon: Icons.apartment_outlined,
                      ),

                      const SizedBox(height: 16),

                      _CustomTextField(
                        controller: businessUnitController,
                        label: "Unidad de negocio",
                        icon: Icons.business_outlined,
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Vista lista. Falta conectar la lógica.",
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            "Solicitar acceso",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Volver",
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionTitle({
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 22,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: primaryColor,
        ),
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(),
      ),
    );
  }
}