import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/datasources/local_reports_local_datasource.dart';
import '../domain/entities/local_report.dart';
import '../domain/entities/report_type.dart';
import '../../login/domain/entities/user.dart';
import 'report_form_page.dart';

class SavedReportDetailPage extends StatefulWidget {
  final LocalReport report;
  final dynamic reportKey;
  final User user;

  const SavedReportDetailPage({
    super.key,
    required this.report,
    required this.reportKey,
    required this.user,
  });

  @override
  State<SavedReportDetailPage> createState() =>
      _SavedReportDetailPageState();
}

class _SavedReportDetailPageState
    extends State<SavedReportDetailPage> {
  final local = LocalReportsLocalDatasource();
  final ImagePicker _picker = ImagePicker();

  List<File> evidencias = [];

  bool saving = false;

  bool get isDraft => widget.report.status == "draft";
  bool get isSent => widget.report.status == "sent";

  @override
  void initState() {
    super.initState();

    evidencias = widget.report.evidenciasPaths
        .map((e) => File(e))
        .where((f) => f.existsSync())
        .toList();
  }

  ReportType buildReportType(LocalReport r) {
    return ReportType(
      reporteId: r.reporteId,
      titulo: r.reportTitle,
      tipoReporte: r.reportElementDescription,
      unidadNegocio: "",
      requiereEvidencia: false,
      activo: true,
      fechaRegistro: r.fechaRegistro,
      fechaActualizacion: r.fechaActualizacion ?? r.fechaRegistro,
    );
  }

  Future<void> takePhoto() async {
    if (!isDraft) return;

    if (evidencias.length >= 5) {
      showMsg("Máximo 5 fotos");
      return;
    }

    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    if (picked != null) {
      setState(() {
        evidencias.add(File(picked.path));
      });
    }
  }

  Future<void> deleteReport() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Eliminar"),
        content: const Text("¿Eliminar este borrador?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await local.deleteReport(widget.reportKey);

    if (!mounted) return;

    Navigator.pop(context);
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget card(String title, Widget child, {IconData? icon}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value.trim().isEmpty ? "-" : value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget imageItem(File file) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullImagePage(file: file),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              file,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (isDraft)
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  evidencias.remove(file);
                });
              },
              child: const CircleAvatar(
                radius: 12,
                backgroundColor: Colors.red,
                child: Icon(Icons.close,
                    size: 14, color: Colors.white),
              ),
            ),
          )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.report;

    return Scaffold(
      appBar: AppBar(
        title: Text(isDraft ? "Editar reporte" : "Detalles del reporte"),

      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// INFO GENERAL
          card(
            "Información general",
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                infoRow("Título del reporte", r.reportTitle),
                infoRow("Tipo de reporte", r.reportElementDescription),
                infoRow("Tipo de elemento", r.elementTypeDescription),
                infoRow("Elemento", r.elementoIdentificador),
                infoRow("Ubicación técnica", r.ubicacionTecnicaDescripcion),
              ],
            ),
            icon: Icons.description_outlined,
          ),

          const SizedBox(height: 14),

          if (isSent)
            card(
              "Datos de envío",
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  infoRow(
                    "Estado",
                    "Enviado",
                  ),
                  infoRow(
                    "Fecha",
                    formatDate(r.fechaRegistro),
                  ),

                  /// ID REPORTE
                  if (r.resultadoReporteId != null)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.confirmation_number,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "ID del reporte: ${r.resultadoReporteId}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              icon: Icons.send_outlined,
            ),


          /// CLASIFICACIÓN
          card(
            "Clasificación",
            Column(
              children: [
                infoRow("Nivel riesgo", r.riskLevelDescription),
                infoRow("Incidencia", r.incidentTypeDescription),
              ],
            ),
            icon: Icons.flag,
          ),

          const SizedBox(height: 14),

          /// CAMPOS
          card(
            "Campos personalizados",
            r.camposPersonalizados.isEmpty
                ? const Text("Sin datos")
                : Column(
              children: r.camposPersonalizados.map((c) {
                return infoRow(
                  c["descripcion"] ?? "Campo",
                  c["valor"] ?? "",
                );
              }).toList(),
            ),
            icon: Icons.list,
          ),

          const SizedBox(height: 14),

          /// EVIDENCIAS
          card(
            "Evidencias",
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ...evidencias.map(imageItem),
                if (isDraft && evidencias.length < 5)
                  GestureDetector(
                    onTap: takePhoto,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.camera_alt),
                    ),
                  ),
              ],
            ),
            icon: Icons.photo,
          ),

          const SizedBox(height: 20),

          /// BOTONES
          if (isDraft)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: deleteReport,
                    icon: const Icon(Icons.delete),
                    label: const Text("Eliminar"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReportFormPage(
                            user: widget.user,
                            report: buildReportType(widget.report),
                            editingReport: widget.report,
                            reportKey: widget.reportKey,
                          ),
                        ),
                      );

                      if (!mounted) return;

                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text("Editar"),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
  String formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);

      return "${date.day.toString().padLeft(2, '0')}/"
          "${date.month.toString().padLeft(2, '0')}/"
          "${date.year} "
          "${date.hour.toString().padLeft(2, '0')}:"
          "${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return isoDate;
    }
  }
}

class FullImagePage extends StatelessWidget {
  final File file;

  const FullImagePage({
    super.key,
    required this.file,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.black,
      body: Center(
        child: InteractiveViewer(
          child: Image.file(file),
        ),
      ),
    );
  }

}