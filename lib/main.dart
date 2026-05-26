import 'package:app_oca/features/login/presentation/pages/userType_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/app_theme.dart';
import 'features/login/domain/entities/user.dart';
import 'features/login/presentation/pages/login_page.dart';
import 'features/reports/domain/entities/custom_field.dart';
import 'features/reports/domain/entities/element.dart';
import 'features/reports/domain/entities/element_detail.dart';
import 'features/reports/domain/entities/incident_type.dart';
import 'features/reports/domain/entities/local_report.dart';
import 'features/reports/domain/entities/report_category.dart';
import 'features/reports/domain/entities/report_type.dart';
import 'features/reports/domain/entities/report_element.dart';
import 'features/reports/domain/entities/risk_level.dart';
import 'features/reports/domain/entities/technical_location.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  /// 🔥 REGISTRAR ADAPTERS
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(ReportTypeAdapter());
  Hive.registerAdapter(ReportCategoryAdapter());
  Hive.registerAdapter(ReportElementAdapter());
  Hive.registerAdapter(CustomFieldAdapter());
  Hive.registerAdapter(RiskLevelAdapter());
  Hive.registerAdapter(IncidentTypeAdapter());
  Hive.registerAdapter(LocalReportAdapter());
  Hive.registerAdapter(ElementoAdapter());
  Hive.registerAdapter(ElementoDetalleAdapter());
  Hive.registerAdapter(TechnicalLocationAdapter());

  /// 🔥 ABRIR BOXES IMPORTANTES
  await Hive.openBox<User>("users");
  print("🟢 BOX USERS ABIERTO");
  await Hive.openBox<LocalReport>("local_reports");
  await Hive.openBox<TechnicalLocation>("technical_locations");

  /// 🔥 ENV
  await dotenv.load(fileName: ".env");
  print(dotenv.env['BASE_URL']);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const UserTypePage(),
    );

  }
}