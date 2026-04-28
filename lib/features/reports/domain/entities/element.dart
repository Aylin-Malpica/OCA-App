import 'package:hive/hive.dart';

part 'element.g.dart';

@HiveType(typeId: 8)
class Elemento {
  @HiveField(0)
  final int elementoId;

  @HiveField(1)
  final int tipoElementoId;

  @HiveField(2)
  final String identificador;

  @HiveField(3)
  final bool activo;

  @HiveField(4)
  final String fechaRegistro;

  @HiveField(5)
  final String fechaActualizacion;

  Elemento({
    required this.elementoId,
    required this.tipoElementoId,
    required this.identificador,
    required this.activo,
    required this.fechaRegistro,
    required this.fechaActualizacion,
  });

  factory Elemento.fromJson(Map<String, dynamic> json) {
    return Elemento(
      elementoId: json["elementoId"] ?? 0,
      tipoElementoId: json["tipoElementoId"] ?? 0,
      identificador: json["identificador"] ?? "",
      activo: json["activo"] ?? false,
      fechaRegistro: json["fechaRegistro"] ?? "",
      fechaActualizacion: json["fechaActualizacion"] ?? "",
    );
  }
}