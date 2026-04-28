import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/custom_field.dart';

class CustomFieldsLocalDatasource {
  Future<void> saveCustomFields(List<CustomField> items) async {
    final box = await Hive.openBox<CustomField>("custom_fields");


    for (final item in items) {
      await box.put(item.campoPersonalizadoId, item);
    }

    await box.flush();
  }

  Future<List<CustomField>> getCustomFields() async {
    final box = await Hive.openBox<CustomField>("custom_fields");
    return box.values.toList();
  }
}