// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReportCategoryAdapter extends TypeAdapter<ReportCategory> {
  @override
  final int typeId = 2;

  @override
  ReportCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReportCategory(
      id: fields[0] as int,
      descripcion: fields[1] as String,
      requiereEvidencia: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ReportCategory obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.descripcion)
      ..writeByte(2)
      ..write(obj.requiereEvidencia);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
