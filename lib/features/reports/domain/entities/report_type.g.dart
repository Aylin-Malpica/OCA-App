// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReportTypeAdapter extends TypeAdapter<ReportType> {
  @override
  final int typeId = 1;

  @override
  ReportType read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReportType(
      reporteId: fields[0] as int,
      titulo: fields[1] as String,
      tipoReporte: fields[2] as String,
      unidadNegocio: fields[3] as String,
      requiereEvidencia: fields[4] as bool,
      activo: fields[5] as bool,
      fechaRegistro: fields[6] as String,
      fechaActualizacion: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ReportType obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.reporteId)
      ..writeByte(1)
      ..write(obj.titulo)
      ..writeByte(2)
      ..write(obj.tipoReporte)
      ..writeByte(3)
      ..write(obj.unidadNegocio)
      ..writeByte(4)
      ..write(obj.requiereEvidencia)
      ..writeByte(5)
      ..write(obj.activo)
      ..writeByte(6)
      ..write(obj.fechaRegistro)
      ..writeByte(7)
      ..write(obj.fechaActualizacion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
