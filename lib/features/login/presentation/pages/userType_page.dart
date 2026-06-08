import 'package:flutter/material.dart';

import '../../../external_register/presentation/pages/external_register_page.dart';
import 'login_page.dart';

class UserTypePage extends StatelessWidget {
  const UserTypePage({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            final isSmallHeight = height < 700;
            final isPhone = width < 600;

            final containerWidth = width > 500 ? 400.0 : width * 0.9;

            final logoHeight = isSmallHeight
                ? 140.0
                : isPhone
                ? 200.0
                : 220.0;

            final titleSize = isSmallHeight ? 24.0 : 30.0;
            final subtitleSize = isSmallHeight ? 16.0 : 20.0;

            final topSpacing = isSmallHeight ? 10.0 : 20.0;
            final middleSpacing = isSmallHeight ? 18.0 : 30.0;
            final cardSpacing = isSmallHeight ? 12.0 : 18.0;

            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: height,
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: isSmallHeight ? 12 : 24,
                    ),
                    child: Container(
                      width: containerWidth,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assets/images/Original.png",
                            height: logoHeight,
                            fit: BoxFit.contain,
                          ),

                          SizedBox(height: topSpacing),

                          Text(
                            "Bienvenido",
                            style: TextStyle(
                              fontSize: titleSize,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            "Selecciona tu tipo de acceso",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: subtitleSize,
                            ),
                          ),

                          SizedBox(height: middleSpacing),

                          _AccessTypeButton(
                            icon: Icons.badge_outlined,
                            title: "Empleado interno",
                            subtitle: "Ingresa con tu número de empleado",
                            primaryColor: primaryColor,
                            isCompact: isSmallHeight,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginPage(),
                                ),
                              );
                            },
                          ),

                          SizedBox(height: cardSpacing),

                          _AccessTypeButton(
                            icon: Icons.person_outline,
                            title: "Usuario externo",
                            subtitle: "Solicita acceso como personal externo",
                            primaryColor: primaryColor,
                            isCompact: isSmallHeight,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ExternalRegisterPage(),
                                ),
                              );
                            },
                          ),

                          SizedBox(height: cardSpacing),

                          _AccessTypeButton(
                            icon: Icons.login_outlined,
                            title: "Ya tengo cuenta",
                            subtitle: "Inicia sesión con tu usuario registrado",
                            primaryColor: primaryColor,
                            isCompact: isSmallHeight,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
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

class _AccessTypeButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color primaryColor;
  final bool isCompact;
  final VoidCallback onTap;

  const _AccessTypeButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.primaryColor,
    required this.isCompact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconBoxSize = isCompact ? 46.0 : 54.0;
    final iconSize = isCompact ? 28.0 : 32.0;
    final titleSize = isCompact ? 16.0 : 18.0;
    final subtitleSize = isCompact ? 13.0 : 15.0;
    final verticalPadding = isCompact ? 14.0 : 20.0;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: 18,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: primaryColor,
              width: 1.6,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                width: iconBoxSize,
                height: iconBoxSize,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: iconSize,
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: subtitleSize,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

