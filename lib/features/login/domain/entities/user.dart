import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  final int usuarioId;

  @HiveField(1)
  final String nombreUsuario;

  @HiveField(2)
  final String nombreCompleto;

  @HiveField(3)
  final String correo;

  @HiveField(4)
  final String contrasenia;

  @HiveField(5)
  final String departamento;

  @HiveField(6)
  final String localidad;

  @HiveField(7)
  final int unidadNegocioId;

  @HiveField(8)
  final bool activo;

  @HiveField(9)
  final String numeroEmpleado;

  User({
    required this.usuarioId,
    required this.nombreUsuario,
    required this.nombreCompleto,
    required this.correo,
    required this.contrasenia,
    required this.departamento,
    required this.localidad,
    required this.unidadNegocioId,
    required this.activo,
    required this.numeroEmpleado,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      usuarioId: json["usuarioId"] ?? 0,
      nombreUsuario: json["nombreUsuario"] ?? "",
      nombreCompleto: json["nombreCompleto"] ?? "",
      correo: json["correo"] ?? "",
      contrasenia: json["contrasenia"] ?? "",
      departamento: json["departamento"] ?? "",
      localidad: json["localidad"] ?? "",
      unidadNegocioId: json["unidadNegocioId"] ?? 0,
      activo: json["activo"] ?? true,
      numeroEmpleado: (json["nombreUsuario"] ?? "").toString(),
    );
  }
}