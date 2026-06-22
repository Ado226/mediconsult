// lib/screens/patient_detail_screen.dart
// Fiche patient détaillée avec onglets : Infos, Consultations, Rendez-vous.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/consultation.dart';
import '../models/patient.dart';
import '../providers/patients_provider.dart';

class PatientDetailScreen extends StatelessWidget {
  final String patientId;

  const PatientDetailScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PatientsProvider>();
    final patient = provider.patientParId(patientId);

    if (patient == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Patient')),
        body: const Center(child: Text('Patient introuvable.')),
      );
    }

    final consultations = provider.consultationsDuPatient(patientId);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(patient.nomComplet),
                background: _Entete(patient: patient),
              ),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Infos'),
                  Tab(text: 'Consultations'),
                  Tab(text: 'Rendez-vous'),
                ],
              ),
            ),
          ],
          body: TabBarView(
            children: [
              _OngletInfos(patient: patient),
              _OngletConsultations(consultations: consultations),
              const _OngletRendezVous(),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _nouvelleConsultation(context, patient),
          icon: const Icon(Icons.add),
          label: const Text('Consultation'),
        ),
      ),
    );
  }

  Future<void> _nouvelleConsultation(
      BuildContext context, Patient patient) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FormulaireConsultation(patient: patient),
    );
  }
}

// ----------------------- En-tête -----------------------

class _Entete extends StatelessWidget {
  final Patient patient;
  const _Entete({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            patient.couleurStatut.withValues(alpha: 0.7),
            Theme.of(context).colorScheme.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const SizedBox.expand(),
    );
  }
}

// ----------------------- Onglet Infos -----------------------

class _OngletInfos extends StatelessWidget {
  final Patient patient;
  const _OngletInfos({required this.patient});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: patient.couleurStatut.withValues(alpha: 0.15),
                child: Text(
                  patient.initiales,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: patient.couleurStatut,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Chip(
                label: Text(patient.libelleStatut),
                backgroundColor: patient.couleurStatut.withValues(alpha: 0.15),
                labelStyle: TextStyle(color: patient.couleurStatut),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _ligne(Icons.cake_outlined, 'Âge', '${patient.age} ans'),
        _ligne(Icons.event, 'Date de naissance',
            patient.derniereVisiteFormatee == 'Aucune visite'
                ? '${patient.dateNaissance.day}/${patient.dateNaissance.month}/${patient.dateNaissance.year}'
                : '${patient.dateNaissance.day}/${patient.dateNaissance.month}/${patient.dateNaissance.year}'),
        _ligne(Icons.phone_outlined, 'Téléphone',
            patient.telephone.isEmpty ? 'Non renseigné' : patient.telephone),
        _ligne(Icons.bloodtype_outlined, 'Groupe sanguin',
            patient.groupeSanguin),
        _ligne(Icons.event_available, 'Dernière visite',
            patient.derniereVisiteFormatee),
        const SizedBox(height: 8),
        const Divider(),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Antécédents médicaux',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Text(
          patient.antecedents.isEmpty
              ? 'Aucun antécédent renseigné.'
              : patient.antecedents,
        ),
      ],
    );
  }

  Widget _ligne(IconData icone, String titre, String valeur) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icone, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Text('$titre : ', style: const TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(valeur,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

// ----------------------- Onglet Consultations -----------------------

class _OngletConsultations extends StatelessWidget {
  final List<Consultation> consultations;
  const _OngletConsultations({required this.consultations});

  @override
  Widget build(BuildContext context) {
    if (consultations.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Aucune consultation enregistrée.\n'
            'Appuyez sur « Consultation » pour en ajouter une.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: consultations.length,
      itemBuilder: (context, i) {
        final c = consultations[i];
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            leading: const CircleAvatar(child: Icon(Icons.event_note)),
            title: Text(c.motif),
            subtitle: Text(c.dateHeureFormatee),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              _bloc('Diagnostic', c.diagnostic),
              _bloc('Traitement prescrit', c.traitement),
              _bloc('Note du médecin', c.noteMedecin),
            ],
          ),
        );
      },
    );
  }

  Widget _bloc(String titre, String contenu) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titre,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(contenu.isEmpty ? 'Non renseigné' : contenu),
          ],
        ),
      ),
    );
  }
}

// ----------------------- Onglet Rendez-vous -----------------------

class _OngletRendezVous extends StatelessWidget {
  const _OngletRendezVous();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'La prise de rendez-vous se gère depuis l\'onglet « Rendez-vous » '
          'de l\'écran principal.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}

// ----------------------- Formulaire Consultation -----------------------

class _FormulaireConsultation extends StatefulWidget {
  final Patient patient;
  const _FormulaireConsultation({required this.patient});

  @override
  State<_FormulaireConsultation> createState() =>
      _FormulaireConsultationState();
}

class _FormulaireConsultationState extends State<_FormulaireConsultation> {
  final _formKey = GlobalKey<FormState>();
  final _motifController = TextEditingController();
  final _diagnosticController = TextEditingController();
  final _traitementController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _dateHeure = DateTime.now();

  @override
  void dispose() {
    _motifController.dispose();
    _diagnosticController.dispose();
    _traitementController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _choisirDateHeure() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateHeure,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('fr', 'FR'),
    );
    if (date == null || !mounted) return;

    final heure = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateHeure),
    );
    if (heure == null) return;

    setState(() {
      _dateHeure = DateTime(
        date.year,
        date.month,
        date.day,
        heure.hour,
        heure.minute,
      );
    });
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;

    final consultation = Consultation.complete(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: widget.patient.id,
      dateHeure: _dateHeure,
      motif: _motifController.text.trim(),
      diagnostic: _diagnosticController.text.trim(),
      traitement: _traitementController.text.trim(),
      noteMedecin: _noteController.text.trim(),
    );

    await context.read<PatientsProvider>().ajouterConsultation(consultation);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Consultation enregistrée.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateTexte =
        '${_dateHeure.day}/${_dateHeure.month}/${_dateHeure.year} à '
        '${_dateHeure.hour}h${_dateHeure.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Nouvelle consultation',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                widget.patient.nomComplet,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Date et heure.
              InkWell(
                onTap: _choisirDateHeure,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date et heure',
                    prefixIcon: Icon(Icons.schedule),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(dateTexte),
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _motifController,
                decoration: const InputDecoration(
                  labelText: 'Motif de consultation *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Le motif est obligatoire'
                    : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _diagnosticController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Diagnostic',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _traitementController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Ordonnance / traitement prescrit',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Note du médecin',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _enregistrer,
                  icon: const Icon(Icons.save),
                  label: const Text('Enregistrer'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
