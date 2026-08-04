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

  @HiveField(24)
  final int ubicacionTecnicaId;

  @HiveField(25)
  final String ubicacionTecnicaDescripcion;

  @HiveField(26)
  final String? seguimientoEstatus;

  @HiveField(27)
  final String? seguimientoCorreoResponsable;

  @HiveField(28)
  final String? seguimientoTipoResponsable;

  @HiveField(29)
  final String? seguimientoFechaActualizacion;

  @HiveField(30)
  final List<Map<String, dynamic>> seguimientoComentarios;

  @HiveField(31)
  final int? seguimientoEstatusId;

  @HiveField(32)
  final List<String> evidenciasUrls;

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
    required this.ubicacionTecnicaId,
    required this.ubicacionTecnicaDescripcion,
    this.seguimientoEstatus,
    this.seguimientoCorreoResponsable,
    this.seguimientoTipoResponsable,
    this.seguimientoFechaActualizacion,
    this.seguimientoComentarios = const [],
    this.seguimientoEstatusId,
    this.evidenciasUrls = const [],
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
      "ubicacionTecnicaId":ubicacionTecnicaId,
      "ubicacionTecnicaDescripcion": ubicacionTecnicaDescripcion,
      "seguimientoEstatus": seguimientoEstatus,
      "seguimientoCorreoResponsable": seguimientoCorreoResponsable,
      "seguimientoTipoResponsable": seguimientoTipoResponsable,
      "seguimientoFechaActualizacion": seguimientoFechaActualizacion,
      "seguimientoComentarios": seguimientoComentarios,
      "seguimientoEstatusId": seguimientoEstatusId,
      "evidenciasUrls": evidenciasUrls,
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
    int ? ubicacionTecnicaId,
    String ? ubicacionTecnicaDescripcion,
    String? seguimientoEstatus,
    String? seguimientoCorreoResponsable,
    String? seguimientoTipoResponsable,
    String? seguimientoFechaActualizacion,
    List<Map<String, dynamic>>? seguimientoComentarios,
    int? seguimientoEstatusId,
    List<String>? evidenciasUrls,
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
      ubicacionTecnicaId: ubicacionTecnicaId ?? this.ubicacionTecnicaId,
      ubicacionTecnicaDescripcion: ubicacionTecnicaDescripcion ?? this.ubicacionTecnicaDescripcion,
      seguimientoEstatus: seguimientoEstatus ?? this.seguimientoEstatus,
      seguimientoCorreoResponsable: seguimientoCorreoResponsable ?? this.seguimientoCorreoResponsable,
      seguimientoTipoResponsable: seguimientoTipoResponsable ?? this.seguimientoTipoResponsable,
      seguimientoFechaActualizacion: seguimientoFechaActualizacion ?? this.seguimientoFechaActualizacion,
      seguimientoComentarios: seguimientoComentarios ?? this.seguimientoComentarios,
      seguimientoEstatusId: seguimientoEstatusId ?? this.seguimientoEstatusId,
      evidenciasUrls: evidenciasUrls ?? this.evidenciasUrls,
    );
  }
  factory LocalReport.fromRemoteJson(
      Map<String, dynamic> json, {
        required String numeroEmpleado,
      }) {
    final camposPersonalizados =
    (json["camposPersonalizados"] as List? ?? [])
        .map<Map<String, dynamic>>((item) {
      final campo = Map<String, dynamic>.from(item as Map);

      return {
        "descripcion": campo["campo"]?.toString() ?? "Campo",
        "campo": campo["campo"]?.toString() ?? "Campo",
        "valor": campo["valor"]?.toString() ?? "",
      };
    }).toList();

    final seguimientos =
    (json["seguimientos"] as List? ?? [])
        .map<Map<String, dynamic>>((item) {
      final seguimiento =
      Map<String, dynamic>.from(item as Map);

      return {
        "resultadoReporteSeguimientoId":
        seguimiento["resultadoReporteSeguimientoId"],
        "comentario":
        seguimiento["descripcionActividad"]?.toString() ??
            seguimiento["comentario"]?.toString() ??
            "",
        "fechaRegistro":
        seguimiento["fechaRegistro"]?.toString() ?? "",
        "activo": seguimiento["activo"] == true,
      };
    }).toList();

    final evidenciasUrls =
    (json["evidencias"] as List? ?? [])
        .map<String>((item) {
      final evidencia =
      Map<String, dynamic>.from(item as Map);

      return evidencia["url"]?.toString() ?? "";
    })
        .where((url) => url.trim().isNotEmpty)
        .toList();

    return LocalReport(
      reporteId: _toInt(json["reporteId"]),
      usuarioMovilId: _toInt(json["usuarioMovilId"]),
      nivelRiesgoId: _toInt(json["nivelRiesgoId"]),
      tipoIncidenciaId: _toInt(json["tipoIncidenciaId"]),
      reporteTipoElementoId:
      _toInt(json["reporteTipoElementoId"]),
      correoResponsable:
      json["correoResponsable"]?.toString() ?? "",
      latitud: _toDouble(json["latitud"]),
      longitud: _toDouble(json["longitud"]),
      camposPersonalizados: camposPersonalizados,
      fechaRegistro:
      json["fechaRegistro"]?.toString() ??
          DateTime.now().toIso8601String(),
      status: "sent",
      reportTitle:
      json["tituloReporte"]?.toString() ??
          "Reporte sin título",
      reportElementDescription:
      json["reporteTipoElemento"]?.toString() ?? "",
      elementTypeDescription:
      json["tipoElemento"]?.toString() ??
          json["elementoTipo"]?.toString() ??
          "",
      riskLevelDescription:
      json["nivelRiesgo"]?.toString() ?? "",
      incidentTypeDescription:
      json["tipoIncidencia"]?.toString() ?? "",
      elementoId: _toInt(json["elementoId"]),
      elementoIdentificador:
      json["elemento"]?.toString() ?? "",
      elementoResumen:
      json["descripcionReporte"]?.toString() ?? "",
      resultadoReporteId:
      _toNullableInt(json["resultadoReporteId"]),
      yaExistia: true,
      evidenciasPaths: const [],
      fechaActualizacion:
      DateTime.now().toIso8601String(),
      numeroEmpleado: numeroEmpleado,
      ubicacionTecnicaId:
      _toInt(json["ubicacionTecnicaId"]),
      ubicacionTecnicaDescripcion:
      json["ubicacionTecnicaZona"]?.toString() ?? "",
      seguimientoEstatus:
      json["estatus"]?.toString(),
      seguimientoCorreoResponsable:
      json["correoResponsable"]?.toString(),
      seguimientoTipoResponsable:
      json["tipoResponsable"]?.toString(),
      seguimientoFechaActualizacion:
      DateTime.now().toIso8601String(),
      seguimientoComentarios: seguimientos,
      seguimientoEstatusId:
      _toNullableInt(
        json["resultadoReporteEstatusId"],
      ),
      evidenciasUrls: evidenciasUrls,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;

    return int.tryParse(value?.toString() ?? "") ?? 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;

    return int.tryParse(value.toString());
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();

    return double.tryParse(value?.toString() ?? "") ?? 0.0;
  }
}