import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../login/domain/entities/internal_employee_data.dart';
import '../../external_register/data/datasources/external_register_remote_datasource.dart';
import '../../../core/network/token_service.dart';
import '../../login/presentation/pages/login_page.dart';

class InternalRegisterFormPage extends StatefulWidget {
  final InternalEmployeeData empleado;

  const InternalRegisterFormPage({
    super.key,
    required this.empleado,
  });

  @override
  State<InternalRegisterFormPage> createState() =>
      _InternalRegisterFormPageState();
}

class _InternalRegisterFormPageState extends State<InternalRegisterFormPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  late ExternalRegisterRemoteDatasource remoteDatasource;

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  bool loadingInitialData = true;
  bool errorInitialData = false;
  bool loadingRegister = false;

  List<InternalTechnicalLocation> technicalLocations = [];
  List<InternalDepartment> departments = [];

  InternalTechnicalLocation? selectedTechnicalLocation;
  InternalDepartment? selectedDepartment;

  @override
  void initState() {
    super.initState();

    remoteDatasource = ExternalRegisterRemoteDatasource(TokenService());
    emailController.text = widget.empleado.correoLimpio;

    loadInitialData();
  }

  Future<void> loadInitialData() async {
    setState(() {
      loadingInitialData = true;
      errorInitialData = false;
      technicalLocations = [];
      departments = [];
      selectedTechnicalLocation = null;
      selectedDepartment = null;
    });

    try {
      final technicalLocationResult =
      await remoteDatasource.getTechnicalLocations(
        unidadNegocioId: widget.empleado.unidadNegocioId,
      );

      final departmentResult = await remoteDatasource.getDepartments();

      if (!mounted) return;

      setState(() {
        technicalLocations = technicalLocationResult
            .map((item) => InternalTechnicalLocation.fromJson(item))
            .where((item) =>
        item.ubicacionTecnicaId != 0 &&
            item.descripcion.trim().isNotEmpty)
            .toList();

        departments = departmentResult
            .map((item) => InternalDepartment.fromJson(item))
            .where((item) =>
        item.departamentoId != 0 &&
            item.descripcion.trim().isNotEmpty)
            .toList();

        loadingInitialData = false;
        errorInitialData = false;
      });
    } catch (e) {
      print("ERROR LOAD INTERNAL REGISTER DATA: $e");

      if (!mounted) return;

      setState(() {
        loadingInitialData = false;
        errorInitialData = true;
      });
    }
  }

  String? validatePassword(String password) {
    if (password.length < 8) {
      return "La contraseña debe tener mínimo 8 caracteres";
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return "La contraseña debe incluir al menos una mayúscula";
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return "La contraseña debe incluir al menos un número";
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=/\\[\];]').hasMatch(password)) {
      return "La contraseña debe incluir al menos un carácter especial";
    }

    return null;
  }

  Future<void> continueRegister() async {
    final correo = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (password.isEmpty) {
      showMsg("Ingresa la contraseña");
      return;
    }

    final passwordError = validatePassword(password);

    if (passwordError != null) {
      showMsg(passwordError);
      return;
    }

    if (confirmPassword.isEmpty) {
      showMsg("Confirma la contraseña");
      return;
    }

    if (password != confirmPassword) {
      showMsg("Las contraseñas no coinciden");
      return;
    }

    if (selectedTechnicalLocation == null) {
      showMsg("Selecciona una ubicación técnica");
      return;
    }

    if (selectedDepartment == null) {
      showMsg("Selecciona un departamento");
      return;
    }

    final numeroEmpleado = "000${widget.empleado.numeroEmpleado.trim()}";

    setState(() {
      loadingRegister = true;
    });

    try {
      final response = await remoteDatasource.registerInternalUser(
        numeroEmpleado: numeroEmpleado,
        correo: correo,
        contrasenia: password,
        departamentoId: selectedDepartment!.departamentoId,
        ubicacionTecnicaId: selectedTechnicalLocation!.ubicacionTecnicaId,
      );

      if (!mounted) return;

      setState(() {
        loadingRegister = false;
      });

      final success = response["success"] == true;
      final message = response["message"]?.toString() ??
          "Tu registro fue completado correctamente.";

      if (!success) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("No se pudo completar el registro"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Aceptar"),
              ),
            ],
          ),
        );
        return;
      }

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text("Registro completado"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginPage(),
                  ),
                      (route) => false,
                );
              },
              child: const Text("Aceptar"),
            ),
          ],
        ),
      );
    } catch (e) {
      print("ERROR INTERNAL REGISTER: $e");

      if (!mounted) return;

      setState(() {
        loadingRegister = false;
      });

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: Text(
            e.toString().replaceAll("Exception: ", ""),
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
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Widget _buildLoadingView() {
    final goldColor = AppTheme.dorado;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text("Registro interno"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: goldColor.withOpacity(0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: goldColor,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Preparando registro interno...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    final blueColor = AppTheme.azul;
    final goldColor = AppTheme.dorado;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text("Registro interno"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(22),
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: goldColor,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "No se pudo preparar el registro",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: blueColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "No fue posible cargar las ubicaciones técnicas o departamentos. Verifica tu conexión e intenta nuevamente.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: loadInitialData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: goldColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text("Reintentar"),
                    ),
                  ),
                  const SizedBox(height: 12),
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
      ),
    );
  }

  InputDecoration _dropdownDecoration({
    required String label,
    required IconData icon,
    required Color goldColor,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        color: goldColor,
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
    );
  }

  @override
  void dispose() {
    passwordController.dispose();
    emailController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final blueColor = AppTheme.azul;
    final goldColor = AppTheme.dorado;
    final textColor = Theme.of(context).colorScheme.onSurface;

    if (loadingInitialData) {
      return _buildLoadingView();
    }

    if (errorInitialData) {
      return _buildErrorView();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text("Registro interno"),
        centerTitle: true,
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
            top: 160,
            left: -65,
            child: _DecorativeCircle(
              size: 130,
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
                final width = constraints.maxWidth;
                final isTablet = width > 600;
                final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

                return SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 20,
                    bottom: keyboardHeight + 24,
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
                            height: isTablet ? 170 : 130,
                            fit: BoxFit.contain,
                          ),

                          const SizedBox(height: 16),

                          Text(
                            "Completa tu registro",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isTablet ? 28 : 24,
                              fontWeight: FontWeight.bold,
                              color: blueColor,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            "Confirma tus datos y completa la información requerida.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: textColor.withOpacity(0.55),
                              fontSize: 15,
                              height: 1.3,
                            ),
                          ),

                          const SizedBox(height: 26),

                          _EmployeeSummaryCard(
                            empleado: widget.empleado,
                            blueColor: blueColor,
                            goldColor: goldColor,
                          ),

                          const SizedBox(height: 20),

                          _FormSectionCard(
                            title: "Seguridad",
                            blueColor: blueColor,
                            goldColor: goldColor,
                            children: [
                              _CustomTextField(
                                controller: emailController,
                                label: "Correo",
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                helperText: "Opcional",
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
                                    color: goldColor,
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
                                    color: goldColor,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      obscureConfirmPassword =
                                      !obscureConfirmPassword;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          _FormSectionCard(
                            title: "Datos laborales",
                            blueColor: blueColor,
                            goldColor: goldColor,
                            children: [
                              DropdownButtonFormField<InternalTechnicalLocation>(
                                value: selectedTechnicalLocation,
                                isExpanded: true,
                                decoration: _dropdownDecoration(
                                  label: "Ubicación técnica",
                                  icon: Icons.location_on_outlined,
                                  goldColor: goldColor,
                                ),
                                items: technicalLocations.map((location) {
                                  return DropdownMenuItem<InternalTechnicalLocation>(
                                    value: location,
                                    child: Text(
                                      location.descripcionCompleta,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedTechnicalLocation = value;
                                  });
                                },
                              ),

                              const SizedBox(height: 16),

                              DropdownButtonFormField<InternalDepartment>(
                                value: selectedDepartment,
                                isExpanded: true,
                                decoration: _dropdownDecoration(
                                  label: "Departamento",
                                  icon: Icons.apartment_outlined,
                                  goldColor: goldColor,
                                ),
                                items: departments.map((department) {
                                  return DropdownMenuItem<InternalDepartment>(
                                    value: department,
                                    child: Text(
                                      department.descripcion,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedDepartment = value;
                                  });
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: loadingRegister ? null : continueRegister,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: goldColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: loadingRegister
                                  ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                                  : const Text(
                                "Finalizar registro",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class InternalTechnicalLocation {
  final int ubicacionTecnicaId;
  final String claveUbicacionTecnica;
  final String denominacion;

  InternalTechnicalLocation({
    required this.ubicacionTecnicaId,
    required this.claveUbicacionTecnica,
    required this.denominacion,
  });

  String get descripcion {
    return denominacion.trim();
  }

  String get descripcionCompleta {

    final nombre = denominacion.trim();

    return "$nombre";
  }

  factory InternalTechnicalLocation.fromJson(Map<String, dynamic> json) {
    return InternalTechnicalLocation(
      ubicacionTecnicaId: json["ubicacionTecnicaId"] ?? json["id"] ?? 0,
      claveUbicacionTecnica: json["claveUbicacionTecnica"]?.toString() ?? "",
      denominacion: json["denominacion"]?.toString() ??
          json["descripcion"]?.toString() ??
          json["nombre"]?.toString() ??
          "",
    );
  }
}

class InternalDepartment {
  final int departamentoId;
  final String descripcion;

  InternalDepartment({
    required this.departamentoId,
    required this.descripcion,
  });

  factory InternalDepartment.fromJson(Map<String, dynamic> json) {
    return InternalDepartment(
      departamentoId: json["departamentoId"] ?? json["id"] ?? 0,
      descripcion: json["descripcion"]?.toString() ??
          json["nombre"]?.toString() ??
          json["nombreDepartamento"]?.toString() ??
          "",
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color color;
  final Color? titleColor;

  const _SectionTitle({
    required this.title,
    required this.color,
    this.titleColor,
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
            color: titleColor ?? Theme.of(context).colorScheme.onSurface,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _EmployeeSummaryCard extends StatelessWidget {
  final InternalEmployeeData empleado;
  final Color blueColor;
  final Color goldColor;

  const _EmployeeSummaryCard({
    required this.empleado,
    required this.blueColor,
    required this.goldColor,
  });

  String formatEmployeeNumber(String value) {
    return "000${value.trim()}";
  }

  @override
  Widget build(BuildContext context) {
    final numeroEmpleado = formatEmployeeNumber(
      empleado.numeroEmpleado,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: goldColor.withOpacity(0.22),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(18),
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
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: goldColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.badge_outlined,
                  color: goldColor,
                  size: 27,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      empleado.nombreLimpio,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: blueColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "Empleado $numeroEmpleado",
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.55),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _MiniEmployeeInfo(
                  label: "Unidad",
                  value: empleado.unidadNegocioLimpia.isEmpty
                      ? "Sin unidad"
                      : empleado.unidadNegocioLimpia,
                  goldColor: goldColor,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _MiniEmployeeInfo(
                  label: "Correo",
                  value: empleado.correoLimpio.isEmpty
                      ? "Sin correo"
                      : empleado.correoLimpio,
                  goldColor: goldColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniEmployeeInfo extends StatelessWidget {
  final String label;
  final String value;
  final Color goldColor;

  const _MiniEmployeeInfo({
    required this.label,
    required this.value,
    required this.goldColor,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: goldColor.withOpacity(0.14),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: textColor.withOpacity(0.50),
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? helperText;

  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    final goldColor = AppTheme.dorado;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        prefixIcon: Icon(
          icon,
          color: goldColor,
        ),
        suffixIcon: suffixIcon,
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

class _FormSectionCard extends StatelessWidget {
  final String title;
  final Color blueColor;
  final Color goldColor;
  final List<Widget> children;

  const _FormSectionCard({
    required this.title,
    required this.blueColor,
    required this.goldColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: goldColor.withOpacity(0.18),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionTitle(
            title: title,
            color: goldColor,
            titleColor: blueColor,
          ),

          const SizedBox(height: 14),

          ...children,
        ],
      ),
    );
  }
}