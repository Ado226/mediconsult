// lib/screens/dashboard_screen.dart
// Tableau de bord adapté au rôle (médecin / patient).
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/patients_provider.dart';
import 'patient_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<PatientsProvider>().charger(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: auth.estMedecin
              ? const _DashboardMedecin()
              : const _DashboardPatient(),
        ),
      ),
    );
  }
}

// ----------------------- Vue médecin -----------------------

class _DashboardMedecin extends StatelessWidget {
  const _DashboardMedecin();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PatientsProvider>();
    final consultations = provider.dernieresConsultations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vue d\'ensemble',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Cartes statistiques.
        Row(
          children: [
            _CarteStat(
              titre: 'Patients',
              valeur: '${provider.nombrePatients}',
              icone: Icons.people,
              couleur: Colors.blue,
            ),
            const SizedBox(width: 12),
            _CarteStat(
              titre: 'En attente',
              valeur: '${provider.nombreEnAttente}',
              icone: Icons.hourglass_bottom,
              couleur: Colors.orange,
            ),
            const SizedBox(width: 12),
            _CarteStat(
              titre: 'Urgents',
              valeur: '${provider.nombreUrgents}',
              icone: Icons.warning_amber_rounded,
              couleur: Colors.red,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Graphique : répartition des statuts.
        Text(
          'Répartition des patients',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: _GraphiqueStatuts(
            actifs: provider.nombrePatients -
                provider.nombreEnAttente -
                provider.nombreUrgents,
            attente: provider.nombreEnAttente,
            urgents: provider.nombreUrgents,
          ),
        ),
        const SizedBox(height: 24),

        // Dernières consultations.
        Text(
          'Dernières consultations',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        if (consultations.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('Aucune consultation enregistrée pour le moment.'),
          )
        else
          ...consultations.map((c) {
            final patient = provider.patientParId(c.patientId);
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.event_note)),
                title: Text(patient?.nomComplet ?? 'Patient inconnu'),
                subtitle: Text('${c.motif} • ${c.dateHeureFormatee}'),
                onTap: patient == null
                    ? null
                    : () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                PatientDetailScreen(patientId: patient.id),
                          ),
                        ),
              ),
            );
          }),
      ],
    );
  }
}

// ----------------------- Vue patient -----------------------

class _DashboardPatient extends StatelessWidget {
  const _DashboardPatient();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête de bienvenue.
        Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
              child: Icon(Icons.waving_hand_outlined,
                  color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bonjour,',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    auth.email ?? 'Patient',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.outline),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: const ListTile(
            leading: CircleAvatar(child: Icon(Icons.event_available)),
            title: Text('Ma prochaine consultation'),
            subtitle: Text('Aucun rendez-vous planifié pour l\'instant'),
          ),
        ),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: const ListTile(
            leading: CircleAvatar(child: Icon(Icons.history)),
            title: Text('Mon historique de visites'),
            subtitle: Text('Consultez vos consultations passées'),
          ),
        ),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: const ListTile(
            leading: CircleAvatar(child: Icon(Icons.favorite_border)),
            title: Text('Mon profil médical'),
            subtitle: Text('Groupe sanguin, antécédents, allergies'),
          ),
        ),
      ],
    );
  }
}

// ----------------------- Composants -----------------------

class _CarteStat extends StatelessWidget {
  final String titre;
  final String valeur;
  final IconData icone;
  final Color couleur;

  const _CarteStat({
    required this.titre,
    required this.valeur,
    required this.icone,
    required this.couleur,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: couleur.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: couleur.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: couleur.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(icone, color: couleur, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              valeur,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: couleur,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              titre,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _GraphiqueStatuts extends StatelessWidget {
  final int actifs;
  final int attente;
  final int urgents;

  const _GraphiqueStatuts({
    required this.actifs,
    required this.attente,
    required this.urgents,
  });

  @override
  Widget build(BuildContext context) {
    final total = actifs + attente + urgents;
    if (total == 0) {
      return const Center(child: Text('Aucune donnée à afficher'));
    }

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 36,
              sections: [
                PieChartSectionData(
                  value: actifs.toDouble(),
                  color: Colors.green,
                  title: '$actifs',
                  radius: 48,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PieChartSectionData(
                  value: attente.toDouble(),
                  color: Colors.orange,
                  title: '$attente',
                  radius: 48,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PieChartSectionData(
                  value: urgents.toDouble(),
                  color: Colors.red,
                  title: '$urgents',
                  radius: 48,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _Legende(couleur: Colors.green, texte: 'Actifs'),
            SizedBox(height: 8),
            _Legende(couleur: Colors.orange, texte: 'En attente'),
            SizedBox(height: 8),
            _Legende(couleur: Colors.red, texte: 'Urgents'),
          ],
        ),
      ],
    );
  }
}

class _Legende extends StatelessWidget {
  final Color couleur;
  final String texte;

  const _Legende({required this.couleur, required this.texte});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, color: couleur),
        const SizedBox(width: 6),
        Text(texte),
      ],
    );
  }
}
