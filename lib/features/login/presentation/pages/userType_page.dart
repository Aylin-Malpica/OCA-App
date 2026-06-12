import 'package:flutter/material.dart';

import '../../../../core/app_theme.dart';
import '../../../external_register/presentation/pages/external_register_page.dart';
import 'login_page.dart';

class UserTypePage extends StatelessWidget {
  const UserTypePage({super.key});

  static const Color accentColor = Color(0xFF5F5DFD);
  static const Color softBackground = Color(0xFFF6F7FB);

  @override
  Widget build(BuildContext context) {
    final goldColor = AppTheme.dorado;
    final blueColor = AppTheme.azul;
    final blueColor2 = AppTheme.azulOscuro;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: softBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            final isSmallHeight = height < 700;
            final isTablet = width > 600;

            final containerWidth = isTablet ? 460.0 : width * 0.90;

            final logoHeight = isSmallHeight
                ? 110.0
                : isTablet
                ? 180.0
                : 150.0;

            return Stack(
              children: [
                Positioned(
                  top: -90,
                  right: -70,
                  child: _DecorativeCircle(
                    size: 190,
                    color: blueColor.withOpacity(0.10),
                  ),
                ),

                Positioned(
                  top: 105,
                  left: -55,
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
                    color: accentColor.withOpacity(0.08),
                  ),
                ),

                SingleChildScrollView(
                  keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: height,
                    ),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallHeight ? 14 : 26,
                        ),
                        child: SizedBox(
                          width: containerWidth,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 12,
                                ),

                                child: Image.asset(
                                  "assets/images/Original.png",
                                  height: logoHeight,
                                  fit: BoxFit.contain,
                                ),
                              ),

                              SizedBox(height: isSmallHeight ? 16 : 22),

                              Text(
                                "Bienvenido",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: isSmallHeight ? 25 : 30,
                                  fontWeight: FontWeight.bold,
                                  color: blueColor2,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                "Accede a tu cuenta o selecciona el tipo de registro que necesitas.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: textColor.withOpacity(0.60),
                                  fontSize: 15,
                                  height: 1.35,
                                ),
                              ),

                              SizedBox(height: isSmallHeight ? 22 : 30),

                              _SectionHeader(
                                title: "Acceso",
                                subtitle:
                                "Si ya tienes una cuenta registrada, inicia sesión.",
                                color: blueColor,
                              ),

                              const SizedBox(height: 12),

                              _OptionCard(
                                icon: Icons.login_outlined,
                                title: "Ya soy usuario",
                                subtitle:
                                "Inicia sesión con tu cuenta registrada.",
                                iconColor: goldColor,
                                borderColor: goldColor,
                                backgroundColor: Colors.white,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginPage(),
                                    ),
                                  );
                                },
                              ),

                              SizedBox(height: isSmallHeight ? 20 : 26),

                              _SectionHeader(
                                title: "Nuevo registro",
                                subtitle:
                                "Elige el tipo de usuario para iniciar tu solicitud.",
                                color: blueColor,
                              ),

                              const SizedBox(height: 12),

                              _OptionCard(
                                icon: Icons.badge_outlined,
                                title: "Empleado interno",
                                subtitle: "Regístrate usando tu número de empleado.",
                                iconColor: goldColor,
                                borderColor: goldColor.withOpacity(0.28),
                                backgroundColor: Colors.white,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginPage(),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 12),

                              _OptionCard(
                                icon: Icons.person_outline,
                                title: "Usuario externo",
                                subtitle: "Solicita acceso como personal externo.",
                                iconColor: goldColor,
                                borderColor: goldColor.withOpacity(0.28),
                                backgroundColor: Colors.white,
                                onTap: () {//
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ExternalRegisterPage(),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 5,
          height: 38,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                subtitle,
                style: TextStyle(
                  color: textColor.withOpacity(0.55),
                  fontSize: 13,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color borderColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.borderColor,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(
              color: borderColor,
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0C274B).withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 27,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor.withOpacity(0.55),
                        fontSize: 13,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: iconColor,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}