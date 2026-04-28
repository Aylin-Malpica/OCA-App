import 'package:hive/hive.dart';

part 'report_element.g.dart';

@HiveType(typeId: 3)
class ReportElement {
  @HiveField(0)
  final int reporteTipoElementoId;

  @HiveField(1)
  final int reporteId;

  @HiveField(2)
  final int tipoElementoId;

  @HiveField(3)
  final String reporteTipoElementoDescripcion;

  @HiveField(4)
  final String tipoElementoDescripcion;

  @HiveField(5)
  final int responsableId;

  @HiveField(6)
  final String responsableDescripcion;

  @HiveField(7)
  final bool activo;

  @HiveField(8)
  final String fechaActualizacion;

  ReportElement({
    required this.reporteTipoElementoId,
    required this.reporteId,
    required this.tipoElementoId,
    required this.reporteTipoElementoDescripcion,
    required this.tipoElementoDescripcion,
    required this.responsableId,
    required this.responsableDescripcion,
    required this.activo,
    required this.fechaActualizacion,
  });

  factory ReportElement.fromJson(Map<String, dynamic> json) {
    return ReportElement(
      reporteTipoElementoId: json["reporteTipoElementoId"] ?? 0,
      reporteId: json["reporteId"] ?? 0,
      tipoElementoId: json["tipoElementoId"] ?? 0,
      reporteTipoElementoDescripcion:
      json["reporteTipoElementoDescripcion"] ?? "",
      tipoElementoDescripcion: json["tipoElementoDescripcion"] ?? "",
      responsableId: json["responsableId"] ?? 0,
      responsableDescripcion: json["responsableDescripcion"] ?? "",
      activo: json["activo"] ?? false,
      fechaActualizacion: json["fechaActualizacion"] ?? "",
    );
  }
}