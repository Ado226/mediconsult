// lib/screens/fhir_screen.dart
// Écran dédié à l'affichage des patients récupérés depuis le serveur FHIR.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/patients_provider.dart';

class FhirScreen extends StatefulWidget {
  const FhirScreen({super.key});

  @override
  State<FhirScreen> createState() => _FhirScreenState();
}

class _FhirScreenState extends State<FhirScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientsProvider>().chargerPatientsFhir();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PatientsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients FHIR (HAPI R4)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: provider.chargementFhir
                ? null
                : () => provider.chargerPatientsFhir(),
          ),
        ],
      ),
      body: _construireCorps(provider),
    );
  }

  Widget _construireCorps(PatientsProvider provider) {
    if (provider.chargementFhir) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Connexion au serveur FHIR...'),
          ],
        ),
      );
    }

    if (provider.erreurFhir != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                provider.erreurFhir!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => provider.chargerPatientsFhir(),
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    final liste = provider.patientsFhir;
    if (liste.isEmpty) {
      return const Center(child: Text('Aucun patient FHIR récupéré.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: liste.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, i) {
        final p = liste[i];
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade50,
              child: const Icon(Icons.person, color: Colors.blue),
            ),
            title: Text(p.nomComplet),
            subtitle: Text(
              'Genre : ${p.genre} • Naissance : ${p.dateNaissance}',
            ),
            trailing: Text(
              'ID ${p.id}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }
}
