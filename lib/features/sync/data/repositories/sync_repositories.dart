import 'package:app_oca/features/sync/data/datasources/catalog_seed_datasource.dart';
import 'package:hive/hive.dart';

import '../../../reports/data/datasources/custom_fields_local_datasource.dart';
import '../../../reports/data/datasources/elements_detail_local_datasource.dart';
import '../../../reports/data/datasources/elements_local_datasource.dart';
import '../../../reports/data/datasources/incident_types_local_datasource.dart';
import '../../../reports/data/datasources/report_elements_local_datasource.dart';
import '../../../reports/data/datasources/risk_levels_local_datasource.dart';
import '../../../reports/data/datasources/technical_location_datasource.dart';
import '../../../reports/domain/entities/custom_field.dart';
import '../../../reports/domain/entities/element.dart';
import '../../../reports/domain/entities/element_detail.dart';
import '../../../reports/domain/entities/incident_type.dart';
import '../../../reports/domain/entities/report_element.dart';
import '../../../reports/domain/entities/risk_level.dart';
import '../../../reports/domain/entities/technical_location.dart';
import '../datasources/sync_remote_datasource.dart';

import '../../../reports/data/datasources/reports_local_datasource.dart';
import '../../../reports/data/datasources/report_categories_local_datasource.dart';
import '../../../reports/domain/entities/report_type.dart';

class SyncRepository {
  final SyncRemoteDatasource remote;
  final ReportsLocalDatasource reportsLocal;
  final ReportCategoriesLocalDatasource categoriesLocal;
  final ReportElementsLocalDatasource elementsLocal;
  final CustomFieldsLocalDatasource customFieldsLocal;
  final RiskLevelsLocalDatasource riskLevelsLocal;
  final IncidentTypesLocalDatasource incidentTypesLocal;
  final ElementsLocalDatasource elementsCatalogLocal;
  final ElementDetailsLocalDatasource elementDetailsLocal;
  final TechnicalLocationsLocalDatasource technicalLocationsLocal;
  final CatalogSeedDatasource seedDatasource;
  SyncRepository(
      this.remote,
      this.reportsLocal,
      this.categoriesLocal,
      this.elementsLocal,
      this.customFieldsLocal,
      this.riskLevelsLocal,
      this.incidentTypesLocal,
      this.elementDetailsLocal,
      this.elementsCatalogLocal,
      this.technicalLocationsLocal,
      this.seedDatasource,
      );

  Future<void> syncAllCatalogs({
    required int unidadNegocioId,
    required String fechaActualizacion,
  }) async {
    await _seedLargeCatalogsIfNeeded();

    final metadataBox = await Hive.openBox('sync_metadata');

    final elementsSeedDate = metadataBox.get(
      'elements_seed_date',
      defaultValue: fechaActualizacion,
    );

    final elementDetailsSeedDate = metadataBox.get(
      'element_details_seed_date',
      defaultValue: fechaActualizacion,
    );

    final largeCatalogsSeedDate = metadataBox.get(
      'large_catalogs_seed_date',
      defaultValue: fechaActualizacion,
    );

    final reportsData = await remote.syncCatalog(
      endpoint: "catalogos/reportes",
      unidadNegocioId: unidadNegocioId,
      fechaActualizacion: fechaActualizacion,
    );

    final reportTypes = reportsData
        .map((e) => ReportType.fromJson(e))
        .toList();

    await reportsLocal.saveReportTypes(reportTypes);

    final reportElementsData = await remote.syncCatalog(
      endpoint: "catalogos/reportes-tipo-elemento",
      unidadNegocioId: unidadNegocioId,
      fechaActualizacion: fechaActualizacion,
    );

    final reportElements = reportElementsData
        .map((e) => ReportElement.fromJson(e))
        .toList();

    await elementsLocal.saveReportElements(reportElements);

    final customFieldsData = await remote.syncCatalog(
      endpoint: "catalogos/campos-personalizados",
      unidadNegocioId: unidadNegocioId,
      fechaActualizacion: fechaActualizacion,
    );

    final customFields = customFieldsData
        .map((e) => CustomField.fromJson(e))
        .toList();

    await customFieldsLocal.saveCustomFields(customFields);

    final riskLevelsData = await remote.syncCatalog(
      endpoint: "catalogos/niveles-riesgo",
      unidadNegocioId: unidadNegocioId,
      fechaActualizacion: fechaActualizacion,
    );

    final riskLevels = riskLevelsData
        .map((e) => RiskLevel.fromJson(e))
        .toList();

    await riskLevelsLocal.saveRiskLevels(riskLevels);

    final incidentTypesData = await remote.syncCatalog(
      endpoint: "catalogos/tipo-incidencia",
      unidadNegocioId: unidadNegocioId,
      fechaActualizacion: fechaActualizacion,
    );

    final incidentTypes = incidentTypesData
        .map((e) => IncidentType.fromJson(e))
        .toList();

    await incidentTypesLocal.saveIncidentTypes(incidentTypes);

    final elementosData = await remote.syncCatalog(
      endpoint: "catalogos/elementos",
      unidadNegocioId: unidadNegocioId,
      fechaActualizacion: elementsSeedDate,
    );

    final elementos = elementosData
        .map((e) => Elemento.fromJson(e))
        .toList();

    await elementsCatalogLocal.saveElements(elementos);

    final elementosDetallesData = await remote.syncCatalog(
      endpoint: "catalogos/elementos-detalles",
      unidadNegocioId: unidadNegocioId,
      fechaActualizacion: elementDetailsSeedDate,
    );

    final elementosDetalles = elementosDetallesData
        .map((e) => ElementoDetalle.fromJson(e))
        .toList();

    await elementDetailsLocal.saveElementDetails(elementosDetalles);

    final technicalLocationsData = await remote.syncCatalog(
      endpoint: "catalogos/ubicaciones-tecnicas",
      unidadNegocioId: unidadNegocioId,
      fechaActualizacion: fechaActualizacion,
    );

    final technicalLocations = technicalLocationsData
        .map((e) => TechnicalLocation.fromJson(e))
        .toList();

    await technicalLocationsLocal.saveTechnicalLocations(technicalLocations);

    print("SINCRONIZACIÓN COMPLETA");
  }

  Future<void> _seedLargeCatalogsIfNeeded() async {
    final metadataBox = await Hive.openBox('sync_metadata');

    final alreadySeeded = metadataBox.get(
      'large_catalogs_seeded',
      defaultValue: false,
    );

    if (alreadySeeded == true) {
      print("CATÁLOGOS PRECARGADOS: ya existen en Hive");
      return;
    }

    print("INICIANDO PRECARGA DE CATÁLOGOS");

    final stopwatch = Stopwatch()..start();

    // ELEMENTOS
    stopwatch.reset();

    final elements = await seedDatasource.loadElements();

    print(
      "SEED LOAD ELEMENTS: ${elements.length} registros "
          "en ${stopwatch.elapsedMilliseconds} ms",
    );

    stopwatch.reset();

    await elementsCatalogLocal.saveElements(elements);

    print(
      "SEED HIVE ELEMENTS: "
          "${stopwatch.elapsedMilliseconds} ms",
    );

    // ELEMENTOS DETALLE
    final detailFiles = [
      'assets/catalogs/element_details_1.json',
      'assets/catalogs/element_details_2.json',
      'assets/catalogs/element_details_3.json',
      'assets/catalogs/element_details_4.json',
    ];

    for (final file in detailFiles) {
      stopwatch.reset();

      final details =
      await seedDatasource.loadElementDetailsFile(file);

      print(
        "SEED LOAD [$file]: ${details.length} registros "
            "en ${stopwatch.elapsedMilliseconds} ms",
      );

      stopwatch.reset();

      await elementDetailsLocal.saveElementDetails(details);

      print(
        "SEED HIVE [$file]: "
            "${stopwatch.elapsedMilliseconds} ms",
      );
    }

    await metadataBox.put(
      'elements_seed_date',
      '2026-08-04 09:52:00.057',
    );

    await metadataBox.put(
      'element_details_seed_date',
      '2026-08-04 09:52:00.057',
    );

    await metadataBox.put(
      'large_catalogs_seeded',
      true,
    );

  }
}