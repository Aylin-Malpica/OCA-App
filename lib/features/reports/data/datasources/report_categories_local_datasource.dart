import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/report_category.dart';

class ReportCategoriesLocalDatasource {
  Future<void> saveReportCategories(List<ReportCategory> items) async {
    final box = await Hive.openBox<ReportCategory>("report_categories");

    for (final item in items) {
      await box.put(item.id, item);
    }

    await box.flush();
  }

  Future<List<ReportCategory>> getReportCategories() async {
    final box = await Hive.openBox<ReportCategory>("report_categories");
    return box.values.toList();
  }
}