// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_field.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomFieldAdapter extends TypeAdapter<CustomField> {
  @override
  final int typeId = 4;

  @override
  CustomField read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomField(
      campoPersonalizadoId: fields[0] as int,
      reporteTipoElementoId: fields[1] as int,
      descripcion: fields[2] as String,
      tipoValorId: fields[3] as int,
      tipoValorDescripcion: fields[4] as String,
      obligatorio: fields[5] as bool,
      activo: fields[6] as bool,
      fechaActualizacion: fields[7] as String,
      catalogoPersonalizadoId: fields[8] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, CustomField obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.campoPersonalizadoId)
      ..writeByte(1)
      ..write(obj.reporteTipoElementoId)
      ..writeByte(2)
      ..write(obj.descripcion)
      ..writeByte(3)
      ..write(obj.tipoValorId)
      ..writeByte(4)
      ..write(obj.tipoValorDescripcion)
      ..writeByte(5)
      ..write(obj.obligatorio)
      ..writeByte(6)
      ..write(obj.activo)
      ..writeByte(7)
      ..write(obj.fechaActualizacion)
      ..writeByte(8)
      ..write(obj.catalogoPersonalizadoId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomFieldAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
