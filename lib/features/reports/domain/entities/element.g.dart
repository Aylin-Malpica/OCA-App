// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'element.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ElementoAdapter extends TypeAdapter<Elemento> {
  @override
  final int typeId = 8;

  @override
  Elemento read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Elemento(
      elementoId: fields[0] as int,
      tipoElementoId: fields[1] as int,
      identificador: fields[2] as String,
      activo: fields[3] as bool,
      fechaRegistro: fields[4] as String,
      fechaActualizacion: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Elemento obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.elementoId)
      ..writeByte(1)
      ..write(obj.tipoElementoId)
      ..writeByte(2)
      ..write(obj.identificador)
      ..writeByte(3)
      ..write(obj.activo)
      ..writeByte(4)
      ..write(obj.fechaRegistro)
      ..writeByte(5)
      ..write(obj.fechaActualizacion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ElementoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
