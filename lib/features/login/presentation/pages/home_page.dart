import 'package:app_oca/features/reports/data/datasources/elements_detail_local_datasource.dart';
import 'package:app_oca/features/reports/data/datasources/technical_location_datasource.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';

import '../../../../core/app_theme.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/storage/sync_storage.dart';

import '../../../catalogs/data/datasources/catalog_remote_datasource.dart';
import '../../../reports/data/datasources/custom_fields_local_datasource.dart';
import '../../../reports/data/datasources/elements_local_datasource.dart';
import '../../../reports/data/datasources/incident_types_local_datasource.dart';
import '../../../reports/data/datasources/report_categories_local_datasource.dart';
import '../../../reports/data/datasources/report_elements_local_datasource.dart';
import '../../../reports/data/datasources/reports_local_datasource.dart';
import '../../../reports/data/datasources/risk_levels_local_datasource.dart';
import '../../../reports/domain/entities/local_report.dart';
import '../../../reports/domain/entities/technical_location.dart';
import '../../../reports/presentation/report_page.dart';
import '../../../reports/data/datasources/local_reports_local_datasource.dart';
import '../../../reports/data/datasources/reports_remote_datasource.dart';
import '../../../reports/presentation/saved_reports_page.dart';
import '../../../sync/data/datasources/sync_remote_datasource.dart';
import '../../../sync/data/repositories/sync_repositories.dart';

import '../../domain/entities/user.dart';
import '../../data/datasources/login_local_datasource.dart';
import '../../data/datasources/login_remote_datasource.dart';
import '../../data/repositories/login_repository.dart';

import 'login_page.dart';

class HomePage extends StatefulWidget {
  final User user;

  const HomePage({
    super.key,
    required this.user,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool syncing = false;
  String lastSync = "No sincronizado";
  String unidadNegocio = "Cargando...";

  bool autoSending = false;
  int totalToSend = 0;
  int sentCount = 0;

  late LocalReportsLocalDatasource localReportsLocal;
  late ReportsRemoteDatasource reportsRemote;

  final LocalReportsLocalDatasource localDatasource =
  LocalReportsLocalDatasource();

  bool sending = false;

  late User currentUser;
  late LoginRepository loginRepository;
  List<MapEntry<dynamic, LocalReport>> draftReports = [];
  bool loadingDrafts = true;

  @override
  void initState() {
    super.initState();

    currentUser = widget.user;

    final apiClient = ApiClient();

    loginRepository = LoginRepository(
      LoginRemoteDatasource(apiClient),
      LoginLocalDatasource(),
    );

    localReportsLocal = LocalReportsLocalDatasource();
    reportsRemote = ReportsRemoteDatasource(apiClient);

    loadLastSync();
    loadUnidadNegocio();
    loadDrafts();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await autoSyncIfNeeded();
      await autoSendDraftsIfNeeded();
    });
  }

  Future<void> loadLastSync() async {
    final storage = SyncStorage();
    final date = await storage.getLastSyncUiDate(currentUser.numeroEmpleado);

    if (date != null && mounted) {
      setState(() {
        lastSync = date;
      });
    }
  }

  Future<void> autoSyncIfNeeded() async {
    final storage = SyncStorage();

    final lastBackendDate = await storage.getLastBackendUpdateDate(
      currentUser.numeroEmpleado,
    );

    final lastUiDate = await storage.getLastSyncUiDate(
      currentUser.numeroEmpleado,
    );

    final alreadySynced = lastBackendDate != null || lastUiDate != null;

    if (alreadySynced) {
      return;
    }

    final hasInternet = await NetworkInfo().hasInternet();

    if (!hasInternet) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "No tienes conexión. La sincronización inicial se realizará cuando tengas internet.",
          ),
        ),
      );

      return;
    }

    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
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
                Icons.sync,
                color: Colors.white,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Sincronización inicial",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        content: const Text(
          "Estamos preparando tus catálogos por primera vez. Esto puede tardar unos segundos.",
          style: TextStyle(
            color: AppTheme.textColor,
            fontSize: 15,
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.dorado,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Aceptar"),
            ),
          ),
        ],
      ),
    );

    if (!mounted) return;

    await startSync();
  }

  Future<void> loadUnidadNegocio() async {
    try {
      final apiClient = ApiClient();
      final datasource = CatalogRemoteDatasource(apiClient);

      final data = await datasource.getUnidadesNegocio();

      final match = data.cast<Map<String, dynamic>>().firstWhere(
            (e) => e["id"] == currentUser.unidadNegocioId,
        orElse: () => {},
      );

      if (match.isNotEmpty && mounted) {
        setState(() {
          unidadNegocio = (match["descripcion"] ?? "Sin unidad") as String;
        });
      }
    } catch (e) {
      print("ERROR UNIDAD NEGOCIO: $e");
    }
  }

  Future<void> startSync() async {
    setState(() {
      syncing = true;
    });

    try {
      final apiClient = ApiClient();

      final syncRepo = SyncRepository(
        SyncRemoteDatasource(apiClient),
        ReportsLocalDatasource(),
        ReportCategoriesLocalDatasource(),
        ReportElementsLocalDatasource(),
        CustomFieldsLocalDatasource(),
        RiskLevelsLocalDatasource(),
        IncidentTypesLocalDatasource(),
        ElementDetailsLocalDatasource(),
        ElementsLocalDatasource(),
        TechnicalLocationsLocalDatasource(),
      );

      final storage = SyncStorage();

      final unidadNegocioId = currentUser.unidadNegocioId;

      if (unidadNegocioId == 0) {
        throw Exception("El usuario no tiene unidad de negocio asignada.");
      }

      final lastBackendDate = await storage.getLastBackendUpdateDate(currentUser.numeroEmpleado);
      final fechaConsulta = lastBackendDate ?? "2026-01-01T00:00:00";

      print("FECHA CONSULTA SYNC: $fechaConsulta");

      await syncRepo.syncAllCatalogs(
        unidadNegocioId: unidadNegocioId,
        fechaActualizacion: fechaConsulta,
      );

      final updatedUser = await loginRepository.syncUser(
        currentUser.numeroEmpleado,
      );

      if (updatedUser != null) {

        bool hasChanges =
            updatedUser.nombreCompleto != currentUser.nombreCompleto ||
                updatedUser.correo != currentUser.correo ||
                updatedUser.departamento != currentUser.departamento ||
                updatedUser.ubicacionTecnica != currentUser.ubicacionTecnica ||
                updatedUser.unidadNegocioId != currentUser.unidadNegocioId;

        if (!updatedUser.activo) {

          if (!mounted) return;

          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              title: const Text("Sesión finalizada"),
              content: const Text(
                "Tu usuario ha sido desactivado. Contacta a soporte.",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Aceptar"),
                ),
              ],
            ),
          );

          await LoginLocalDatasource().clearUsers();

          if (!mounted) return;

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const LoginPage(),
            ),
                (route) => false,
          );

          return;
        }

        if (!mounted) return;

        setState(() {
          currentUser = updatedUser;
        });

        await loadUnidadNegocio();

        if (hasChanges && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Tu información fue actualizada"),
            ),
          );
        }
      }

      final now = DateTime.now();
      final backendFormatted = DateFormat("yyyy-MM-ddTHH:mm:ss").format(now);
      final uiFormatted = DateFormat("dd/MM/yyyy hh:mm a").format(now);

      await storage.saveLastBackendUpdateDate(
        backendFormatted,
        currentUser.numeroEmpleado,
      );

      await storage.saveLastSyncUiDate(
        uiFormatted,
        currentUser.numeroEmpleado,
      );

      if (!mounted) return;

      setState(() {
        lastSync = uiFormatted;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sincronización completada"),
        ),
      );
    } catch (e) {
      print("ERROR SYNC: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al sincronizar: $e"),
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        syncing = false;
      });
    }
  }

  Future<void> loadDrafts() async {
    final data = await localReportsLocal.getReportsByUser(
      currentUser.numeroEmpleado,
    );

    final drafts = data.entries
        .where((e) => e.value.status == "draft")
        .toList();

    if (!mounted) return;

    setState(() {
      draftReports = drafts;
      loadingDrafts = false;
    });
  }

  Future<List<String>> convertImagesToBase64(List<String> paths) async {
    List<String> images = [];

    for (final path in paths) {
      final file = File(path);

      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        final base64Str = base64Encode(bytes);

        String mimeType = "image/jpeg";

        if (path.toLowerCase().endsWith(".png")) {
          mimeType = "image/png";
        }

        images.add("data:$mimeType;base64,$base64Str");
      }
    }

    return images;
  }

  Future<void> sendAllDrafts() async {
    final hasInternet = await NetworkInfo().hasInternet();

    if (!hasInternet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No tienes conexión a internet")),
      );
      return;
    }

    setState(() {
      sending = true;
      totalToSend = draftReports.length;
      sentCount = 0;
    });

    try {
      for (final entry in draftReports) {
        final key = entry.key;
        final report = entry.value;

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

        final response = await reportsRemote.sendReport(payload);

        if (response != null && response["success"] == true) {
          final data = response["data"];
          int resultadoReporteId = data["resultadoReporteId"];

          /// 🔥 evidencias
          if (report.evidenciasPaths.isNotEmpty) {
            final evidenciasBase64 =
            await convertImagesToBase64(report.evidenciasPaths);

            await reportsRemote.sendEvidences(
              resultadoReporteId: resultadoReporteId,
              evidenciasBase64: evidenciasBase64,
            );
          }

          final updated = report.copyWith(
            status: "sent",
            resultadoReporteId: resultadoReporteId,
          );

          await localReportsLocal.updateReport(key, updated);

          sentCount++;
          if (mounted) setState(() {});
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Todos los reportes enviados")),
      );

      await loadDrafts();
    } catch (e) {
      print("ERROR SEND ALL: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al enviar reportes")),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        sending = false;
        totalToSend = 0;
        sentCount = 0;
      });
    }
  }

  Future<void> autoSendDraftsIfNeeded() async {
    final hasInternet = await NetworkInfo().hasInternet();

    if (!hasInternet) return;

    final data = await localDatasource.getReportsByUser(
      widget.user.numeroEmpleado,
    );

    final drafts = data.entries
        .where((e) => e.value.status == "draft")
        .toList();

    if (drafts.isEmpty) return;

    setState(() {
      autoSending = true;
      totalToSend = drafts.length;
      sentCount = 0;
    });

    try {
      for (final entry in drafts) {
        final key = entry.key;
        final report = entry.value;

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

        final response = await reportsRemote.sendReport(payload);

        if (response != null && response["success"] == true) {
          final data = response["data"];
          final resultadoReporteId = data["resultadoReporteId"];

          /// 🔥 EVIDENCIAS
          if (report.evidenciasPaths.isNotEmpty) {
            final evidenciasBase64 =
            await convertImagesToBase64(report.evidenciasPaths);

            await reportsRemote.sendEvidences(
              resultadoReporteId: resultadoReporteId,
              evidenciasBase64: evidenciasBase64,
            );
          }

          final updated = report.copyWith(
            status: "sent",
            resultadoReporteId: resultadoReporteId,
          );

          await localReportsLocal.updateReport(key, updated);
        }

        /// 🔥 PROGRESO
        if (mounted) {
          setState(() {
            sentCount++;
          });
        }
      }

      await loadDrafts();
    } catch (e) {
      print("AUTO SEND ERROR: $e");
    } finally {
      if (mounted) {
        setState(() {
          autoSending = false;
        });
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final user = currentUser;

    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: const Text("Inicio"),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  color: Colors.white,
                  onPressed: () async {
                    await _logout(context);
                  },
                )
              ],
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Card(
                      elevation: 2,
                      color: Colors.white,
                      shadowColor: AppTheme.dorado.withOpacity(0.18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(
                          color: AppTheme.dorado.withOpacity(0.35),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: AppTheme.dorado.withOpacity(0.15),
                                  child: const Icon(
                                    Icons.person,
                                    size: 30,
                                    color: AppTheme.dorado,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.nombreCompleto,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.marBaltico,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        user.correo,
                                        style: const TextStyle(
                                          color: AppTheme.textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),

                            const SizedBox(height: 20),
                            Divider(
                              color: AppTheme.dorado.withOpacity(0.25),
                            ),
                            const SizedBox(height: 10),

                            _infoRow(
                              icon: Icons.badge,
                              text: "No. empleado: ${user.nombreUsuario}",
                            ),

                            const SizedBox(height: 12),

                            _infoRow(
                              icon: Icons.apartment,
                              text: "Departamento: ${user.departamento}",
                            ),

                            const SizedBox(height: 12),

                            _infoRow(
                              icon: Icons.location_on,
                              text: "Ubicación tecnica: ${user.ubicacionTecnica}",
                            ),

                            const SizedBox(height: 12),

                            _infoRow(
                              icon: Icons.business,
                              text: "Unidad de negocio: $unidadNegocio",
                            ),

                            const SizedBox(height: 16),
                            Divider(
                              color: AppTheme.dorado.withOpacity(0.25),
                            ),
                            const SizedBox(height: 10),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.sync,
                                  color: AppTheme.dorado,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Última sincronización",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.marBaltico,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        lastSync,
                                        style: const TextStyle(
                                          color: AppTheme.textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Card(
                      elevation: 2,
                      color: Colors.white,
                      shadowColor: AppTheme.dorado.withOpacity(0.18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(
                          color: AppTheme.dorado.withOpacity(0.35),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.assignment_outlined,
                                  color: AppTheme.dorado,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Mis reportes",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.marBaltico,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            Text(
                              "${draftReports.length} pendiente(s) por enviar",
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppTheme.textColor,
                              ),
                            ),

                            const SizedBox(height: 12),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: draftReports.isEmpty ? null : sendAllDrafts,
                                icon: const Icon(Icons.send),
                                label: Text(
                                  "${draftReports.length} pendiente(s) por enviar",
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.dorado,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.grey.shade300,
                                  disabledForegroundColor: Colors.grey.shade600,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: MediaQuery.of(context).size.width > 600
                          ? 1.2
                          : 1.05,
                      children: [
                        _menuItem(
                          context: context,
                          icon: Icons.sync,
                          title: "Sincronizar\nDatos",
                          onTap: () async {
                            final network = NetworkInfo();
                            final hasInternet = await network.hasInternet();

                            if (!hasInternet) {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("Sin conexión"),
                                  content: const Text(
                                    "Necesitas conexión a internet para sincronizar los datos.",
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

                            showDialog(
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
                                        Icons.sync,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          "Sincronizar datos",
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
                                        Icons.wifi,
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
                                            "¿Deseas sincronizar la información ahora?",
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
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text(
                                      "Cancelar",
                                      style: TextStyle(
                                        color: AppTheme.textColor,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      startSync();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.dorado,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text("Aceptar"),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        _menuItem(
                          context: context,
                          icon: Icons.download,
                          title: "Generar\nReporte",
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReportsPage(user: user),
                              ),
                            );

                            await loadDrafts();
                          },
                        ),

                        _menuItem(
                          context: context,
                          icon: Icons.folder_copy_outlined,
                          title: "Mis\nReportes",
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SavedReportsPage(
                                  user: widget.user,
                                ),
                              ),
                            );

                            await loadDrafts();
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          if (syncing)
            Container(
              color: Colors.black.withOpacity(0.45),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text(
                      "Sincronizando datos...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    )
                  ],
                ),
              ),
            ),
          if (autoSending)
            Container(
              color: Colors.black.withOpacity(0.45),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),

                    Text(
                      "Enviando reportes...",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "$sentCount de $totalToSend",
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: 200,
                      child: LinearProgressIndicator(
                        value: totalToSend == 0
                            ? 0
                            : sentCount / totalToSend,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Widget _infoRow({
  required IconData icon,
  required String text,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(
        icon,
        color: AppTheme.dorado,
        size: 22,
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: AppTheme.marBaltico,
          ),
        ),
      ),
    ],
  );
}
//
Widget _menuItem({
  required BuildContext context,
  required IconData icon,
  required String title,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Card(
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppTheme.dorado.withOpacity(0.14),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 30,
                color: AppTheme.dorado,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppTheme.marBaltico,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _logout(BuildContext context) async {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (_) => const LoginPage(),
    ),
        (route) => false,
  );
}