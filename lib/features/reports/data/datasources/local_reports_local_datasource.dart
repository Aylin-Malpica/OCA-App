import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/local_report.dart';

class LocalReportsLocalDatasource {
  Future<void> saveReport(LocalReport report) async {
    final box = Hive.box<LocalReport>("local_reports");
    await box.add(report);
  }

  Future<List<LocalReport>> getReports() async {
    final box = Hive.box<LocalReport>("local_reports");
    return box.values.toList();
  }

  Future<Map<dynamic, LocalReport>> getReportsWithKeys() async {
    final box = Hive.box<LocalReport>("local_reports");
    return box.toMap().cast<dynamic, LocalReport>();
  }

  Future<void> updateReport(dynamic key, LocalReport report) async {
    final box = Hive.box<LocalReport>("local_reports");
    await box.put(key, report);
  }

  Future<void> deleteReport(dynamic key) async {
    final box = Hive.box<LocalReport>("local_reports");
    await box.delete(key);
  }



  Future<Map<dynamic, LocalReport>> getReportsByUser(String numeroEmpleado) async {
    final box = Hive.box<LocalReport>("local_reports");

    final key = numeroEmpleado.trim().toLowerCase();

    return Map.fromEntries(
      box.toMap().entries.where(
            (e) => e.value.numeroEmpleado.trim().toLowerCase() == key,
      ),
    );
  }
}