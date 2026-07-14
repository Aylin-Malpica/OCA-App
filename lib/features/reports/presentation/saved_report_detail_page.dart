import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/app_theme.dart';
import '../data/datasources/local_reports_local_datasource.dart';
import '../domain/entities/local_report.dart';
import '../domain/entities/report_type.dart';
import '../../login/domain/entities/user.dart';
import 'report_form_page.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_info.dart';
import '../data/datasources/reports_remote_datasource.dart';

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

class _SavedReportDetailPageState extends State<SavedReportDetailPage> {
  final local = LocalReportsLocalDatasource();
  final reportsRemote = ReportsRemoteDatasource(ApiClient());
  final ImagePicker _picker = ImagePicker();

  late LocalReport currentReport;

  List<File> evidencias = [];

  bool saving = false;

  bool get isDraft => widget.report.status == "draft";
  bool get isSent => widget.report.status == "sent";

  @override
  void initState() {
    super.initState();

    currentReport = widget.report;

    evidencias = currentReport.evidenciasPaths
        .map((e) => File(e))
        .where((f) => f.existsSync())
        .toList();

    syncTrackingDetail();
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

  Future<void> syncTrackingDetail() async {
    if (currentReport.status != "sent") return;
    if (currentReport.resultadoReporteId == null) return;

    if (currentReport.seguimientoEstatusId == 3 ||
        currentReport.seguimientoEstatusId == 4) {
      return;
    }

    final hasInternet = await NetworkInfo().hasInternet();

    if (!hasInternet) return;

    // petición...
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

        title: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppTheme.azulOscuro,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.delete_outline,
                color: Colors.white,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Eliminar reporte",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.warning_amber_outlined,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "¿Eliminar este borrador?",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.marBaltico,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Esta acción no se puede deshacer.",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Cancelar",
              style: TextStyle(
                color: AppTheme.textColor,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.delete_outline),
            label: const Text("Eliminar"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
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

  Color getTrackingStatusColor(int? statusId) {
    switch (statusId) {
      case 1: // Abierto
        return Colors.blue;
      case 2: // En proceso
        return Colors.amber.shade700;
      case 3: // Cancelado
        return Colors.red;
      case 4: // Resuelto
        return Colors.green;
      default:
        return AppTheme.textColor;
    }
  }

  IconData getTrackingStatusIcon(int? statusId) {
    switch (statusId) {
      case 1:
        return Icons.lock_open_outlined;
      case 2:
        return Icons.pending_actions_outlined;
      case 3:
        return Icons.cancel_outlined;
      case 4:
        return Icons.check_circle_outline;
      default:
        return Icons.info_outline;
    }
  }

  Widget trackingStatusHeader(LocalReport report) {
    final estatus = report.seguimientoEstatus ?? "Sin estatus";

    final color = getTrackingStatusColor(
      report.seguimientoEstatusId,
    );

    final icon = getTrackingStatusIcon(
      report.seguimientoEstatusId,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.16),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Estatus actual",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  estatus,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget trackingSection(LocalReport r) {
    if (r.status != "sent") {
      return const SizedBox.shrink();
    }

    final comentarios = r.seguimientoComentarios;

    return card(
      "Seguimiento del reporte",
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          trackingStatusHeader(r),

          const SizedBox(height: 14),

          infoRow(
            "Responsable",
            r.seguimientoCorreoResponsable ?? "-",
          ),

          infoRow(
            "Tipo de responsable",
            r.seguimientoTipoResponsable ?? "-",
          ),

          const SizedBox(height: 8),

          const Row(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 19,
                color: AppTheme.dorado,
              ),
              SizedBox(width: 8),
              Text(
                "Comentarios",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.marBaltico,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (comentarios.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.dorado.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.dorado.withOpacity(0.20),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.forum_outlined,
                    size: 20,
                    color: AppTheme.textColor,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Sin comentarios registrados.",
                      style: TextStyle(
                        color: AppTheme.textColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: comentarios.map((c) {
                final activo = c["activo"] == true;

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: activo
                        ? AppTheme.dorado.withOpacity(0.05)
                        : Colors.grey.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: activo
                          ? AppTheme.dorado.withOpacity(0.25)
                          : Colors.grey.withOpacity(0.25),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppTheme.dorado.withOpacity(0.13),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.comment_outlined,
                          size: 18,
                          color: AppTheme.dorado,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              c["comentario"]?.toString() ?? "-",
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.marBaltico,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Row(
                              children: [
                                const Icon(
                                  Icons.schedule,
                                  size: 14,
                                  color: AppTheme.textColor,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  formatDate(
                                    c["fechaRegistro"]
                                        ?.toString() ??
                                        "",
                                  ),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
      icon: Icons.manage_search_outlined,
    );
  }

  Widget card(String title, Widget child, {IconData? icon}) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shadowColor: AppTheme.dorado.withOpacity(0.18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: AppTheme.dorado.withOpacity(0.30),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppTheme.dorado.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: AppTheme.dorado,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.marBaltico,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
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
          color: AppTheme.dorado.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.dorado.withOpacity(0.22),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value.trim().isEmpty ? "-" : value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppTheme.marBaltico,
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
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.dorado.withOpacity(0.35),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                file,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        if (isDraft)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  evidencias.remove(file);
                });
              },
              child: const CircleAvatar(
                radius: 12,
                backgroundColor: Colors.red,
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = currentReport;

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
                        color: AppTheme.dorado.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.dorado.withOpacity(0.35),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.confirmation_number,
                            color: AppTheme.dorado,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "ID del reporte: ${r.resultadoReporteId}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.dorado,
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
                        color: AppTheme.dorado.withOpacity(0.08),
                        border: Border.all(
                          color: AppTheme.dorado.withOpacity(0.45),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: AppTheme.dorado,
                        size: 30,
                      ),
                    ),
                  ),
              ],
            ),
            icon: Icons.photo,
          ),

          const SizedBox(height: 14),

          trackingSection(r),

          const SizedBox(height: 20),
          /// BOTONES
          if (isDraft)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: deleteReport,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text("Eliminar"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.dorado,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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
                    icon: const Icon(Icons.edit_outlined),
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
      appBar: AppBar(
        title: const Text("Evidencia"),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: InteractiveViewer(
          child: Image.file(file),
        ),
      ),
    );
  }
}