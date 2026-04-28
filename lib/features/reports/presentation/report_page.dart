import 'package:flutter/material.dart';

import '../../../../core/app_theme.dart';
import '../../login/domain/entities/user.dart';
import '../data/datasources/reports_local_datasource.dart';
import '../domain/entities/report_type.dart';
import 'report_form_page.dart';

class ReportsPage extends StatefulWidget {
  final User user;

  const ReportsPage({
    super.key,
    required this.user,
  });

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final ReportsLocalDatasource local = ReportsLocalDatasource();

  List<ReportType> reports = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  Future<void> loadReports() async {
    try {
      final data = await local.getActiveReportTypes();

      if (!mounted) return;

      setState(() {
        reports = data;
        loading = false;
      });
    } catch (e) {
      print("ERROR LOAD LOCAL REPORTS: $e");

      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  Future<void> openReportForm(ReportType report) async {
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportFormPage(
          user: widget.user,
          report: report,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Generar reporte"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: loading
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : Column(
          children: [
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      child: Icon(Icons.assessment),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        "MÓDULO DE REPORTES",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            Expanded(
              child: reports.isEmpty
                  ? const Center(
                child: Text(
                  "No hay tipos de reporte sincronizados",
                ),
              )
                  : ListView.separated(
                itemCount: reports.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 18),
                itemBuilder: (context, index) {
                  final report = reports[index];

                  return _reportCard(
                    context: context,
                    title: report.titulo,
                    subtitle: report.tipoReporte,
                    onTap: () {
                      openReportForm(report);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _reportCard({
  required BuildContext context,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppTheme.tulipanes.withOpacity(0.15),
                child: Icon(
                  Icons.description_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 10),
          const Text(
            "Descripción",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Genera el formulario correspondiente para $title.",
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.arrow_forward),
              label: const Text("Generar reporte"),

            ),
          ),
        ],
      ),
    ),
  );
}