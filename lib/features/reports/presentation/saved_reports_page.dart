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

  Future<void> loadReports() async {
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
    } catch (e) {
      print("ERROR LOAD REPORTS: $e");

      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
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
        return Colors.orange;
      case "sent":
        return Colors.green;
      default:
        return Colors.grey;
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
        title: const Text("Enviar reporte"),
        content: const Text(
          "¿Deseas enviar este reporte borrador ahora?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Enviar"),
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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: getStatusColor(item.status).withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: getStatusColor(item.status).withOpacity(0.35),
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
            color: getStatusColor(item.status),
          ),
          const SizedBox(width: 6),
          Text(
            getStatusLabel(item.status),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: getStatusColor(item.status),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.reportTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _statusBadge(item),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.reportElementDescription,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.qr_code_2,
                    size: 18,
                    color: Colors.grey,
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
                          ),
                        ),
                        if (item.elementoResumen.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.elementoResumen,
                            style: const TextStyle(
                              color: Colors.grey,
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
            const SizedBox(height: 10),
            if (item.evidenciasPaths.isNotEmpty)
              Text(
                "${item.evidenciasPaths.length} evidencia(s)",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            const SizedBox(height: 14),
            Row(
              children: [

                /// 👁 VER / EDITAR
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      if (item.status == "draft") {
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
                      } else {
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
                      }

                      if (!mounted) return;
                      await loadReports();
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text("Ver detalles"),
                  ),
                ),

                if (item.status == "draft") ...[

                  const SizedBox(width: 10),

                  /// 🚀 ENVIAR
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: sending
                          ? null
                          : () => confirmSendDraft(key, item),
                      icon: const Icon(Icons.send),
                      label: const Text("Enviar"),
                    ),
                  ),

                  const SizedBox(width: 10),

                  /// ❌ ELIMINAR
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      onPressed: sending
                          ? null
                          : () => confirmDeleteReport(key),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text("Eliminar"),
                    ),
                  ),
                ],
              ],
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
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 18),
              Text(
                sendingMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
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
            const Center(
              child: Text("No hay reportes guardados"),
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
        title: const Text("Eliminar reporte"),
        content: const Text(
          "¿Estás seguro de eliminar este borrador?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await deleteReport(key);
    }
  }
}