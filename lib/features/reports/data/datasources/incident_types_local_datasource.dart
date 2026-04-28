import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/incident_type.dart';

class IncidentTypesLocalDatasource {
  Future<void> saveIncidentTypes(List<IncidentType> items) async {
    final box = await Hive.openBox<IncidentType>("incident_types");

    for (final item in items) {
      await box.put(item.id, item);
    }
    await box.flush();
  }

  Future<List<IncidentType>> getIncidentTypes() async {
    final box = await Hive.openBox<IncidentType>("incident_types");
    return box.values.toList();
  }
}