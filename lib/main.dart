// lib/main.dart
// Point d'entrée : initialise le stockage chiffré, les notifications,
// la localisation FR, insère les données de test, puis lance l'application.
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'models/patient.dart';
import 'providers/auth_provider.dart';
import 'providers/patients_provider.dart';
import 'screens/rendez_vous_screen.dart';
import 'services/auth_service.dart';
import 'services/fhir_service.dart';
import 'services/storage_service.dart';
import 'services/sync_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Localisation française pour le formatage des dates.
  await initializeDateFormatting('fr_FR', null);

  // Stockage local chiffré (Hive + AES).
  final storage = StorageService();
  await storage.init();

  // Insère des données de démonstration si la base est vide.
  await _seedDonneesTest(storage);

  // Notifications locales.
  await RendezVousScreen.initNotifications();

  // Services et providers.
  final authService = AuthService();
  final fhirService = FhirService();
  final syncService = SyncService(storage);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
        ChangeNotifierProvider(
          create: (_) =>
              PatientsProvider(storage, fhirService, syncService)..charger(),
        ),
      ],
      child: const MediConsultApp(),
    ),
  );
}

/// Insère 5 patients fictifs au premier lancement.
Future<void> _seedDonneesTest(StorageService storage) async {
  if (!storage.estVide) return;

  final maintenant = DateTime.now();
  DateTime ne(int age) => DateTime(maintenant.year - age, 5, 15);

  final patients = [
    Patient.complet(
      id: 'p1',
      nom: 'Sawadogo',
      prenom: 'Aminata',
      dateNaissance: ne(34),
      telephone: '+226 70 11 22 33',
      groupeSanguin: 'A+',
      antecedents: 'Diabète de type 2 sous metformine.',
      statut: 'actif',
      derniereVisite: maintenant.subtract(const Duration(days: 5)),
    ),
    Patient.complet(
      id: 'p2',
      nom: 'Kaboré',
      prenom: 'Moussa',
      dateNaissance: ne(58),
      telephone: '+226 76 44 55 66',
      groupeSanguin: 'O-',
      antecedents: 'Hypertension artérielle sévère. Antécédent d\'AVC.',
      statut: 'urgent',
      derniereVisite: maintenant.subtract(const Duration(days: 1)),
    ),
    Patient.complet(
      id: 'p3',
      nom: 'Traoré',
      prenom: 'Fatoumata',
      dateNaissance: ne(45),
      telephone: '+226 78 77 88 99',
      groupeSanguin: 'B+',
      antecedents: 'Asthme allergique.',
      statut: 'attente',
      derniereVisite: maintenant.subtract(const Duration(days: 20)),
    ),
    Patient.complet(
      id: 'p4',
      nom: 'Ouédraogo',
      prenom: 'Ibrahim',
      dateNaissance: ne(67),
      telephone: '+226 71 00 11 22',
      groupeSanguin: 'AB+',
      antecedents: 'Insuffisance rénale chronique stade 3.',
      statut: 'actif',
      derniereVisite: maintenant.subtract(const Duration(days: 12)),
    ),
    Patient.complet(
      id: 'p5',
      nom: 'Diallo',
      prenom: 'Mariam',
      dateNaissance: ne(29),
      telephone: '+226 75 33 44 55',
      groupeSanguin: 'A-',
      antecedents: 'Aucun antécédent notable.',
      statut: 'actif',
      derniereVisite: maintenant.subtract(const Duration(days: 40)),
    ),
  ];

  for (final p in patients) {
    await storage.sauvegarderPatient(p);
  }
}
