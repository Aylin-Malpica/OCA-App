// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_element.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReportElementAdapter extends TypeAdapter<ReportElement> {
  @override
  final int typeId = 3;

  @override
  ReportElement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReportElement(
      reporteTipoElementoId: fields[0] as int,
      reporteId: fields[1] as int,
      tipoElementoId: fields[2] as int,
      reporteTipoElementoDescripcion: fields[3] as String,
      tipoElementoDescripcion: fields[4] as String,
      responsableId: fields[5] as int,
      responsableDescripcion: fields[6] as String,
      activo: fields[7] as bool,
      fechaActualizacion: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ReportElement obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.reporteTipoElementoId)
      ..writeByte(1)
      ..write(obj.reporteId)
      ..writeByte(2)
      ..write(obj.tipoElementoId)
      ..writeByte(3)
      ..write(obj.reporteTipoElementoDescripcion)
      ..writeByte(4)
      ..write(obj.tipoElementoDescripcion)
      ..writeByte(5)
      ..write(obj.responsableId)
      ..writeByte(6)
      ..write(obj.responsableDescripcion)
      ..writeByte(7)
      ..write(obj.activo)
      ..writeByte(8)
      ..write(obj.fechaActualizacion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportElementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
