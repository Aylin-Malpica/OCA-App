class ReportEvidence {
  final String nombreArchivo;
  final String url;

  const ReportEvidence({
    required this.nombreArchivo,
    required this.url,
  });

  factory ReportEvidence.fromJson(Map<String, dynamic> json) {
    return ReportEvidence(
      nombreArchivo: json["nombreArchivo"]?.toString() ?? "",
      url: json["url"]?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "nombreArchivo": nombreArchivo,
      "url": url,
    };
  }
}