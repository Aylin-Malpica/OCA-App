import 'package:hive/hive.dart';
import '../../../reports/domain/entities/custom_catalog.dart';

class CustomCatalogsLocalDatasource {
  static const String boxName = 'custom_catalogs_box';

  Future<void> saveCustomCatalogs(List<CustomCatalog> catalogs) async {
    final box = await Hive.openBox<CustomCatalog>(boxName);

    // Opcional: Limpiar catálogos anteriores si es sincronización completa
    // await box.clear();

    final Map<int, CustomCatalog> catalogsMap = {
      for (var catalog in catalogs) catalog.catalogoPersonalizadoId: catalog
    };

    await box.putAll(catalogsMap);
  }

  Future<List<CustomCatalog>> getCustomCatalogs() async {
    final box = await Hive.openBox<CustomCatalog>(boxName);
    return box.values.toList();
  }
}