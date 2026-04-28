import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/report_element.dart';

class ReportElementsLocalDatasource {
  Future<void> saveReportElements(List<ReportElement> items) async {
    final box = await Hive.openBox<ReportElement>("report_elements");

    for (final item in items) {
      await box.put(item.reporteTipoElementoId, item);
    }

    await box.flush();
  }

  Future<List<ReportElement>> getReportElements() async {
    final box = await Hive.openBox<ReportElement>("report_elements");
    return box.values.toList();
  }
}