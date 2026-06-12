import 'package:flutter/material.dart';
import '../../../../core/app_theme.dart';
import '../../login/domain/entities/internal_employee_data.dart';
import 'internal_register_form_page.dart';

class InternalRegisterPreviewPage extends StatelessWidget {
  final InternalEmployeeData empleado;

  const InternalRegisterPreviewPage({
    super.key,
    required this.empleado,
  });

  @override
  Widget build(BuildContext context) {
    final blueColor2 = AppTheme.azulOscuro;
    final blueColor = AppTheme.azul;
    final goldColor = AppTheme.dorado;
    final textColor = Theme.of(context).colorScheme.onSurface;

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
                            height: isTablet ? 170 : 130,
                            fit: BoxFit.contain,
                          ),

                          const SizedBox(height: 16),

                          Text(
                            "Confirma tus datos",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isTablet ? 28 : 24,
                              fontWeight: FontWeight.bold,
                              color: blueColor2,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            "Encontramos tu información como empleado. Revisa que tus datos sean correctos para continuar con tu registro.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: textColor.withOpacity(0.55),
                              fontSize: 15,
                              height: 1.3,
                            ),
                          ),

                          const SizedBox(height: 26),

                          _EmployeeSummaryCard(
                            empleado: empleado,
                            blueColor: blueColor,
                            goldColor: goldColor,
                          ),

                          const SizedBox(height: 30),

                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => InternalRegisterFormPage(
                                      empleado: empleado,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: goldColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                "Continuar registro",
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