import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/element.dart';

class ElementsLocalDatasource {
  Future<void> saveElements(List<Elemento> items) async {
    final box = await Hive.openBox<Elemento>("elements");

    for (final item in items) {
      await box.put(item.elementoId, item);
    }

    await box.flush();
  }

  Future<List<Elemento>> getElements() async {
    final box = await Hive.openBox<Elemento>("elements");
    return box.values.toList();
  }

  Future<List<Elemento>> getElementsByTipoElementoId(int tipoElementoId) async {
    final box = await Hive.openBox<Elemento>("elements");

    return box.values
        .where((e) => e.tipoElementoId == tipoElementoId && e.activo)
        .toList();
  }
}