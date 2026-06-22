// lib/screens/patients_list_screen.dart
// Liste des patients : recherche temps réel, Cards, swipe-to-delete, FAB.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/patients_provider.dart';
import '../widgets/carte_patient.dart';
import 'ajout_patient_screen.dart';
import 'fhir_screen.dart';
import 'patient_detail_screen.dart';

class PatientsListScreen extends StatefulWidget {
  const PatientsListScreen({super.key});

  @override
  State<PatientsListScreen> createState() => _PatientsListScreenState();
}

class _PatientsListScreenState extends State<PatientsListScreen> {
  final _rechercheController = TextEditingController();

  @override
  void dispose() {
    _rechercheController.dispose();
    super.dispose();
  }

  Future<void> _confirmerSuppression(String id, String nom) async {
    final provider = context.read<PatientsProvider>();
    final confirme = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer le patient'),
        content: Text(
          'Voulez-vous vraiment supprimer « $nom » ? '
          'Ses consultations seront également supprimées.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirme == true) {
      await provider.supprimerPatient(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('« $nom » supprimé.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PatientsProvider>();
    final patients = provider.patientsFiltres;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients'),
        actions: [
          IconButton(
            tooltip: 'Patients FHIR (serveur distant)',
            icon: const Icon(Icons.cloud_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FhirScreen()),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SearchBar(
              controller: _rechercheController,
              hintText: 'Rechercher un patient...',
              leading: const Icon(Icons.search),
              trailing: [
                if (_rechercheController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _rechercheController.clear();
                      provider.rechercher('');
                      setState(() {});
                    },
                  ),
              ],
              onChanged: (v) {
                provider.rechercher(v);
                setState(() {});
              },
            ),
          ),
        ),
      ),
      body: patients.isEmpty
          ? _EtatVide(recherche: _rechercheController.text)
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 88),
              itemCount: patients.length,
              itemBuilder: (context, i) {
                final patient = patients[i];
                return Dismissible(
                  key: ValueKey(patient.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    padding: const EdgeInsets.only(right: 24),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) async {
                    await _confirmerSuppression(
                        patient.id, patient.nomComplet);
                    return false; // suppression gérée manuellement
                  },
                  child: CartePatient(
                    patient: patient,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            PatientDetailScreen(patientId: patient.id),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AjoutPatientScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
    );
  }
}

class _EtatVide extends StatelessWidget {
  final String recherche;
  const _EtatVide({required this.recherche});

  @override
  Widget build(BuildContext context) {
    final aucunResultat = recherche.isNotEmpty;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            aucunResultat ? Icons.search_off : Icons.people_outline,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 12),
          Text(
            aucunResultat
                ? 'Aucun patient ne correspond à « $recherche »'
                : 'Aucun patient enregistré',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
