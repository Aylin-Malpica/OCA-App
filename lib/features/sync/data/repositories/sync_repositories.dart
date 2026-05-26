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
import '../../../reports/domain/entities/report_category.dart';

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
      );

  Future<void> syncAllCatalogs({
    required int unidadNegocioId,
    required String fechaActualizacion,
  }) async {

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
      fechaActualizacion: fechaActualizacion,
    );

    final elementos = elementosData
        .map((e) => Elemento.fromJson(e))
        .toList();

    await elementsCatalogLocal.saveElements(elementos);

    final elementosDetallesData = await remote.syncCatalog(
      endpoint: "catalogos/elementos-detalles",
      unidadNegocioId: unidadNegocioId,
      fechaActualizacion: fechaActualizacion,
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
}