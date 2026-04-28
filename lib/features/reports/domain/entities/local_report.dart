import 'package:hive/hive.dart';

part 'local_report.g.dart';

@HiveType(typeId: 7)
class LocalReport {
  @HiveField(0)
  final int reporteId;

  @HiveField(1)
  final int usuarioMovilId;

  @HiveField(2)
  final int nivelRiesgoId;

  @HiveField(3)
  final int tipoIncidenciaId;

  @HiveField(4)
  final int reporteTipoElementoId;

  @HiveField(5)
  final String correoResponsable;

  @HiveField(6)
  final double latitud;

  @HiveField(7)
  final double longitud;

  @HiveField(8)
  final List<Map<String, dynamic>> camposPersonalizados;

  @HiveField(9)
  final String fechaRegistro;

  @HiveField(10)
  final String status; // draft / sent

  @HiveField(11)
  final String reportTitle;

  @HiveField(12)
  final String reportElementDescription;

  @HiveField(13)
  final String elementTypeDescription;

  @HiveField(14)
  final String riskLevelDescription;

  @HiveField(15)
  final String incidentTypeDescription;

  @HiveField(16)
  final int elementoId;

  @HiveField(17)
  final String elementoIdentificador;

  @HiveField(18)
  final String elementoResumen;

  @HiveField(19)
  final int? resultadoReporteId;

  @HiveField(20)
  final bool yaExistia;

  @HiveField(21)
  final List<String> evidenciasPaths;

  @HiveField(22)
  final String? fechaActualizacion;

  @HiveField(23)
  final String numeroEmpleado;

  LocalReport({
    required this.reporteId,
    required this.usuarioMovilId,
    required this.nivelRiesgoId,
    required this.tipoIncidenciaId,
    required this.reporteTipoElementoId,
    required this.correoResponsable,
    required this.latitud,
    required this.longitud,
    required this.camposPersonalizados,
    required this.fechaRegistro,
    required this.status,
    required this.reportTitle,
    required this.reportElementDescription,
    required this.elementTypeDescription,
    required this.riskLevelDescription,
    required this.incidentTypeDescription,
    required this.elementoId,
    required this.elementoIdentificador,
    required this.elementoResumen,
    required this.resultadoReporteId,
    required this.yaExistia,
    required this.evidenciasPaths,
    this.fechaActualizacion,
    required this.numeroEmpleado,
  });

  Map<String, dynamic> toJson() {
    return {
      "reporteId": reporteId,
      "usuarioMovilId": usuarioMovilId,
      "nivelRiesgoId": nivelRiesgoId,
      "tipoIncidenciaId": tipoIncidenciaId,
      "reporteTipoElementoId": reporteTipoElementoId,
      "correoResponsable": correoResponsable,
      "latitud": latitud,
      "longitud": longitud,
      "camposPersonalizados": camposPersonalizados,
      "fechaRegistro": fechaRegistro,
      "status": status,
      "reportTitle": reportTitle,
      "reportElementDescription": reportElementDescription,
      "elementTypeDescription": elementTypeDescription,
      "riskLevelDescription": riskLevelDescription,
      "incidentTypeDescription": incidentTypeDescription,
      "elementoId": elementoId,
      "elementoIdentificador": elementoIdentificador,
      "elementoResumen": elementoResumen,
      "resultadoReporteId": resultadoReporteId,
      "yaExistia": yaExistia,
      "evidenciasPaths": evidenciasPaths,
      "fechaActualizacion": fechaActualizacion,
      "numeroEmpleado": numeroEmpleado,
    };
  }

  LocalReport copyWith({
    int? reporteId,
    int? usuarioMovilId,
    int? nivelRiesgoId,
    int? tipoIncidenciaId,
    int? reporteTipoElementoId,
    String? correoResponsable,
    double? latitud,
    double? longitud,
    List<Map<String, dynamic>>? camposPersonalizados,
    String? fechaRegistro,
    String? status,
    String? reportTitle,
    String? reportElementDescription,
    String? elementTypeDescription,
    String? riskLevelDescription,
    String? incidentTypeDescription,
    int? elementoId,
    String? elementoIdentificador,
    String? elementoResumen,
    int? resultadoReporteId,
    bool? yaExistia,
    List<String>? evidenciasPaths,
    String? fechaActualizacion,
    String? numeroEmpleado,
  }) {
    return LocalReport(
      reporteId: reporteId ?? this.reporteId,
      usuarioMovilId: usuarioMovilId ?? this.usuarioMovilId,
      nivelRiesgoId: nivelRiesgoId ?? this.nivelRiesgoId,
      tipoIncidenciaId: tipoIncidenciaId ?? this.tipoIncidenciaId,
      reporteTipoElementoId:
      reporteTipoElementoId ?? this.reporteTipoElementoId,
      correoResponsable: correoResponsable ?? this.correoResponsable,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      camposPersonalizados:
      camposPersonalizados ?? this.camposPersonalizados,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      status: status ?? this.status,
      reportTitle: reportTitle ?? this.reportTitle,
      reportElementDescription:
      reportElementDescription ?? this.reportElementDescription,
      elementTypeDescription:
      elementTypeDescription ?? this.elementTypeDescription,
      riskLevelDescription:
      riskLevelDescription ?? this.riskLevelDescription,
      incidentTypeDescription:
      incidentTypeDescription ?? this.incidentTypeDescription,
      elementoId: elementoId ?? this.elementoId,
      elementoIdentificador:
      elementoIdentificador ?? this.elementoIdentificador,
      elementoResumen: elementoResumen ?? this.elementoResumen,
      resultadoReporteId: resultadoReporteId ?? this.resultadoReporteId,
      yaExistia: yaExistia ?? this.yaExistia,
      evidenciasPaths: evidenciasPaths ?? this.evidenciasPaths,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      numeroEmpleado: numeroEmpleado ?? this.numeroEmpleado,
    );
  }
}