import 'package:hive/hive.dart';

part 'custom_field.g.dart';

@HiveType(typeId: 4)
class CustomField {
  @HiveField(0)
  final int campoPersonalizadoId;

  @HiveField(1)
  final int reporteTipoElementoId;

  @HiveField(2)
  final String descripcion;

  @HiveField(3)
  final int tipoValorId;

  @HiveField(4)
  final String tipoValorDescripcion;

  @HiveField(5)
  final bool obligatorio;

  @HiveField(6)
  final bool activo;

  @HiveField(7)
  final String fechaActualizacion;

  CustomField({
    required this.campoPersonalizadoId,
    required this.reporteTipoElementoId,
    required this.descripcion,
    required this.tipoValorId,
    required this.tipoValorDescripcion,
    required this.obligatorio,
    required this.activo,
    required this.fechaActualizacion,
  });

  factory CustomField.fromJson(Map<String, dynamic> json) {
    return CustomField(
      campoPersonalizadoId: json["campoPersonalizadoId"] ?? 0,
      reporteTipoElementoId: json["reporteTipoElementoId"] ?? 0,
      descripcion: json["descripcion"] ?? "",
      tipoValorId: json["tipoValorId"] ?? 0,
      tipoValorDescripcion: json["tipoValorDescripcion"] ?? "",
      obligatorio: json["obligatorio"] ?? false,
      activo: json["activo"] ?? false,
      fechaActualizacion: json["fechaActualizacion"] ?? "",
    );
  }
}