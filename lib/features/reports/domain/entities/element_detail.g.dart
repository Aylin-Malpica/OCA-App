// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'element_detail.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ElementoDetalleAdapter extends TypeAdapter<ElementoDetalle> {
  @override
  final int typeId = 9;

  @override
  ElementoDetalle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ElementoDetalle(
      elementoDetalleId: fields[0] as int,
      elementoId: fields[1] as int,
      valor: fields[2] as String,
      descripcion: fields[3] as String,
      activo: fields[4] as bool,
      fechaRegistro: fields[5] as String,
      fechaActualizacion: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ElementoDetalle obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.elementoDetalleId)
      ..writeByte(1)
      ..write(obj.elementoId)
      ..writeByte(2)
      ..write(obj.valor)
      ..writeByte(3)
      ..write(obj.descripcion)
      ..writeByte(4)
      ..write(obj.activo)
      ..writeByte(5)
      ..write(obj.fechaRegistro)
      ..writeByte(6)
      ..write(obj.fechaActualizacion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ElementoDetalleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
