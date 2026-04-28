import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/risk_level.dart';

class RiskLevelsLocalDatasource {
  Future<void> saveRiskLevels(List<RiskLevel> items) async {
    final box = await Hive.openBox<RiskLevel>("risk_levels");

    for (final item in items) {
      await box.put(item.id, item);
    }
    await box.flush();
  }

  Future<List<RiskLevel>> getRiskLevels() async {
    final box = await Hive.openBox<RiskLevel>("risk_levels");
    return box.values.toList();
  }
}