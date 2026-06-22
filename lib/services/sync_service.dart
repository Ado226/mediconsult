// lib/services/sync_service.dart
// Synchronisation des données locales non synchronisées vers le serveur FHIR.
// (Implémentation pédagogique : marque les éléments comme synchronisés
// lorsqu'une connexion est disponible.)
import 'package:connectivity_plus/connectivity_plus.dart';

import '../models/patient.dart';
import 'storage_service.dart';

class SyncService {
  final StorageService _storage;
  final Connectivity _connectivity = Connectivity();

  SyncService(this._storage);

  Future<bool> estConnecte() async {
    final resultats = await _connectivity.checkConnectivity();
    return !resultats.contains(ConnectivityResult.none);
  }

  /// Tente de synchroniser tous les patients non encore synchronisés.
  /// Retourne le nombre d'éléments synchronisés.
  Future<int> synchroniser() async {
    if (!await estConnecte()) return 0;

    var compteur = 0;
    final nonSync =
        _storage.toutLesPatients().where((p) => !p.estSynchronise);

    for (final patient in nonSync) {
      // Ici se ferait un POST/PUT FHIR réel. On simule la réussite.
      await _marquerSynchronise(patient);
      compteur++;
    }
    return compteur;
  }

  Future<void> _marquerSynchronise(Patient patient) async {
    patient.estSynchronise = true;
    await _storage.sauvegarderPatient(patient);
  }

  /// Synchronisation d'arrière-plan, déclenchée après un ajout.
  Future<void> syncSiConnecte(Patient patient) async {
    if (await estConnecte()) {
      await _marquerSynchronise(patient);
    }
  }
}
