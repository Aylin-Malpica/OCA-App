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
  final String ubicacionTecnica;

  @HiveField(7)
  final int unidadNegocioId;

  @HiveField(8)
  final bool activo;

  @HiveField(9)
  final String numeroEmpleado;

  @HiveField(10)
  DateTime? lastSync;

  @HiveField(11)
  final int departamentoId;

  @HiveField(12)
  final int ubicacionTecnicaId;

  @HiveField(13)
  final bool accesoPendiente;

  User({
    required this.usuarioId,
    required this.nombreUsuario,
    required this.nombreCompleto,
    required this.correo,
    required this.contrasenia,
    required this.departamento,
    required this.ubicacionTecnica,
    required this.unidadNegocioId,
    required this.activo,
    required this.numeroEmpleado,
    required this.departamentoId,
    required this.ubicacionTecnicaId,
    this.lastSync,
    required this.accesoPendiente,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final data = json["userData"] is Map<String, dynamic>
        ? json["userData"] as Map<String, dynamic>
        : json;

    return User(
      usuarioId: data["usuarioId"] ?? 0,
      nombreUsuario: data["nombreUsuario"]?.toString().trim() ?? "",
      nombreCompleto: data["nombreCompleto"]?.toString().trim() ?? "",
      correo: data["correo"]?.toString().trim() ?? "",
      contrasenia: data["contrasenia"]?.toString() ?? "",
      departamento: data["departamento"]?.toString().trim() ?? "",
      ubicacionTecnica: data["ubicacionTecnica"]?.toString().trim() ?? "",
      unidadNegocioId: data["unidadNegocioId"] ?? 0,
      activo: data["activo"] ?? true,
      numeroEmpleado: data["nombreUsuario"]?.toString().trim() ?? "",
      departamentoId: data["departamentoId"] ?? 0,
      ubicacionTecnicaId: data["ubicacionTecnicaId"] ?? 0,
      accesoPendiente: data["accesoPendiente"] ?? false,
    );
  }
}