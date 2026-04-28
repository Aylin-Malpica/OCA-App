import 'package:hive/hive.dart';

part 'report_type.g.dart';

@HiveType(typeId: 1)

class ReportType {
  @HiveField(0)
  final int reporteId;

  @HiveField(1)
  final String titulo;

  @HiveField(2)
  final String tipoReporte;

  @HiveField(3)
  final String unidadNegocio;

  @HiveField(4)
  final bool requiereEvidencia;

  @HiveField(5)
  final bool activo;

  @HiveField(6)
  final String fechaRegistro;

  @HiveField(7)
  final String fechaActualizacion;

  ReportType({
    required this.reporteId,
    required this.titulo,
    required this.tipoReporte,
    required this.unidadNegocio,
    required this.requiereEvidencia,
    required this.activo,
    required this.fechaRegistro,
    required this.fechaActualizacion,
  });

  factory ReportType.fromJson(Map<String, dynamic> json) {
    return ReportType(
      reporteId: json["reporteId"] ?? 0,
      titulo: json["titulo"] ?? "",
      tipoReporte: json["tipoReporte"] ?? "",
      unidadNegocio: json["unidadNegocio"] ?? "",
      requiereEvidencia: json["requiereEvidencia"] ?? false,
      activo: json["activo"] ?? false,
      fechaRegistro: json["fechaRegistro"] ?? "",
      fechaActualizacion: json["fechaActualizacion"] ?? "",
    );
  }
}