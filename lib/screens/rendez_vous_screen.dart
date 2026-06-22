// lib/screens/rendez_vous_screen.dart
// Rendez-vous : liste des consultations à venir + démonstration de
// notification locale (flutter_local_notifications).
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import '../models/consultation.dart';
import '../providers/patients_provider.dart';

class RendezVousScreen extends StatelessWidget {
  const RendezVousScreen({super.key});

  /// Instance partagée du plugin de notifications.
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// Initialise le plugin de notifications (appelé depuis main.dart).
  static Future<void> initNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _notifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  Future<void> _notifierRappel(BuildContext context) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'rappels_rdv',
        'Rappels de rendez-vous',
        channelDescription: 'Notifications de rappel des consultations',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    try {
      await _notifications.show(
        0,
        'MediConsult — Rappel',
        'Vous avez une consultation à venir.',
        details,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification de rappel envoyée.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notifications non disponibles sur cette plateforme.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PatientsProvider>();

    // Rendez-vous = consultations dont la date est dans le futur.
    final aVenir = provider.consultationsAVenir;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rendez-vous'),
        actions: [
          IconButton(
            tooltip: 'Tester un rappel',
            icon: const Icon(Icons.notifications_active_outlined),
            onPressed: () => _notifierRappel(context),
          ),
        ],
      ),
      body: aVenir.isEmpty
          ? const _AucunRdv()
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: aVenir.length,
              itemBuilder: (context, i) =>
                  _CarteRdv(consultation: aVenir[i], provider: provider),
            ),
    );
  }
}

class _CarteRdv extends StatelessWidget {
  final Consultation consultation;
  final PatientsProvider provider;

  const _CarteRdv({required this.consultation, required this.provider});

  @override
  Widget build(BuildContext context) {
    final patient = provider.patientParId(consultation.patientId);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: const Icon(Icons.event, color: Colors.blue),
        ),
        title: Text(patient?.nomComplet ?? 'Patient inconnu'),
        subtitle: Text('${consultation.motif}\n${consultation.dateHeureFormatee}'),
        isThreeLine: true,
      ),
    );
  }
}

class _AucunRdv extends StatelessWidget {
  const _AucunRdv();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Text(
            'Aucun rendez-vous à venir',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Créez une consultation avec une date future depuis la fiche '
              'd\'un patient pour la voir apparaître ici.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
