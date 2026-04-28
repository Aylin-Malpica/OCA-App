import 'package:hive/hive.dart';

part 'risk_level.g.dart';

@HiveType(typeId: 5)
class RiskLevel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final int reporteTipoElementoId;

  @HiveField(2)
  final String descripcion;

  @HiveField(3)
  final bool activo;

  @HiveField(4)
  final String fechaActualizacion;

  RiskLevel({
    required this.id,
    required this.reporteTipoElementoId,
    required this.descripcion,
    required this.activo,
    required this.fechaActualizacion,
  });

  factory RiskLevel.fromJson(Map<String, dynamic> json) {
    return RiskLevel(
      id: json["id"] ?? 0,
      reporteTipoElementoId: json["reporteTipoElementoId"] ?? 0,
      descripcion: json["descripcion"] ?? "",
      activo: json["activo"] ?? false,
      fechaActualizacion: json["fechaActualizacion"] ?? "",
    );
  }
}