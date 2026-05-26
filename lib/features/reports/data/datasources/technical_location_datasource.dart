import 'package:hive/hive.dart';

import '../../domain/entities/technical_location.dart';

class TechnicalLocationsLocalDatasource {
  final box = Hive.box<TechnicalLocation>("technical_locations");

  Future<void> saveTechnicalLocations(List<TechnicalLocation> items) async {
    for (final item in items) {
      await box.put(item.ubicacionTecnicaId, item);
    }
  }

  Future<List<TechnicalLocation>> getTechnicalLocations() async {
    return box.values.toList();
  }
}