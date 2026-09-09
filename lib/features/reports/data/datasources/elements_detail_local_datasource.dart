import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/element_detail.dart';

class ElementDetailsLocalDatasource {
  Future<void> saveElementDetails(List<ElementoDetalle> items) async {
    final box = await Hive.openBox<ElementoDetalle>("element_details");

    final detailsMap = {
      for (final item in items) item.elementoDetalleId: item,
    };

    await box.putAll(detailsMap);
  }

  Future<List<ElementoDetalle>> getElementDetails() async {
    final box = await Hive.openBox<ElementoDetalle>("element_details");
    return box.values.toList();
  }
}