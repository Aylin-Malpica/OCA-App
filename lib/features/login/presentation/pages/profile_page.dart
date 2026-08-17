import 'package:flutter/material.dart';
import '../../../../core/app_theme.dart';
import '../../domain/entities/user.dart';

class ProfilePage extends StatefulWidget {
  final User user;
  final String unidadNegocio;
  final String lastSync;

  final Future<bool> Function(String correo, String telefono)? onSaveContact;

  const ProfilePage({
    super.key,
    required this.user,
    required this.unidadNegocio,
    required this.lastSync,
    this.onSaveContact,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _correoController;
  late final TextEditingController _telefonoController;

  bool editingContact = false;
  bool saving = false;

  late String _correoActual;
  String _telefonoActual = '';

  bool get correoFaltante => _correoActual.trim().isEmpty;

  @override
  void initState() {
    super.initState();
    _correoActual = widget.user.correo;
    _correoController = TextEditingController(text: widget.user.correo);
    _telefonoController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _correoController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  String? _validateCorreo(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Ingresa un correo';
    final regex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(v)) return 'Correo inválido';
    return null;
  }

  String? _validateTelefono(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return 'Número inválido';
    return null;
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => saving = true);

    try {
      final ok = widget.onSaveContact == null
          ? true
          : await widget.onSaveContact!(
        _correoController.text.trim(),
        _telefonoController.text.trim(),
      );

      if (!mounted) return;

      if (ok) {
        setState(() {
          _correoActual = _correoController.text.trim();
          _telefonoActual = _telefonoController.text.trim();
          editingContact = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datos actualizados')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo guardar, intenta de nuevo')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Widget _card(String title, Widget child, {IconData? icon}) {
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
                    child: Icon(icon, size: 20, color: AppTheme.dorado),
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

  Widget _infoRow({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.dorado),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14.5,
              color: AppTheme.marBaltico,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _headerCard() {
    return Card(
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
        child: Row(
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: AppTheme.dorado.withOpacity(0.15),
              child: const Icon(
                Icons.person,
                size: 34,
                color: AppTheme.dorado,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.nombreCompleto,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.marBaltico,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    correoFaltante ? 'Sin correo registrado' : _correoActual,
                    style: TextStyle(
                      color: correoFaltante
                          ? Colors.red.shade400
                          : AppTheme.textColor,
                      fontStyle:
                      correoFaltante ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _generalInfoCard() {
    return _card(
      'Información general',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(
            icon: Icons.badge,
            text: 'No. empleado: ${widget.user.nombreUsuario}',
          ),
          const SizedBox(height: 12),
          _infoRow(
            icon: Icons.apartment,
            text: 'Departamento: ${widget.user.departamento}',
          ),
          const SizedBox(height: 12),
          _infoRow(
            icon: Icons.location_on,
            text: 'Ubicación técnica: ${widget.user.ubicacionTecnica}',
          ),
          const SizedBox(height: 12),
          _infoRow(
            icon: Icons.business,
            text: 'Unidad de negocio: ${widget.unidadNegocio}',
          ),
        ],
      ),
      icon: Icons.description_outlined,
    );
  }

  Widget _contactCard() {
    return _card(
      'Datos de contacto',
      Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!editingContact) ...[
              _infoRow(
                icon: Icons.email_outlined,
                text: correoFaltante
                    ? 'Correo: sin registrar'
                    : 'Correo: $_correoActual',
              ),
              const SizedBox(height: 12),
              _infoRow(
                icon: Icons.phone_outlined,
                text: _telefonoActual.isEmpty
                    ? 'Teléfono: sin registrar'
                    : 'Teléfono: $_telefonoActual',
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.dorado,
                    side: BorderSide(color: AppTheme.dorado.withOpacity(0.6)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => setState(() => editingContact = true),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: Text(
                    correoFaltante ? 'Agregar datos' : 'Editar datos',
                  ),
                ),
              ),
            ] else ...[
              TextFormField(
                controller: _correoController,
                keyboardType: TextInputType.emailAddress,
                validator: _validateCorreo,
                decoration: InputDecoration(
                  labelText: 'Correo',
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: AppTheme.dorado.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.dorado.withOpacity(0.30),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _telefonoController,
                keyboardType: TextInputType.phone,
                validator: _validateTelefono,
                decoration: InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  filled: true,
                  fillColor: AppTheme.dorado.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.dorado.withOpacity(0.30),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: saving
                          ? null
                          : () => setState(() => editingContact = false),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.dorado,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: saving ? null : _saveContact,
                      icon: saving
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Icon(Icons.check, size: 18),
                      label: const Text('Guardar'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      icon: Icons.contact_mail_outlined,
    );
  }

  Widget _syncCard() {
    return _card(
      'Última sincronización',
      _infoRow(icon: Icons.sync, text: widget.lastSync),
      icon: Icons.sync,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _headerCard(),
          const SizedBox(height: 14),
          _generalInfoCard(),
          const SizedBox(height: 14),
          _contactCard(),
          const SizedBox(height: 14),
          _syncCard(),
        ],
      ),
    );
  }
}