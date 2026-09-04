import 'dart:convert';
import 'dart:io';
import 'package:app_oca/core/network/api_client.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/network/location_service.dart';
import '../../login/domain/entities/user.dart';
import '../data/datasources/elements_detail_local_datasource.dart';
import '../data/datasources/report_elements_local_datasource.dart';
import '../data/datasources/elements_local_datasource.dart';
import '../data/datasources/custom_fields_local_datasource.dart';
import '../data/datasources/reports_remote_datasource.dart';
import '../data/datasources/risk_levels_local_datasource.dart';
import '../data/datasources/incident_types_local_datasource.dart';
import '../data/datasources/local_reports_local_datasource.dart';
import 'package:permission_handler/permission_handler.dart';
import '../data/datasources/technical_location_datasource.dart';
import '../domain/entities/element_detail.dart';
import '../domain/entities/report_type.dart';
import '../domain/entities/report_element.dart';
import '../domain/entities/element.dart';
import '../domain/entities/custom_field.dart';
import '../domain/entities/risk_level.dart';
import '../domain/entities/incident_type.dart';
import '../domain/entities/local_report.dart';
import '../domain/entities/technical_location.dart';
import '../../../../core/app_theme.dart';

class ReportFormPage extends StatefulWidget {
  final User user;
  final ReportType report;
  final LocalReport? editingReport;
  final dynamic reportKey;

  const ReportFormPage({
    super.key,
    required this.user,
    required this.report,
    this.editingReport,
    this.reportKey,
  });

  @override
  State<ReportFormPage> createState() => _ReportFormPageState();
}

class _ReportFormPageState extends State<ReportFormPage> {
  final reportElementsLocal = ReportElementsLocalDatasource();
  final elementsLocal = ElementsLocalDatasource();
  final customFieldsLocal = CustomFieldsLocalDatasource();
  final riskLevelsLocal = RiskLevelsLocalDatasource();
  final incidentTypesLocal = IncidentTypesLocalDatasource();
  final localReportsLocal = LocalReportsLocalDatasource();
  final elementDetailsLocal = ElementDetailsLocalDatasource();
  final locationService = LocationService();
  final technicalLocationsLocal = TechnicalLocationsLocalDatasource();

  late ReportsRemoteDatasource reportsRemote;

  List<ElementoDetalle> selectedElementDetails = [];
  final TextEditingController elementoSearchController =
  TextEditingController();

  List<ReportElement> reportElements = [];
  ReportElement? selectedReportElement;
  List<Elemento> elementos = [];
  Elemento? selectedElemento;

  List<CustomField> customFields = [];
  List<RiskLevel> riskLevels = [];
  List<IncidentType> incidentTypes = [];

  List<TechnicalLocation> technicalLocations = [];
  TechnicalLocation? selectedTechnicalLocation;

  final Map<int, TextEditingController> controllers = {};

  int? selectedRiskLevelId;
  int? selectedIncidentTypeId;
  int autocompleteRefreshKey = 0;

  bool loading = true;
  bool saving = false;
  bool allowExit = false;
  bool isSending = false;

  List<File> evidencias = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    reportsRemote = ReportsRemoteDatasource(ApiClient());

    loadInitialData();
    loadTechnicalLocations();

    if (widget.editingReport != null) {
      loadEditingData();
    }
  }

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    elementoSearchController.dispose();
    super.dispose();
  }

  bool get hasFormChanges {
    final hasCustomText = controllers.values.any(
          (c) => c.text.trim().isNotEmpty,
    );

    return selectedElemento != null ||
        selectedRiskLevelId != null ||
        selectedIncidentTypeId != null ||
        hasCustomText ||
        evidencias.isNotEmpty;
  }

  Future<bool> confirmChangeReportType() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
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
                Icons.warning_amber_rounded,
                color: Colors.white,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Cambiar tipo de reporte",
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
                Icons.change_circle_outlined,
                color: AppTheme.dorado,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                "Si cambias el tipo de reporte se borrarán los datos capturados del formulario actual. ¿Deseas continuar?",
                style: TextStyle(
                  fontSize: 15,
                  height: 1.35,
                  color: AppTheme.textColor,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(
              "Cancelar",
              style: TextStyle(
                color: AppTheme.textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.check),
            label: const Text("Continuar"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dorado,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 11,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<bool> confirmExitForm() async {
    if (!hasFormChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
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
                Icons.warning_amber_rounded,
                color: Colors.white,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Salir del formulario",
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
                Icons.edit_note_outlined,
                color: AppTheme.dorado,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                "Tienes información capturada sin guardar. Si sales ahora, perderás los cambios. ¿Deseas salir?",
                style: TextStyle(
                  fontSize: 15,
                  height: 1.35,
                  color: AppTheme.textColor,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(
              "Cancelar",
              style: TextStyle(
                color: AppTheme.textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.exit_to_app),
            label: const Text("Salir"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dorado,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 11,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  void resetDependentForm() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    controllers.clear();

    setState(() {
      selectedElemento = null;
      selectedElementDetails = [];
      elementos = [];
      customFields = [];
      riskLevels = [];
      incidentTypes = [];
      selectedRiskLevelId = null;
      selectedIncidentTypeId = null;
      evidencias.clear();
      elementoSearchController.clear();
      autocompleteRefreshKey++;
    });
  }

  Future<void> loadInitialData() async {
    final all = await reportElementsLocal.getReportElements();

    final filtered = all.where((e) {
      return e.reporteId == widget.report.reporteId && e.activo;
    }).toList();

    if (!mounted) return;

    setState(() {
      reportElements = filtered;
      loading = false;
    });
  }

  Future<void> loadElementos(int tipoElementoId) async {
    final all = await elementsLocal.getElements();

    final filtered = all.where((e) {
      return e.tipoElementoId == tipoElementoId && e.activo;
    }).toList();

    if (!mounted) return;

    setState(() {
      elementos = filtered;
      selectedElemento = null;
      selectedElementDetails = [];
    });
  }

  Future<void> loadElementDetails(int elementoId) async {
    final allDetails = await elementDetailsLocal.getElementDetails();

    final filtered = allDetails.where((e) {
      return e.elementoId == elementoId && e.activo;
    }).toList();

    if (!mounted) return;

    setState(() {
      selectedElementDetails = filtered;
    });
  }

  String buildElementDetailsSummary(List<ElementoDetalle> details) {
    if (details.isEmpty) return "Sin detalles";

    return details
        .where((e) => e.descripcion.trim().isNotEmpty)
        .map((e) => "${e.valor}: ${e.descripcion}")
        .join("\n");
  }

  Future<void> loadDynamicCatalogs(int reporteTipoElementoId) async {
    final allFields = await customFieldsLocal.getCustomFields();
    final allRisk = await riskLevelsLocal.getRiskLevels();
    final allIncident = await incidentTypesLocal.getIncidentTypes();

    final fields = allFields.where((e) {
      return e.reporteTipoElementoId == reporteTipoElementoId && e.activo;
    }).toList();

    final risk = allRisk.where((e) {
      return e.reporteTipoElementoId == reporteTipoElementoId && e.activo;
    }).toList();

    final incident = allIncident.where((e) {
      return e.reporteTipoElementoId == reporteTipoElementoId && e.activo;
    }).toList();

    for (final f in fields) {
      controllers[f.campoPersonalizadoId] = TextEditingController();
    }

    if (!mounted) return;

    setState(() {
      customFields = fields;
      riskLevels = risk;
      incidentTypes = incident;
    });
  }

  Future<void> loadTechnicalLocations() async {
    final all = await technicalLocationsLocal.getTechnicalLocations();

    if (!mounted) return;

    setState(() {
      technicalLocations = all;

      setDefaultTechnicalLocationFromUser();
    });
  }

  void setDefaultTechnicalLocationFromUser() {
    if (selectedTechnicalLocation != null) return;

    if (widget.user.ubicacionTecnicaId == 0) return;

    TechnicalLocation? defaultLocation;

    for (final location in technicalLocations) {
      if (location.ubicacionTecnicaId == widget.user.ubicacionTecnicaId) {
        defaultLocation = location;
        break;
      }
    }

    if (defaultLocation == null) return;

    selectedTechnicalLocation = defaultLocation;
  }

  Future<void> takePhoto() async {
    if (evidencias.length >= 5) {
      showMsg("Máximo 5 fotos permitidas");
      return;
    }

    final status = await Permission.camera.request();

    if (!status.isGranted) {
      if (status.isPermanentlyDenied) {
        showMsg("El permiso de cámara está bloqueado. Actívalo desde configuración.");
        await openAppSettings();
      } else {
        showMsg("Se necesita permiso de cámara para tomar evidencias.");
      }
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

  String now() => DateTime.now().toIso8601String();

  Future<void> saveOrSend({bool send = false}) async {
    if (!validateForm()) return;
    setState(() {
      saving = true;
      isSending = send;
    });


    setState(() => saving = true);

    try {
      final hasInternet = await NetworkInfo().hasInternet();
      final pos = await locationService.getCurrentLocation();

      final payload = {
        "reporteId": widget.report.reporteId,
        "usuarioMovilId": widget.user.usuarioId,
        "nivelRiesgoId": selectedRiskLevelId,
        "tipoIncidenciaId": selectedIncidentTypeId,
        "reporteTipoElementoId":
        selectedReportElement!.reporteTipoElementoId,
        "elementoId": selectedElemento!.elementoId,
        "correoResponsable": widget.user.correo,
        "latitud": pos?.latitude ?? 0,
        "longitud": pos?.longitude ?? 0,
        "camposPersonalizados": customFields.map((f) {
          return {
            "campoPersonalizadoId": f.campoPersonalizadoId,
            "valor": controllers[f.campoPersonalizadoId]?.text ?? ""
          };
        }).toList(),
        "fechaRegistro": now(),
        "ubicacionTecnicaId":
        selectedTechnicalLocation!.ubicacionTecnicaId,
        "unidadNegocioId": widget.user.unidadNegocioId,
      };

      int resultadoReporteId = 0;
      bool yaExistia = false;
      String finalStatus = "draft";

      if (send && hasInternet) {
        final reportResponse = await reportsRemote.sendReport(payload);

        if (reportResponse != null &&
            reportResponse["success"] == true) {
          final data = reportResponse["data"] ?? {};

          resultadoReporteId = data["resultadoReporteId"] ?? 0;
          yaExistia = data["yaExistia"] ?? false;

          if (evidencias.isNotEmpty && resultadoReporteId > 0) {
            print("🔵 CONVIRTIENDO IMÁGENES...");

            final evidenciasBase64 =
            await convertImagesToBase64(
              evidencias.map((e) => e.path).toList(),
            );

            print("========== JSON EVIDENCIAS ==========");
            print(const JsonEncoder.withIndent('  ').convert({
              "evidencias": evidenciasBase64
                  .map((e) => {"base64": e})
                  .toList(),
            }));
            print("=====================================");

            final evidencesResponse =
            await reportsRemote.sendEvidences(
              resultadoReporteId: resultadoReporteId,
              evidenciasBase64: evidenciasBase64,
            );

            if (evidencesResponse != null) {
              finalStatus = "sent";
            } else {
              finalStatus = "draft";
            }
          } else {
            finalStatus = "sent";
          }
        } else {
          finalStatus = "draft";
        }
      } else {
        finalStatus = "draft";
      }

      final selectedRisk = riskLevels.firstWhere(
            (e) => e.id == selectedRiskLevelId,
      );

      final selectedIncident = incidentTypes.firstWhere(
            (e) => e.id == selectedIncidentTypeId,
      );

      final camposLocal = customFields.map((f) {
        return {
          "campoPersonalizadoId": f.campoPersonalizadoId,
          "descripcion": f.descripcion,
          "valor":
          controllers[f.campoPersonalizadoId]?.text.trim() ?? "",
        };
      }).toList();

      final localReport = LocalReport(
        numeroEmpleado: widget.user.numeroEmpleado,
        reporteId: widget.report.reporteId,
        usuarioMovilId: widget.user.usuarioId,
        nivelRiesgoId: selectedRiskLevelId!,
        tipoIncidenciaId: selectedIncidentTypeId!,
        reporteTipoElementoId:
        selectedReportElement!.reporteTipoElementoId,
        correoResponsable: widget.user.correo,
        latitud: pos?.latitude ?? 0,
        longitud: pos?.longitude ?? 0,
        camposPersonalizados: camposLocal,
        fechaRegistro: now(),
        status: finalStatus,
        reportTitle: widget.report.titulo,
        reportElementDescription:
        selectedReportElement!.reporteTipoElementoDescripcion,
        elementTypeDescription:
        selectedReportElement!.tipoElementoDescripcion,
        riskLevelDescription: selectedRisk.descripcion,
        incidentTypeDescription: selectedIncident.descripcion,
        elementoId: selectedElemento!.elementoId,
        elementoIdentificador: selectedElemento!.identificador,
        elementoResumen: selectedElemento!.identificador,
        resultadoReporteId: resultadoReporteId,
        yaExistia: yaExistia,
        evidenciasPaths:
        evidencias.map((e) => e.path).toList(),
        fechaActualizacion: now(),
        ubicacionTecnicaId:
        selectedTechnicalLocation!.ubicacionTecnicaId,

        ubicacionTecnicaDescripcion:
        selectedTechnicalLocation!.denominacion,
      );

      if (widget.editingReport != null &&
          widget.reportKey != null) {
        await localReportsLocal.updateReport(
          widget.reportKey,
          localReport,
        );
      } else {
        await localReportsLocal.saveReport(localReport);
      }

      if (finalStatus == "sent") {
        await showSuccessDialog("Reporte enviado correctamente");
      } else {
        await showSuccessDialog("Guardado como borrador");
      }

      Navigator.pop(context);
    } catch (e) {
      print("❌ ERROR SAVE OR SEND: $e");
      showMsg("Error: $e");
    } finally {
      setState(() {
        saving = false;
        isSending = false;
      });
    }
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
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

        final fullBase64 = "data:$mimeType;base64,$base64Str";
        images.add(fullBase64);
      }
    }

    return images;
  }

  Future<void> confirmSendReport() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Enviar reporte"),
        content: const Text(
          "¿Estás seguro de que deseas enviar este reporte?",
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
      await saveOrSend(send: true);
    }
  }
  InputDecoration _inputDecoration({
    required String label,
    IconData? icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null
          ? null
          : Icon(
        icon,
        color: AppTheme.dorado,
      ),
      labelStyle: const TextStyle(
        color: AppTheme.textColor,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppTheme.dorado,
          width: 1.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppTheme.dorado.withOpacity(0.35),
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: allowExit || !hasFormChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldLeave = await confirmExitForm();
        if (shouldLeave && mounted) {
          setState(() {
            allowExit = true;
          });
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Nuevo reporte"),
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  DropdownButtonFormField<ReportElement>(
                    value: selectedReportElement,
                    isExpanded: true,
                    decoration: _inputDecoration(
                      label: "Tipo de reporte",
                      icon: Icons.assignment_outlined,
                    ).copyWith(
                      contentPadding: const EdgeInsets.only(
                        top: 24,
                        bottom: 18,
                        left: 12,
                        right: 12,
                      ),
                    ),
                    items: reportElements.map((e) {
                      return DropdownMenuItem<ReportElement>(
                        value: e,
                        child: Text(
                          e.reporteTipoElementoDescripcion,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                      );
                    }).toList(),
                    selectedItemBuilder: (context) {
                      return reportElements.map((e) {
                        return Text(
                          e.reporteTipoElementoDescripcion,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        );
                      }).toList();
                    },
                    onChanged: (value) async {
                      if (value == null) return;

                      if (selectedReportElement?.reporteTipoElementoId ==
                          value.reporteTipoElementoId) {
                        return;
                      }

                      if (hasFormChanges) {
                        final confirmed = await confirmChangeReportType();
                        if (!confirmed) return;
                      }

                      resetDependentForm();

                      setState(() {
                        selectedReportElement = value;
                      });

                      await loadElementos(value.tipoElementoId);
                      await loadDynamicCatalogs(
                        value.reporteTipoElementoId,
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  Autocomplete<Elemento>(
                    key: ValueKey(autocompleteRefreshKey),
                    displayStringForOption: (Elemento option) =>
                    option.identificador,
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return elementos;
                      }

                      return elementos.where((Elemento option) {
                        final query =
                        textEditingValue.text.toLowerCase();

                        return option.identificador
                            .toLowerCase()
                            .contains(query);
                      });
                    },
                    onSelected: (Elemento selection) async {
                      setState(() {
                        selectedElemento = selection;
                      });

                      await loadElementDetails(selection.elementoId);
                    },
                    fieldViewBuilder: (
                        context,
                        textEditingController,
                        focusNode,
                        onFieldSubmitted,
                        ) {
                      return TextField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: _inputDecoration(
                          label: "Elemento",
                          hint: "Escribe para buscar",
                          icon: Icons.search,
                        ),
                      );
                    },
                    optionsViewBuilder: (
                        context,
                        onSelected,
                        options,
                        ) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width:
                            MediaQuery.of(context).size.width * 0.85,
                            constraints:
                            const BoxConstraints(maxHeight: 250),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: options.length,
                              itemBuilder: (context, index) {
                                final option = options.elementAt(index);

                                return ListTile(
                                  leading: const Icon(Icons.qr_code_2),
                                  title: Text(option.identificador),
                                  onTap: () => onSelected(option),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  if (selectedElemento != null) ...[
                    const SizedBox(height: 16),
                    Card(
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
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: AppTheme.dorado.withOpacity(0.14),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.info_outline,
                                    color: AppTheme.dorado,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "Detalle del elemento",
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.marBaltico,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              "Código: ${selectedElemento!.identificador}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.marBaltico,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (selectedElementDetails.isEmpty)
                              const Text(
                                "Sin detalles disponibles",
                                style: TextStyle(color: AppTheme.textColor),
                              )
                            else
                              ...selectedElementDetails.map((detail) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "• ",
                                        style: TextStyle(
                                          color: AppTheme.dorado,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          "${detail.valor}: ${detail.descripcion}",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: AppTheme.textColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  DropdownButtonFormField<int>(
                    value: selectedIncidentTypeId,
                    decoration: _inputDecoration(
                      label: "Tipo incidencia",
                      icon: Icons.warning_amber_outlined,
                    ),
                    items: incidentTypes.map((e) {
                      return DropdownMenuItem(
                        value: e.id,
                        child: Text(e.descripcion),
                      );
                    }).toList(),
                    onChanged: (v) =>
                        setState(() => selectedIncidentTypeId = v),
                  ),

                  const SizedBox(height: 20),

                  DropdownButtonFormField<int>(
                    value: selectedRiskLevelId,
                    decoration: _inputDecoration(
                      label: "Nivel riesgo",
                      icon: Icons.health_and_safety_outlined,
                    ),
                    items: riskLevels.map((e) {
                      return DropdownMenuItem(
                        value: e.id,
                        child: Text(e.descripcion),
                      );
                    }).toList(),
                    onChanged: (v) =>
                        setState(() => selectedRiskLevelId = v),
                  ),

                  const SizedBox(height: 20),
                  DropdownButtonFormField<TechnicalLocation>(
                    value: selectedTechnicalLocation,
                    isExpanded: true,
                    decoration: _inputDecoration(
                      label: "Ubicación técnica",
                      icon: Icons.location_on_outlined,
                    ),
                    items: technicalLocations.map((location) {
                      final text =
                          "${location.descripcionZona} -";

                      return DropdownMenuItem<TechnicalLocation>(
                        value: location,
                        child: Text(
                          text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                      );
                    }).toList(),
                    selectedItemBuilder: (context) {
                      return technicalLocations.map((location) {
                        final text =
                            "${location.descripcionZona}";

                        return Text(
                          text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        );
                      }).toList();
                    },
                    onChanged: (value) {
                      setState(() {
                        selectedTechnicalLocation = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return "Selecciona una ubicación técnica";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ...customFields.map((f) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextField(
                        controller: controllers[f.campoPersonalizadoId],
                        decoration: _inputDecoration(
                          label: f.descripcion,
                          icon: Icons.edit_note,
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppTheme.dorado.withOpacity(0.30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.dorado.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppTheme.dorado.withOpacity(0.14),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.photo_camera_outlined,
                                color: AppTheme.dorado,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                "Evidencia fotográfica",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppTheme.marBaltico,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: widget.report.requiereEvidencia
                                    ? Colors.red.withOpacity(0.12)
                                    : Colors.green.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.report.requiereEvidencia ? "Obligatoria" : "Opcional",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: widget.report.requiereEvidencia
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            ...evidencias.map((file) {
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      file,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
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
                            }),

                            if (evidencias.length < 5)
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
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  FutureBuilder<bool>(
                    future: NetworkInfo().hasInternet(),
                    builder: (context, snapshot) {
                      final hasInternet = snapshot.data ?? false;

                      return SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: saving ? null : handleSubmit,
                          icon: Icon(hasInternet ? Icons.send : Icons.save),
                          label: Text(
                            hasInternet ? "Guardar reporte" : "Guardar borrador",
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
                      );
                    },
                  ),
                ],
              ),
            ),

            if (saving)
              Container(
                color: Colors.black.withOpacity(0.4),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        isSending
                            ? "Enviando reporte, por favor espera..."
                            : "Guardando borrador...",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  Future<void> loadEditingData() async {
    final r = widget.editingReport!;

    selectedRiskLevelId = r.nivelRiesgoId;
    selectedIncidentTypeId = r.tipoIncidenciaId;

    evidencias = r.evidenciasPaths
        .map((e) => File(e))
        .where((f) => f.existsSync())
        .toList();

    final allElements = await reportElementsLocal.getReportElements();

    final selected = allElements.firstWhere(
          (e) => e.reporteTipoElementoId == r.reporteTipoElementoId,
    );

    selectedReportElement = selected;

    await loadElementos(selected.tipoElementoId);
    await loadDynamicCatalogs(selected.reporteTipoElementoId);

    final allCatalog = await elementsLocal.getElements();

    selectedElemento = allCatalog.firstWhere(
          (e) => e.elementoId == r.elementoId,
    );

    elementoSearchController.text = selectedElemento!.identificador;

    await loadElementDetails(selectedElemento!.elementoId);

    for (final campo in r.camposPersonalizados) {
      controllers[campo["campoPersonalizadoId"]]?.text =
          campo["valor"] ?? "";
    }

    selectedTechnicalLocation =
        technicalLocations.firstWhere(
              (e) =>
          e.ubicacionTecnicaId ==
              r.ubicacionTecnicaId,
        );

    if (!mounted) return;

    setState(() {});
  }
  Future<void> showSuccessDialog(String message) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 50,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pop(context);

    Navigator.pop(context);
  }
  bool validateForm() {

    if (selectedReportElement == null) {
      showMsg("Selecciona tipo de reporte");
      return false;
    }

    if (selectedElemento == null) {
      showMsg("Selecciona elemento");
      return false;
    }

    if (selectedRiskLevelId == null) {
      showMsg("Selecciona nivel de riesgo");
      return false;
    }

    if (selectedIncidentTypeId == null) {
      showMsg("Selecciona tipo incidencia");
      return false;
    }

    if (selectedTechnicalLocation == null) {
      showMsg("Selecciona ubicación técnica");
      return false;
    }

    for (final field in customFields) {

      final value = controllers[field.campoPersonalizadoId]
          ?.text
          .trim() ?? "";

      if (field.obligatorio == true && value.isEmpty) {
        showMsg("El campo '${field.descripcion}' es obligatorio");
        return false;
      }
    }

    if (widget.report.requiereEvidencia && evidencias.isEmpty) {
      showMsg("Debes tomar una evidencia fotográfica");
      return false;
    }

    return true;
  }
  Future<void> handleSubmit() async {
    final hasInternet = await NetworkInfo().hasInternet();

    if (hasInternet) {
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
                      "Se enviará el reporte inmediatamente.",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.marBaltico,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "¿Deseas continuar?",
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
        await saveOrSend(send: true);
      }
    } else {
      await saveOrSend(send: false);
    }
  }
}