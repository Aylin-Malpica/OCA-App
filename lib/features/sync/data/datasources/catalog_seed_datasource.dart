import 'dart:convert';
import 'package:flutter/services.dart';

import '../../../reports/domain/entities/element.dart';
import '../../../reports/domain/entities/element_detail.dart';

class CatalogSeedDatasource {
  Future<List<Elemento>> loadElements() async {
    final jsonString = await rootBundle.loadString(
      'assets/catalogs/elements.json',
    );

    final List<dynamic> data = jsonDecode(jsonString);

    return data
        .map((e) => Elemento.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<ElementoDetalle>> loadElementDetailsFile(
      String assetPath,
      ) async {
    final jsonString = await rootBundle.loadString(assetPath);

    final List<dynamic> data = jsonDecode(jsonString);

    return data
        .map(
          (e) => ElementoDetalle.fromJson(
        Map<String, dynamic>.from(e),
      ),
    )
        .toList();
  }
}