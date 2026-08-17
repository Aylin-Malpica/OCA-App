import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/network/token_service.dart';
import '../../../login/presentation/pages/login_page.dart';
import '../../data/datasources/external_register_remote_datasource.dart';
import '../../../../core/app_theme.dart';
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
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  late ExternalRegisterRemoteDatasource externalRegisterRemoteDatasource;

  bool loadingRegister = false;

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  bool loadingInitialData = true;
  bool errorInitialData = false;
  bool loadingDepartments = false;
  bool loadingTechnicalLocations = false;

  List<BusinessUnit> businessUnits = [];
  List<TechnicalLocation> technicalLocations = [];
  List<Department> departments = [];

  Department? selectedDepartment;
  BusinessUnit? selectedBusinessUnit;
  TechnicalLocation? selectedTechnicalLocation;

  bool hasMinLength = false;
  bool hasUppercase = false;
  bool hasNumber = false;
  bool hasSpecialChar = false;

  @override
  void initState() {
    super.initState();

    externalRegisterRemoteDatasource = ExternalRegisterRemoteDatasource(TokenService());

    loadInitialData();

    nameController.addListener(generateUsername);
    lastNamePController.addListener(generateUsername);
    lastNameMController.addListener(generateUsername);

    passwordController.addListener(() {
      validatePasswordLive(passwordController.text);
    });
  }

  void validatePasswordLive(String password) {
    setState(() {
      hasMinLength = password.length >= 8;
      hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
      hasNumber = RegExp(r'[0-9]').hasMatch(password);
      hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=/\\[\];]').hasMatch(password);
    });
  }

  Widget _passwordRequirement({
    required bool isValid,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: isValid ? Colors.green : AppTheme.textColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: isValid ? Colors.green : AppTheme.textColor,
                fontWeight: isValid ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> loadInitialData() async {
    setState(() {
      loadingInitialData = true;
      errorInitialData = false;
      selectedBusinessUnit = null;
      selectedTechnicalLocation = null;
      technicalLocations = [];
      businessUnits = [];
    });

    try {
      final token = await TokenService().getToken();

      if (token == null || token.isEmpty) {
        throw Exception("No se pudo obtener token");
      }

      final result = await externalRegisterRemoteDatasource.getBusinessUnits();

      if (!mounted) return;

      setState(() {
        businessUnits = result
            .map((item) => BusinessUnit.fromJson(item))
            .where((item) => item.unidadNegocioId != 0 && item.nombre.trim().isNotEmpty)
            .toList();

        loadingInitialData = false;
        errorInitialData = false;
      });
    } catch (e) {
      print("ERROR LOAD INITIAL EXTERNAL REGISTER DATA: $e");

      if (!mounted) return;

      setState(() {
        loadingInitialData = false;
        errorInitialData = true;
      });
    }
  }

  Future<void> loadTechnicalLocationsByBusinessUnit(int unidadNegocioId,) async {
    setState(() {
      loadingTechnicalLocations = true;
      selectedTechnicalLocation = null;
      technicalLocations = [];
    });

    try {
      final result =
      await externalRegisterRemoteDatasource.getTechnicalLocations(
        unidadNegocioId: unidadNegocioId,
      );

      if (!mounted) return;

      setState(() {
        technicalLocations = result
            .map((item) => TechnicalLocation.fromJson(item))
            .where((item) => item.ubicacionTecnicaId != 0)
            .toList();

        loadingTechnicalLocations = false;
      });
    } catch (e) {
      print("ERROR LOAD EXTERNAL TECHNICAL LOCATIONS: $e");

      if (!mounted) return;

      setState(() {
        loadingTechnicalLocations = false;
      });

      showMsg("No se pudieron cargar las ubicaciones técnicas");
    }
  }

  Future<void> loadDepartments() async {
    setState(() {
      loadingDepartments = true;
      selectedDepartment = null;
      departments = [];
    });

    try {
      final result = await externalRegisterRemoteDatasource.getDepartments();

      if (!mounted) return;

      setState(() {
        departments = result
            .map((item) => Department.fromJson(item))
            .where((item) =>
        item.departamentoId != 0 && item.descripcion.trim().isNotEmpty)
            .toList();

        loadingDepartments = false;
      });
    } catch (e) {
      print("ERROR LOAD EXTERNAL DEPARTMENTS: $e");

      if (!mounted) return;

      setState(() {
        loadingDepartments = false;
      });

      showMsg("No se pudieron cargar los departamentos");
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

  Future<void> registerExternalUser() async {
    final nombreUsuario = usernameController.text.trim();
    final nombres = nameController.text.trim();
    final apellidoPaterno = lastNamePController.text.trim();
    final apellidoMaterno = lastNameMController.text.trim();

    final correo = emailController.text.trim();
    final telefono = phoneController.text.trim();

    final contrasenia = passwordController.text.trim();
    final confirmarContrasenia = confirmPasswordController.text.trim();

    if (nombreUsuario.isEmpty) {
      showMsg("El nombre de usuario es obligatorio");
      return;
    }

    if (nombres.isEmpty) {//
      showMsg("Ingresa el nombre");
      return;
    }

    if (apellidoPaterno.isEmpty) {
      showMsg("Ingresa el apellido paterno");
      return;
    }

    if (apellidoMaterno.isEmpty) {
      showMsg("Ingresa el apellido materno");
      return;
    }


    if (correo.isEmpty) {
      showMsg("El correo es obligatorio");
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(correo)) {
      showMsg("Ingresa un correo válido");
      return;
    }


    if (contrasenia.isEmpty) {
      showMsg("Ingresa la contraseña");
      return;
    }

    final passwordError = validatePassword(contrasenia);

    if (passwordError != null) {
      showMsg(passwordError);
      return;
    }

    if (confirmarContrasenia.isEmpty) {
      showMsg("Confirma la contraseña");
      return;
    }

    if (contrasenia != confirmarContrasenia) {
      showMsg("Las contraseñas no coinciden");
      return;
    }

    if (selectedBusinessUnit == null) {
      showMsg("Selecciona una unidad de negocio");
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

    setState(() {
      loadingRegister = true;
    });

    final usuarioGenerado = nombreUsuario;

    try {
      final response =
      await externalRegisterRemoteDatasource.registerExternalUser(
        nombreUsuario: nombreUsuario,
        nombres: nombres,
        apellidoPaterno: apellidoPaterno,
        apellidoMaterno: apellidoMaterno,
        correo: correo,
        telefono: telefono,
        contrasenia: contrasenia,
        confirmarContrasenia: confirmarContrasenia,
        unidadNegocioId: selectedBusinessUnit!.unidadNegocioId,
        departamentoId: selectedDepartment!.departamentoId,
        ubicacionTecnicaId: selectedTechnicalLocation!.ubicacionTecnicaId,
      );

      if (!mounted) return;

      setState(() {
        loadingRegister = false;
      });

      final success = response["success"] == true;
      final message = response["message"]?.toString() ??
          "Tu solicitud de registro externo fue enviada correctamente.";

      if (!success) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("No se pudo registrar"),
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

      final generatedUsername = usuarioGenerado;

      final navigator = Navigator.of(context);

      final accepted = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          titlePadding: EdgeInsets.zero,
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppTheme.azulOscuro,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: Colors.white,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Registro enviado",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.dorado.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: AppTheme.dorado,
                  size: 34,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppTheme.textColor,
                ),
              ),

              const SizedBox(height: 18),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.dorado.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.dorado.withOpacity(0.35),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Tu nombre de usuario es:",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      generatedUsername,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        color: AppTheme.marBaltico,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Guárdalo o recuérdalo, lo necesitarás para iniciar sesión.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 12),

              const Text(
                "Espera a que tu encargado de zona habilite tu acceso.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color:Colors.red,
                ),
              ),

            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.dorado,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Aceptar"),
              ),
            ),
          ],
        ),
      );

      if (accepted == true) {
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const LoginPage(),
          ),
              (route) => false,
        );
      }

      return;

    } catch (e) {
      print("ERROR REGISTER EXTERNAL USER: $e");

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
  void generateUsername() {
    final fullName = nameController.text.trim();
    final lastNameP = lastNamePController.text.trim();
    final lastNameM = lastNameMController.text.trim();

    if (fullName.isEmpty) {
      usernameController.text = "";
      return;
    }

    final nameParts = fullName
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList();

    if (nameParts.isEmpty) {
      usernameController.text = "";
      return;
    }

    final firstName = _capitalizeFirstLetter(nameParts.first);

    final otherNameInitials = nameParts
        .skip(1)
        .map((part) => part[0].toUpperCase())
        .join();

    final lastNamePInitial =
    lastNameP.isNotEmpty ? lastNameP[0].toUpperCase() : "";

    final lastNameMInitial =
    lastNameM.isNotEmpty ? lastNameM[0].toUpperCase() : "";

    final generatedUsername =
        "$firstName$otherNameInitials$lastNamePInitial$lastNameMInitial";

    if (usernameController.text != generatedUsername) {
      usernameController.text = generatedUsername;
    }
  }

  String _capitalizeFirstLetter(String value) {
    if (value.isEmpty) return "";

    final lowerValue = value.toLowerCase();

    return lowerValue[0].toUpperCase() + lowerValue.substring(1);
  }

  Widget _buildInitialLoadingView() {
    final goldColor = AppTheme.dorado;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text("Registro externo"),
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
                    "Preparando registro externo...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
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

  Widget _buildInitialErrorView() {
    final blueColor = AppTheme.azul;
    final goldColor = AppTheme.dorado;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text("Registro externo"),
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
                    "No fue posible obtener el token o cargar las unidades de negocio. Verifica tu conexión e intenta nuevamente.",
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

  @override
  void dispose() {
    nameController.removeListener(generateUsername);
    lastNamePController.removeListener(generateUsername);
    lastNameMController.removeListener(generateUsername);

    usernameController.dispose();
    nameController.dispose();
    lastNamePController.dispose();
    lastNameMController.dispose();
    departmentController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
  InputDecoration _dropdownDecoration({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color goldColor,
    String? helperText,
  }) {
    return InputDecoration(
      labelText: label,
      helperText: helperText,
      prefixIcon: Icon(
        icon,
        color: goldColor,
      ),
      filled: true,
      fillColor: const Color(0xFFF9FAFC),//
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
  Widget build(BuildContext context) {
    final blueColor = AppTheme.azul;
    final blueColor2 = AppTheme.azulOscuro;
    final goldColor = AppTheme.dorado;
    final textColor = Theme.of(context).colorScheme.onSurface;

    if (loadingInitialData) {
      return _buildInitialLoadingView();
    }

    if (errorInitialData) {
      return _buildInitialErrorView();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text("Registro externo"),
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
                            "Crear cuenta externa",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isTablet ? 28 : 24,
                              fontWeight: FontWeight.bold,
                              color: blueColor2,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            "Completa tus datos para solicitar acceso a la aplicación.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: textColor.withOpacity(0.55),
                              fontSize: 15,
                              height: 1.3,
                            ),
                          ),

                          const SizedBox(height: 26),

                          _FormSectionCard(
                            title: "Datos personales",
                            blueColor: blueColor,
                            goldColor: goldColor,
                            children: [
                              _CustomTextField(
                                controller: nameController,
                                label: "Nombre",
                                icon: Icons.badge_outlined,
                                inputFormatters: [
                                  CapitalizeFirstLetterFormatter(),
                                ],
                              ),

                              const SizedBox(height: 16),

                              _CustomTextField(
                                controller: lastNamePController,
                                label: "Apellido paterno",
                                icon: Icons.badge_outlined,
                                inputFormatters: [
                                  CapitalizeFirstLetterFormatter(),
                                ],
                              ),

                              const SizedBox(height: 16),

                              _CustomTextField(
                                controller: lastNameMController,
                                label: "Apellido materno",
                                icon: Icons.badge_outlined,
                                inputFormatters: [
                                  CapitalizeFirstLetterFormatter(),
                                ],
                              ),

                              const SizedBox(height: 16),

                              _CustomTextField(
                                controller: usernameController,
                                label: "Nombre de usuario",
                                icon: Icons.person_outline,
                                readOnly: true,
                              ),

                              const SizedBox(height: 16),

                              _CustomTextField(
                                controller: emailController,
                                label: "Correo",
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          _FormSectionCard(
                            title: "Acceso",
                            blueColor: blueColor,
                            goldColor: goldColor,
                            children: [
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

                              const SizedBox(height: 10),

                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.dorado.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.dorado.withOpacity(0.25),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "La contraseña debe contener:",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.marBaltico,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    _passwordRequirement(
                                      isValid: hasMinLength,
                                      text: "Mínimo 8 caracteres",
                                    ),
                                    _passwordRequirement(
                                      isValid: hasUppercase,
                                      text: "Al menos 1 letra mayúscula",
                                    ),
                                    _passwordRequirement(
                                      isValid: hasNumber,
                                      text: "Al menos 1 número",
                                    ),
                                    _passwordRequirement(
                                      isValid: hasSpecialChar,
                                      text: "Al menos 1 carácter especial",
                                    ),
                                  ],
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
                              DropdownButtonFormField<BusinessUnit>(
                                value: selectedBusinessUnit,
                                isExpanded: true,
                                decoration: _dropdownDecoration(
                                  context: context,
                                  label: "Unidad de negocio",
                                  icon: Icons.business_outlined,
                                  goldColor: goldColor,
                                ),
                                items: businessUnits.map((unit) {
                                  return DropdownMenuItem<BusinessUnit>(
                                    value: unit,
                                    child: Text(
                                      unit.nombre,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedBusinessUnit = value;
                                    selectedTechnicalLocation = null;
                                    selectedDepartment = null;
                                    technicalLocations = [];
                                    departments = [];
                                  });

                                  if (value != null) {
                                    loadTechnicalLocationsByBusinessUnit(
                                      value.unidadNegocioId,
                                    );

                                    loadDepartments();
                                  }
                                },
                              ),

                              const SizedBox(height: 16),

                              DropdownButtonFormField<TechnicalLocation>(
                                value: selectedTechnicalLocation,
                                isExpanded: true,
                                decoration: _dropdownDecoration(
                                  context: context,
                                  label: "Ubicación técnica",
                                  icon: Icons.location_on_outlined,
                                  goldColor: selectedBusinessUnit == null
                                      ? Colors.grey
                                      : goldColor,
                                  helperText: selectedBusinessUnit == null
                                      ? "Primero selecciona una unidad de negocio"
                                      : null,
                                ),
                                items: technicalLocations.map((location) {
                                  return DropdownMenuItem<TechnicalLocation>(
                                    value: location,
                                    child: Text(
                                      location.denominacion,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: selectedBusinessUnit == null ||
                                    loadingTechnicalLocations
                                    ? null
                                    : (value) {
                                  setState(() {
                                    selectedTechnicalLocation = value;
                                  });
                                },
                              ),

                              if (loadingTechnicalLocations)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: LinearProgressIndicator(
                                    color: goldColor,
                                    backgroundColor: goldColor.withOpacity(0.12),
                                  ),
                                ),

                              const SizedBox(height: 16),

                              DropdownButtonFormField<Department>(
                                value: selectedDepartment,
                                isExpanded: true,
                                decoration: _dropdownDecoration(
                                  context: context,
                                  label: "Departamento",
                                  icon: Icons.apartment_outlined,
                                  goldColor: selectedBusinessUnit == null
                                      ? Colors.grey
                                      : goldColor,
                                  helperText: selectedBusinessUnit == null
                                      ? "Primero selecciona una unidad de negocio"
                                      : null,
                                ),
                                items: departments.map((department) {
                                  return DropdownMenuItem<Department>(
                                    value: department,
                                    child: Text(
                                      department.descripcion,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: selectedBusinessUnit == null ||
                                    loadingDepartments
                                    ? null
                                    : (value) {
                                  setState(() {
                                    selectedDepartment = value;
                                  });
                                },
                              ),

                              if (loadingDepartments)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: LinearProgressIndicator(
                                    color: goldColor,
                                    backgroundColor: goldColor.withOpacity(0.12),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed:
                              loadingRegister ? null : registerExternalUser,
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
                                "Solicitar acceso",
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

class BusinessUnit {
  final int unidadNegocioId;
  final String nombre;

  BusinessUnit({
    required this.unidadNegocioId,
    required this.nombre,
  });

  factory BusinessUnit.fromJson(Map<String, dynamic> json) {
    return BusinessUnit(
      unidadNegocioId: json["unidadNegocioId"] ?? json["id"] ?? 0,
      nombre: json["descripcion"] ??
          json["nombre"] ??
          json["nombreUnidadNegocio"] ??
          json["denominacion"] ??
          "",
    );
  }
}

class TechnicalLocation {
  final int ubicacionTecnicaId;
  final String claveUbicacionTecnica;
  final String denominacion;

  TechnicalLocation({
    required this.ubicacionTecnicaId,
    required this.claveUbicacionTecnica,
    required this.denominacion,
  });

  factory TechnicalLocation.fromJson(Map<String, dynamic> json) {
    return TechnicalLocation(
      ubicacionTecnicaId: json["ubicacionTecnicaId"] ?? json["id"] ?? 0,
      claveUbicacionTecnica: json["claveUbicacionTecnica"] ?? "",
      denominacion: json["denominacion"] ?? json["nombre"] ?? "",
    );
  }
}

class Department {
  final int departamentoId;
  final String descripcion;

  Department({
    required this.departamentoId,
    required this.descripcion,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      departamentoId: json["departamentoId"] ?? json["id"] ?? 0,
      descripcion: json["descripcion"] ??
          json["nombre"] ??
          json["nombreDepartamento"] ??
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

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final bool readOnly;
  final String? helperText;
  final List<TextInputFormatter>? inputFormatters;

  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.readOnly = false,
    this.helperText,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final goldColor = AppTheme.dorado;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      readOnly: readOnly,
      inputFormatters: inputFormatters,
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

class CapitalizeFirstLetterFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final text = newValue.text;

    final capitalizedText = text[0].toUpperCase() + text.substring(1);

    return newValue.copyWith(
      text: capitalizedText,
      selection: newValue.selection,
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