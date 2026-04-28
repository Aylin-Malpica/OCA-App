// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'risk_level.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RiskLevelAdapter extends TypeAdapter<RiskLevel> {
  @override
  final int typeId = 5;

  @override
  RiskLevel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RiskLevel(
      id: fields[0] as int,
      reporteTipoElementoId: fields[1] as int,
      descripcion: fields[2] as String,
      activo: fields[3] as bool,
      fechaActualizacion: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RiskLevel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.reporteTipoElementoId)
      ..writeByte(2)
      ..write(obj.descripcion)
      ..writeByte(3)
      ..write(obj.activo)
      ..writeByte(4)
      ..write(obj.fechaActualizacion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RiskLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
