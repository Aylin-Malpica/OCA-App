import 'package:hive/hive.dart';
part 'custom_catalog.g.dart';

@HiveType(typeId: 20)
class CustomCatalog {
  @HiveField(0)
  final int catalogoPersonalizadoId;
  @HiveField(1)
  final String descripcion;
  @HiveField(2)
  final bool activo;
  @HiveField(3)
  final List<CustomCatalogDetail> detalles;

  CustomCatalog({
    required this.catalogoPersonalizadoId,
    required this.descripcion,
    required this.activo,
    required this.detalles,
  });

  factory CustomCatalog.fromJson(Map<String, dynamic> json) {
    return CustomCatalog(
      catalogoPersonalizadoId: json['catalogoPersonalizadoId'] ?? 0,
      descripcion: json['descripcion'] ?? '',
      activo: json['activo'] ?? false,
      detalles: (json['detalles'] as List<dynamic>? ?? [])
          .map((e) => CustomCatalogDetail.fromJson(e))
          .toList(),
    );
  }
}

@HiveType(typeId: 21) // Asigna un typeId que no estés usando
class CustomCatalogDetail {
  @HiveField(0)
  final int catalogoPersonalizadoDetalleId;
  @HiveField(1)
  final String descripcion;
  @HiveField(2)
  final bool activo;

  CustomCatalogDetail({
    required this.catalogoPersonalizadoDetalleId,
    required this.descripcion,
    required this.activo,
  });

  factory CustomCatalogDetail.fromJson(Map<String, dynamic> json) {
    return CustomCatalogDetail(
      catalogoPersonalizadoDetalleId: json['catalogoPersonalizadoDetalleId'] ?? 0,
      descripcion: json['descripcion'] ?? '',
      activo: json['activo'] ?? false,
    );
  }
}