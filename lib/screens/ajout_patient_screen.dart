// lib/screens/ajout_patient_screen.dart
// Formulaire de saisie d'un nouveau patient avec validation complète.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/patient.dart';
import '../providers/patients_provider.dart';

class AjoutPatientScreen extends StatefulWidget {
  const AjoutPatientScreen({super.key});

  @override
  State<AjoutPatientScreen> createState() => _AjoutPatientScreenState();
}

class _AjoutPatientScreenState extends State<AjoutPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _antecedentsController = TextEditingController();

  static const _groupes = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

  DateTime? _dateNaissance;
  String _groupeSanguin = 'O+';
  String _statut = 'actif';

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _antecedentsController.dispose();
    super.dispose();
  }

  Future<void> _choisirDate() async {
    final maintenant = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(maintenant.year - 30),
      firstDate: DateTime(1900),
      lastDate: maintenant,
      helpText: 'Date de naissance',
      locale: const Locale('fr', 'FR'),
    );
    if (date != null) setState(() => _dateNaissance = date);
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dateNaissance == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez choisir la date de naissance')),
      );
      return;
    }

    final patient = Patient.complet(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nom: _nomController.text.trim(),
      prenom: _prenomController.text.trim(),
      dateNaissance: _dateNaissance!,
      telephone: _telephoneController.text.trim(),
      groupeSanguin: _groupeSanguin,
      antecedents: _antecedentsController.text.trim(),
      statut: _statut,
    );

    await context.read<PatientsProvider>().ajouterPatient(patient);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Patient « ${patient.nomComplet} » ajouté.')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un patient')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Prénom.
            TextFormField(
              controller: _prenomController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Prénom *',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Le prénom est obligatoire'
                  : null,
            ),
            const SizedBox(height: 16),

            // Nom.
            TextFormField(
              controller: _nomController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nom *',
                prefixIcon: Icon(Icons.badge_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Le nom est obligatoire'
                  : null,
            ),
            const SizedBox(height: 16),

            // Date de naissance.
            InkWell(
              onTap: _choisirDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date de naissance *',
                  prefixIcon: Icon(Icons.cake_outlined),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _dateNaissance == null
                      ? 'Sélectionner une date'
                      : DateFormat('dd/MM/yyyy').format(_dateNaissance!),
                  style: TextStyle(
                    color: _dateNaissance == null
                        ? Colors.grey
                        : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Téléphone.
            TextFormField(
              controller: _telephoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Numéro de téléphone',
                prefixIcon: Icon(Icons.phone_outlined),
                border: OutlineInputBorder(),
                hintText: '+226 70 00 00 00',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                if (v.trim().length < 8) {
                  return 'Numéro trop court';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Groupe sanguin.
            DropdownButtonFormField<String>(
              initialValue: _groupeSanguin,
              decoration: const InputDecoration(
                labelText: 'Groupe sanguin',
                prefixIcon: Icon(Icons.bloodtype_outlined),
                border: OutlineInputBorder(),
              ),
              items: _groupes
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (v) => setState(() => _groupeSanguin = v!),
            ),
            const SizedBox(height: 16),

            // Statut.
            DropdownButtonFormField<String>(
              initialValue: _statut,
              decoration: const InputDecoration(
                labelText: 'Statut',
                prefixIcon: Icon(Icons.flag_outlined),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'actif', child: Text('Actif')),
                DropdownMenuItem(value: 'attente', child: Text('En attente')),
                DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
              ],
              onChanged: (v) => setState(() => _statut = v!),
            ),
            const SizedBox(height: 16),

            // Antécédents médicaux.
            TextFormField(
              controller: _antecedentsController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Antécédents médicaux',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.medical_information_outlined),
                border: OutlineInputBorder(),
                hintText: 'Allergies, pathologies chroniques, traitements...',
              ),
            ),
            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _enregistrer,
              icon: const Icon(Icons.save),
              label: const Text('Enregistrer le patient'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
