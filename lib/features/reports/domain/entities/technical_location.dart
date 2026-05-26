import 'package:hive/hive.dart';

part 'technical_location.g.dart';

@HiveType(typeId: 12)
class TechnicalLocation extends HiveObject {

  @HiveField(0)
  final int ubicacionTecnicaId;

  @HiveField(1)
  final String claveUbicacionTecnica;

  @HiveField(2)
  final String denominacion;

  @HiveField(3)
  final String idZona;

  @HiveField(4)
  final int unidadNegocioId;

  @HiveField(5)
  final String descripcionZona;

  TechnicalLocation({
    required this.ubicacionTecnicaId,
    required this.claveUbicacionTecnica,
    required this.denominacion,
    required this.idZona,
    required this.unidadNegocioId,
    required this.descripcionZona,
  });

  factory TechnicalLocation.fromJson(Map<String, dynamic> json) {
    return TechnicalLocation(
      ubicacionTecnicaId: json['ubicacionTecnicaId'] ?? 0,
      claveUbicacionTecnica: json['claveUbicacionTecnica'] ?? '',
      denominacion: json['denominacion'] ?? '',
      idZona: json['idZona'] ?? '',
      unidadNegocioId: json['unidadNegocioId'] ?? 0,
      descripcionZona: json['descripcionZona'] ?? '',
    );
  }
}