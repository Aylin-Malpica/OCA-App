// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_catalog.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomCatalogAdapter extends TypeAdapter<CustomCatalog> {
  @override
  final int typeId = 20;

  @override
  CustomCatalog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomCatalog(
      catalogoPersonalizadoId: fields[0] as int,
      descripcion: fields[1] as String,
      activo: fields[2] as bool,
      detalles: (fields[3] as List).cast<CustomCatalogDetail>(),
    );
  }

  @override
  void write(BinaryWriter writer, CustomCatalog obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.catalogoPersonalizadoId)
      ..writeByte(1)
      ..write(obj.descripcion)
      ..writeByte(2)
      ..write(obj.activo)
      ..writeByte(3)
      ..write(obj.detalles);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomCatalogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CustomCatalogDetailAdapter extends TypeAdapter<CustomCatalogDetail> {
  @override
  final int typeId = 21;

  @override
  CustomCatalogDetail read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomCatalogDetail(
      catalogoPersonalizadoDetalleId: fields[0] as int,
      descripcion: fields[1] as String,
      activo: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CustomCatalogDetail obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.catalogoPersonalizadoDetalleId)
      ..writeByte(1)
      ..write(obj.descripcion)
      ..writeByte(2)
      ..write(obj.activo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomCatalogDetailAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
