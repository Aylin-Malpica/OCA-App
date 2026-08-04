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

  Future<void> upsertRemoteReport(
      LocalReport remoteReport,
      ) async {
    final box = Hive.box<LocalReport>("local_reports");

    final resultadoReporteId =
        remoteReport.resultadoReporteId;

    if (resultadoReporteId == null) {
      return;
    }

    dynamic existingKey;

    for (final key in box.keys) {
      final savedReport = box.get(key);

      if (savedReport?.resultadoReporteId ==
          resultadoReporteId) {
        existingKey = key;
        break;
      }
    }

    if (existingKey != null) {
      final existingReport = box.get(existingKey);

      if (existingReport == null) return;

      final mergedReport = remoteReport.copyWith(
        // Conservamos las rutas locales de evidencias.
        evidenciasPaths: existingReport.evidenciasPaths,
      );

      await box.put(existingKey, mergedReport);
    } else {
      await box.add(remoteReport);
    }
  }

  bool hasCompletedInitialReportsSync(
      int usuarioMovilId,
      ) {
    final box = Hive.box("sync_metadata");

    return box.get(
      "initial_reports_sync_$usuarioMovilId",
      defaultValue: false,
    ) ==
        true;
  }

  Future<void> markInitialReportsSyncCompleted(
      int usuarioMovilId,
      ) async {
    final box = Hive.box("sync_metadata");

    await box.put(
      "initial_reports_sync_$usuarioMovilId",
      true,
    );
  }
}