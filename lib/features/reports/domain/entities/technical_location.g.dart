// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'technical_location.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TechnicalLocationAdapter extends TypeAdapter<TechnicalLocation> {
  @override
  final int typeId = 12;

  @override
  TechnicalLocation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TechnicalLocation(
      ubicacionTecnicaId: fields[0] as int,
      claveUbicacionTecnica: fields[1] as String,
      denominacion: fields[2] as String,
      idZona: fields[3] as String,
      unidadNegocioId: fields[4] as int,
      descripcionZona: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TechnicalLocation obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.ubicacionTecnicaId)
      ..writeByte(1)
      ..write(obj.claveUbicacionTecnica)
      ..writeByte(2)
      ..write(obj.denominacion)
      ..writeByte(3)
      ..write(obj.idZona)
      ..writeByte(4)
      ..write(obj.unidadNegocioId)
      ..writeByte(5)
      ..write(obj.descripcionZona);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TechnicalLocationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
