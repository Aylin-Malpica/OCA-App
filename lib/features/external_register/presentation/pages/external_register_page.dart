import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/network/token_service.dart';
import '../../../login/presentation/pages/login_page.dart';
import '../../data/datasources/external_register_remote_datasource.dart';

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

  @override
  void initState() {
    super.initState();

    externalRegisterRemoteDatasource = ExternalRegisterRemoteDatasource(TokenService());

    loadInitialData();

    nameController.addListener(generateUsername);
    lastNamePController.addListener(generateUsername);
    lastNameMController.addListener(generateUsername);
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

      print("TOKEN EN REGISTRO EXTERNO: $token");

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

  Future<void> registerExternalUser() async {
    final nombreUsuario = usernameController.text.trim();
    final nombres = nameController.text.trim();
    final apellidoPaterno = lastNamePController.text.trim();
    final apellidoMaterno = lastNameMController.text.trim();
    final correo = emailController.text.trim();
    final contrasenia = passwordController.text.trim();
    final confirmarContrasenia = confirmPasswordController.text.trim();

    if (nombreUsuario.isEmpty) {
      showMsg("El nombre de usuario es obligatorio");
      return;
    }

    if (nombres.isEmpty) {
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

    if (contrasenia.isEmpty) {
      showMsg("Ingresa la contraseña");
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

    try {
      final response =
      await externalRegisterRemoteDatasource.registerExternalUser(
        nombreUsuario: nombreUsuario,
        nombres: nombres,
        apellidoPaterno: apellidoPaterno,
        apellidoMaterno: apellidoMaterno,
        correo: correo,
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

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text("Registro enviado"),
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Registro externo"),
        centerTitle: true,
      ),
      body: const SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text(
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
    );
  }

  Widget _buildInitialErrorView() {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Registro externo"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: primaryColor,
                ),
                const SizedBox(height: 20),
                const Text(
                  "No se pudo preparar el registro",
                  textAlign: TextAlign.center,
                  style: TextStyle(
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
                    child: const Text("Reintentar"),
                  ),
                ),
                const SizedBox(height: 12),
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
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final textColor = Theme.of(context).colorScheme.onSurface;

    if (loadingInitialData) {
      return _buildInitialLoadingView();
    }

    if (errorInitialData) {
      return _buildInitialErrorView();
    }

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
                        title: "Datos personales",
                        color: primaryColor,
                      ),

                      const SizedBox(height: 12),

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
                        helperText: "Opcional. Puedes dejarlo vacío.",
                      ),

                      const SizedBox(height: 28),

                      _SectionTitle(
                        title: "Acceso",
                        color: primaryColor,
                      ),

                      const SizedBox(height: 12),

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
                        title: "Datos laborales",
                        color: primaryColor,
                      ),

                      const SizedBox(height: 12),

                      DropdownButtonFormField<BusinessUnit>(
                        value: selectedBusinessUnit,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: "Unidad de negocio",
                          prefixIcon: Icon(
                            Icons.business_outlined,
                            color: primaryColor,
                          ),
                          border: const OutlineInputBorder(),
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
                        decoration: InputDecoration(
                          labelText: "Ubicación técnica",
                          prefixIcon: Icon(
                            Icons.location_on_outlined,
                            color: selectedBusinessUnit == null
                                ? Colors.grey
                                : primaryColor,
                          ),
                          border: const OutlineInputBorder(),
                          helperText: selectedBusinessUnit == null
                              ? "Primero selecciona una unidad de negocio"
                              : null,
                        ),
                        items: technicalLocations.map((location) {
                          return DropdownMenuItem<TechnicalLocation>(
                            value: location,
                            child: Text(
                              " ${location.denominacion}",
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
                        const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: LinearProgressIndicator(),
                        ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<Department>(
                        value: selectedDepartment,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: "Departamento",
                          prefixIcon: Icon(
                            Icons.apartment_outlined,
                            color: selectedBusinessUnit == null
                                ? Colors.grey
                                : primaryColor,
                          ),
                          border: const OutlineInputBorder(),
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
                        onChanged: selectedBusinessUnit == null || loadingDepartments
                            ? null
                            : (value) {
                          setState(() {
                            selectedDepartment = value;
                          });
                        },
                      ),
                      if (loadingDepartments)
                        const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: LinearProgressIndicator(),
                        ),
                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: loadingRegister ? null : registerExternalUser,
                          child: loadingRegister
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
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
    final primaryColor = Theme.of(context).colorScheme.primary;

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
          color: primaryColor,
        ),
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(),
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