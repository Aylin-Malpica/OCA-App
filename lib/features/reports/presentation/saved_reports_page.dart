import 'dart:convert';
import 'dart:io';

import 'package:app_oca/features/reports/presentation/report_form_page.dart';
import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_info.dart';
import '../../login/domain/entities/user.dart';
import '../data/datasources/local_reports_local_datasource.dart';
import '../data/datasources/reports_remote_datasource.dart';
import '../domain/entities/local_report.dart';
import '../domain/entities/report_type.dart';
import 'saved_report_detail_page.dart';
import '../../../../core/app_theme.dart';
class SavedReportsPage extends StatefulWidget {
  final User user;
  const SavedReportsPage({
    super.key,
    required this.user,
  });

  @override
  State<SavedReportsPage> createState() => _SavedReportsPageState();
}

class _SavedReportsPageState extends State<SavedReportsPage> {
  final LocalReportsLocalDatasource localDatasource =
  LocalReportsLocalDatasource();

  final ReportsRemoteDatasource reportsRemote =
  ReportsRemoteDatasource(ApiClient());

  List<MapEntry<dynamic, LocalReport>> reports = [];

  bool loading = true;
  bool sending = false;

  String sendingMessage = "Enviando reporte...";

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  Future<void> loadReports({bool syncTracking = true}) async {
    setState(() {
      loading = true;
    });

    try {
      final data = await localDatasource.getReportsByUser(
        widget.user.numeroEmpleado,
      );

      final list = data.entries.toList()
        ..sort(
              (a, b) => b.value.fechaRegistro.compareTo(a.value.fechaRegistro),
        );

      if (!mounted) return;

      setState(() {
        reports = list;
        loading = false;
      });

      if (syncTracking) {
        await syncReportsTrackingStatus();
      }
    } catch (e) {
      print("ERROR LOAD REPORTS: $e");

      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  Future<void> syncReportsTrackingStatus() async {
    final hasInternet = await NetworkInfo().hasInternet();

    if (!hasInternet) return;

    for (final entry in reports) {
      final key = entry.key;
      final report = entry.value;

      // Solo reportes enviados
      if (report.status != "sent") continue;

      // Debe tener ID del reporte generado en backend
      if (report.resultadoReporteId == null) continue;

      // Si ya está cancelado o resuelto, ya no se consulta
      if (report.seguimientoEstatusId == 3 ||
          report.seguimientoEstatusId == 4) {
        print(
          "SE OMITE REPORTE ${report.resultadoReporteId}: "
              "${report.seguimientoEstatus}",
        );
        continue;
      }

      try {
        final response = await reportsRemote.getReportTrackingStatus(
          report.resultadoReporteId!,
        );

        if (response == null ||
            response["success"] != true ||
            response["data"] == null) {
          continue;
        }

        final data = response["data"];

        final updatedReport = report.copyWith(
          seguimientoEstatusId: data["estatusId"],
          seguimientoEstatus: data["estatus"],
          seguimientoCorreoResponsable: data["correoResponsable"],
          seguimientoTipoResponsable: data["tipoResponsable"],
          seguimientoFechaActualizacion: DateTime.now().toIso8601String(),
        );

        await localDatasource.updateReport(key, updatedReport);
      } catch (e) {
        print(
          "ERROR SYNC TRACKING STATUS "
              "${report.resultadoReporteId}: $e",
        );
      }
    }

    if (!mounted) return;

    await loadReports(syncTracking: false);
  }

  String getStatusLabel(String status) {
    switch (status) {
      case "draft":
        return "Borrador";
      case "sent":
        return "Enviado";
      default:
        return status;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "draft":
        return AppTheme.dorado;
      case "sent":
        return Colors.green;
      default:
        return AppTheme.textColor;
    }
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> confirmSendDraft(
      dynamic key,
      LocalReport report,
      ) async {
    final hasInternet = await NetworkInfo().hasInternet();

    if (!hasInternet) {
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Sin conexión"),
          content: const Text(
            "Necesitas conexión a internet para enviar este reporte.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Aceptar"),
            ),
          ],
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
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
                Icons.send_outlined,
                color: Colors.white,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Enviar reporte",
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
                color: AppTheme.dorado.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.cloud_upload_outlined,
                color: AppTheme.dorado,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "¿Deseas enviar este reporte borrador ahora?",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.marBaltico,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Se requiere conexión a internet.",
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
            icon: const Icon(Icons.send),
            label: const Text("Enviar"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dorado,
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

    if (confirmed == true) {
      await sendDraftReport(key, report);
    }
  }

  Future<List<String>> convertImagesToBase64(List<String> paths) async {
    List<String> images = [];

    for (final path in paths) {
      final file = File(path);

      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        final base64Str = base64Encode(bytes);

        final lower = path.toLowerCase();
        String mimeType = "image/jpeg";

        if (lower.endsWith(".png")) {
          mimeType = "image/png";
        } else if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) {
          mimeType = "image/jpeg";
        }

        images.add("data:$mimeType;base64,$base64Str");
      }
    }

    return images;
  }

  Future<void> sendDraftReport(
      dynamic key,
      LocalReport report,
      ) async {
    setState(() {
      sending = true;
      sendingMessage = "Enviando reporte...";
    });

    try {
      final payload = {
        "reporteId": report.reporteId,
        "usuarioMovilId": report.usuarioMovilId,
        "nivelRiesgoId": report.nivelRiesgoId,
        "tipoIncidenciaId": report.tipoIncidenciaId,
        "reporteTipoElementoId": report.reporteTipoElementoId,
        "elementoId": report.elementoId,
        "correoResponsable": report.correoResponsable,
        "latitud": report.latitud,
        "longitud": report.longitud,
        "camposPersonalizados": report.camposPersonalizados
            .map((e) => {
          "campoPersonalizadoId": e["campoPersonalizadoId"],
          "valor": e["valor"],
        })
            .toList(),
        "fechaRegistro": report.fechaRegistro,
      };

      print("========== JSON REENVÍO REPORTE ==========");
      print(const JsonEncoder.withIndent('  ').convert(payload));
      print("==========================================");

      final response = await reportsRemote.sendReport(payload);

      if (response == null ||
          response["success"] != true ||
          response["data"] == null) {
        throw Exception("No se pudo enviar el reporte");
      }

      final data = response["data"];
      final resultadoReporteId = data["resultadoReporteId"];
      final yaExistia = data["yaExistia"] ?? false;

      if (report.evidenciasPaths.isNotEmpty && resultadoReporteId != null) {
        setState(() {
          sendingMessage = "Enviando imágenes...";
        });

        final evidenciasBase64 =
        await convertImagesToBase64(report.evidenciasPaths);

        print("========== JSON EVIDENCIAS ==========");
        print(
          const JsonEncoder.withIndent('  ').convert({
            "evidencias": evidenciasBase64
                .map((e) => {"base64": e})
                .toList(),
          }),
        );
        print("=====================================");

        final evidencesResponse = await reportsRemote.sendEvidences(
          resultadoReporteId: resultadoReporteId,
          evidenciasBase64: evidenciasBase64,
        );

        if (evidencesResponse == null) {
          throw Exception("No se pudieron enviar las evidencias");
        }
      }

      final updatedReport = report.copyWith(
        status: "sent",
        resultadoReporteId: resultadoReporteId,
        yaExistia: yaExistia,
        fechaActualizacion: DateTime.now().toIso8601String(),
      );

      await localDatasource.updateReport(key, updatedReport);

      if (!mounted) return;

      showMsg("Reporte enviado correctamente");
      await loadReports();
    } catch (e) {
      print("ERROR SEND DRAFT REPORT: $e");

      final updatedReport = report.copyWith(
        status: "draft",
        fechaActualizacion: DateTime.now().toIso8601String(),
      );

      await localDatasource.updateReport(key, updatedReport);

      if (!mounted) return;

      showMsg("Error al enviar reporte: $e");
      await loadReports();
    } finally {
      if (!mounted) return;

      setState(() {
        sending = false;
        sendingMessage = "Enviando reporte...";
      });
    }
  }

  Widget _statusBadge(LocalReport item) {
    final color = getStatusColor(item.status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            item.status == "sent"
                ? Icons.check_circle_outline
                : Icons.edit_note_outlined,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            getStatusLabel(item.status),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportCard(
      BuildContext context,
      dynamic key,
      LocalReport item,
      ) {
    final isDraft = item.status == "draft";

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      color: Colors.white,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppTheme.dorado.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    color: AppTheme.dorado,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.reportTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppTheme.marBaltico,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.reportElementDescription,
                        style: const TextStyle(
                          color: AppTheme.textColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _statusBadge(item),
              ],
            ),

            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: AppTheme.dorado.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.dorado.withOpacity(0.25),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.qr_code_2,
                    size: 20,
                    color: AppTheme.dorado,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Elemento: ${item.elementoIdentificador}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppTheme.marBaltico,
                          ),
                        ),
                        if (item.elementoResumen.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.elementoResumen,
                            style: const TextStyle(
                              color: AppTheme.textColor,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            _trackingStatusBanner(item),

            if (item.evidenciasPaths.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.photo_camera_outlined,
                    size: 18,
                    color: AppTheme.dorado,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "${item.evidenciasPaths.length} evidencia(s)",
                    style: const TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),

            if (isDraft)
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
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
                      onPressed: sending
                          ? null
                          : () => confirmSendDraft(key, item),
                      icon: const Icon(Icons.send),
                      label: const Text("Enviar reporte"),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.marBaltico,
                            side: BorderSide(
                              color: AppTheme.dorado.withOpacity(0.55),
                            ),
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
                                  report: buildReportType(item),
                                  editingReport: item,
                                  reportKey: key,
                                ),
                              ),
                            );

                            if (!mounted) return;
                            await loadReports();
                          },
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text("Editar"),
                        ),
                      ),

                      const SizedBox(width: 10),

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
                          onPressed: sending
                              ? null
                              : () => confirmDeleteReport(key),
                          icon: const Icon(Icons.delete_outline),
                          label: const Text("Eliminar"),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.marBaltico,
                    side: BorderSide(
                      color: AppTheme.dorado.withOpacity(0.55),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SavedReportDetailPage(
                          report: item,
                          reportKey: key,
                          user: widget.user,
                        ),
                      ),
                    );

                    if (!mounted) return;
                    await loadReports();
                  },
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text("Ver detalles"),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sendingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.35),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 28),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppTheme.dorado.withOpacity(0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: AppTheme.dorado,
              ),
              const SizedBox(height: 18),
              Text(
                sendingMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.marBaltico,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis reportes"),
      ),
      body: Stack(
        children: [
          if (loading)
            const Center(child: CircularProgressIndicator())
          else if (reports.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppTheme.dorado.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(
                        Icons.folder_copy_outlined,
                        color: AppTheme.dorado,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "No hay reportes guardados",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.marBaltico,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Los reportes que guardes o envíes aparecerán aquí.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textColor,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final entry = reports[index];
                final key = entry.key;
                final item = entry.value;

                return _reportCard(context, key, item);
              },
            ),
          if (sending) _sendingOverlay(),
        ],
      ),
    );
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
  Future<void> deleteReport(dynamic key) async {
    try {
      await localDatasource.deleteReport(key);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Reporte eliminado"),
        ),
      );

      await loadReports();
    } catch (e) {
      print("ERROR DELETE REPORT: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al eliminar: $e"),
        ),
      );
    }
  }

  Future<void> confirmDeleteReport(dynamic key) async {
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
                    "¿Estás seguro de eliminar este borrador?",
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

    if (confirm == true) {
      await deleteReport(key);
    }
  }
  Widget _trackingStatusBanner(LocalReport item) {
    final estatus = item.seguimientoEstatus;

    if (item.status != "sent" ||
        estatus == null ||
        estatus.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final color = getTrackingStatusColor(
      item.seguimientoEstatusId,
    );

    final icon = getTrackingStatusIcon(
      item.seguimientoEstatusId,
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
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
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 21,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Estatus de seguimiento",
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
                    fontSize: 15,
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
}