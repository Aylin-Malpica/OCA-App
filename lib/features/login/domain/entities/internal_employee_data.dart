class InternalEmployeeData {
  final String numeroEmpleado;
  final String nombre;
  final String correo;
  final String nombreSociedad;
  final int unidadNegocioId;
  final String unidadNegocio;
  final String fuente;

  InternalEmployeeData({
    required this.numeroEmpleado,
    required this.nombre,
    required this.correo,
    required this.nombreSociedad,
    required this.unidadNegocioId,
    required this.unidadNegocio,
    required this.fuente,
  });

  String get numeroEmpleadoFormateado {
    return numeroEmpleado.trim().padLeft(4, '0');
  }

  String get nombreLimpio => nombre.trim();

  String get correoLimpio => correo.trim();

  String get unidadNegocioLimpia => unidadNegocio.trim();

  factory InternalEmployeeData.fromJson(Map<String, dynamic> json) {
    return InternalEmployeeData(
      numeroEmpleado: json["numeroEmpleado"]?.toString() ?? "",
      nombre: json["nombre"]?.toString() ?? "",
      correo: json["correo"]?.toString() ?? "",
      nombreSociedad: json["nombreSociedad"]?.toString() ?? "",
      unidadNegocioId: json["unidadNegocioId"] ?? 0,
      unidadNegocio: json["unidadNegocio"]?.toString() ?? "",
      fuente: json["fuente"]?.toString() ?? "",
    );
  }
}