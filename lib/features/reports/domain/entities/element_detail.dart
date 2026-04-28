import 'package:hive/hive.dart';

part 'element_detail.g.dart';

@HiveType(typeId: 9)
class ElementoDetalle {
  @HiveField(0)
  final int elementoDetalleId;

  @HiveField(1)
  final int elementoId;

  @HiveField(2)
  final String valor;

  @HiveField(3)
  final String descripcion;

  @HiveField(4)
  final bool activo;

  @HiveField(5)
  final String fechaRegistro;

  @HiveField(6)
  final String fechaActualizacion;

  ElementoDetalle({
    required this.elementoDetalleId,
    required this.elementoId,
    required this.valor,
    required this.descripcion,
    required this.activo,
    required this.fechaRegistro,
    required this.fechaActualizacion,
  });

  factory ElementoDetalle.fromJson(Map<String, dynamic> json) {
    return ElementoDetalle(
      elementoDetalleId: json["elementoDetalleId"] ?? 0,
      elementoId: json["elementoId"] ?? 0,
      valor: json["valor"] ?? "",
      descripcion: json["descripcion"] ?? "",
      activo: json["activo"] ?? false,
      fechaRegistro: json["fechaRegistro"] ?? "",
      fechaActualizacion: json["fechaActualizacion"] ?? "",
    );
  }
}