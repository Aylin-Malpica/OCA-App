// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_report.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalReportAdapter extends TypeAdapter<LocalReport> {
  @override
  final int typeId = 7;

  @override
  LocalReport read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalReport(
      reporteId: fields[0] as int,
      usuarioMovilId: fields[1] as int,
      nivelRiesgoId: fields[2] as int,
      tipoIncidenciaId: fields[3] as int,
      reporteTipoElementoId: fields[4] as int,
      correoResponsable: fields[5] as String,
      latitud: fields[6] as double,
      longitud: fields[7] as double,
      camposPersonalizados: (fields[8] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      fechaRegistro: fields[9] as String,
      status: fields[10] as String,
      reportTitle: fields[11] as String,
      reportElementDescription: fields[12] as String,
      elementTypeDescription: fields[13] as String,
      riskLevelDescription: fields[14] as String,
      incidentTypeDescription: fields[15] as String,
      elementoId: fields[16] as int,
      elementoIdentificador: fields[17] as String,
      elementoResumen: fields[18] as String,
      resultadoReporteId: fields[19] as int?,
      yaExistia: fields[20] as bool,
      evidenciasPaths: (fields[21] as List).cast<String>(),
      fechaActualizacion: fields[22] as String?,
      numeroEmpleado: fields[23] as String,
      ubicacionTecnicaId: fields[24] as int,
      ubicacionTecnicaDescripcion: fields[25] as String,
      seguimientoEstatus: fields[26] as String?,
      seguimientoCorreoResponsable: fields[27] as String?,
      seguimientoTipoResponsable: fields[28] as String?,
      seguimientoFechaActualizacion: fields[29] as String?,
      seguimientoComentarios: (fields[30] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      seguimientoEstatusId: fields[31] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, LocalReport obj) {
    writer
      ..writeByte(32)
      ..writeByte(0)
      ..write(obj.reporteId)
      ..writeByte(1)
      ..write(obj.usuarioMovilId)
      ..writeByte(2)
      ..write(obj.nivelRiesgoId)
      ..writeByte(3)
      ..write(obj.tipoIncidenciaId)
      ..writeByte(4)
      ..write(obj.reporteTipoElementoId)
      ..writeByte(5)
      ..write(obj.correoResponsable)
      ..writeByte(6)
      ..write(obj.latitud)
      ..writeByte(7)
      ..write(obj.longitud)
      ..writeByte(8)
      ..write(obj.camposPersonalizados)
      ..writeByte(9)
      ..write(obj.fechaRegistro)
      ..writeByte(10)
      ..write(obj.status)
      ..writeByte(11)
      ..write(obj.reportTitle)
      ..writeByte(12)
      ..write(obj.reportElementDescription)
      ..writeByte(13)
      ..write(obj.elementTypeDescription)
      ..writeByte(14)
      ..write(obj.riskLevelDescription)
      ..writeByte(15)
      ..write(obj.incidentTypeDescription)
      ..writeByte(16)
      ..write(obj.elementoId)
      ..writeByte(17)
      ..write(obj.elementoIdentificador)
      ..writeByte(18)
      ..write(obj.elementoResumen)
      ..writeByte(19)
      ..write(obj.resultadoReporteId)
      ..writeByte(20)
      ..write(obj.yaExistia)
      ..writeByte(21)
      ..write(obj.evidenciasPaths)
      ..writeByte(22)
      ..write(obj.fechaActualizacion)
      ..writeByte(23)
      ..write(obj.numeroEmpleado)
      ..writeByte(24)
      ..write(obj.ubicacionTecnicaId)
      ..writeByte(25)
      ..write(obj.ubicacionTecnicaDescripcion)
      ..writeByte(26)
      ..write(obj.seguimientoEstatus)
      ..writeByte(27)
      ..write(obj.seguimientoCorreoResponsable)
      ..writeByte(28)
      ..write(obj.seguimientoTipoResponsable)
      ..writeByte(29)
      ..write(obj.seguimientoFechaActualizacion)
      ..writeByte(30)
      ..write(obj.seguimientoComentarios)
      ..writeByte(31)
      ..write(obj.seguimientoEstatusId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalReportAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
