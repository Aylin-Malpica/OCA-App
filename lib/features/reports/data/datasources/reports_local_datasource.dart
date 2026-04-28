import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/report_type.dart';

class ReportsLocalDatasource {
  Future<void> saveReportTypes(List<ReportType> items) async {
    final box = await Hive.openBox<ReportType>("report_types");

    for (final item in items) {
      await box.put(item.reporteId, item);
    }

    await box.flush();
  }

  Future<List<ReportType>> getReportTypes() async {
    final box = await Hive.openBox<ReportType>("report_types");
    return box.values.toList();
  }

  Future<List<ReportType>> getActiveReportTypes() async {
    final box = await Hive.openBox<ReportType>("report_types");

    return box.values
        .where((e) => e.activo == true)
        .toList();
  }
}