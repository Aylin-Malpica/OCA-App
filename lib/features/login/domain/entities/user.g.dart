// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      usuarioId: fields[0] as int,
      nombreUsuario: fields[1] as String,
      nombreCompleto: fields[2] as String,
      correo: fields[3] as String,
      contrasenia: fields[4] as String,
      departamento: fields[5] as String,
      ubicacionTecnica: fields[6] as String,
      unidadNegocioId: fields[7] as int,
      activo: fields[8] as bool,
      numeroEmpleado: fields[9] as String,
      departamentoId: fields[11] as int,
      ubicacionTecnicaId: fields[12] as int,
      lastSync: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.usuarioId)
      ..writeByte(1)
      ..write(obj.nombreUsuario)
      ..writeByte(2)
      ..write(obj.nombreCompleto)
      ..writeByte(3)
      ..write(obj.correo)
      ..writeByte(4)
      ..write(obj.contrasenia)
      ..writeByte(5)
      ..write(obj.departamento)
      ..writeByte(6)
      ..write(obj.ubicacionTecnica)
      ..writeByte(7)
      ..write(obj.unidadNegocioId)
      ..writeByte(8)
      ..write(obj.activo)
      ..writeByte(9)
      ..write(obj.numeroEmpleado)
      ..writeByte(10)
      ..write(obj.lastSync)
      ..writeByte(11)
      ..write(obj.departamentoId)
      ..writeByte(12)
      ..write(obj.ubicacionTecnicaId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
