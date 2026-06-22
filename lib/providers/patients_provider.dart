// lib/providers/patients_provider.dart
// Gestion d'état centralisée des patients et de leurs consultations.
import 'package:flutter/foundation.dart';

import '../models/consultation.dart';
import '../models/patient.dart';
import '../services/fhir_service.dart';
import '../services/storage_service.dart';
import '../services/sync_service.dart';

class PatientsProvider extends ChangeNotifier {
  final StorageService _storage;
  final FhirService _fhir;
  final SyncService _sync;

  PatientsProvider(this._storage, this._fhir, this._sync);

  List<Patient> _patients = [];
  String _recherche = '';

  // --- État FHIR ---
  bool _chargementFhir = false;
  String? _erreurFhir;
  List<PatientFhir> _patientsFhir = [];

  // ----------------------- Getters -----------------------

  List<Patient> get tousLesPatients => _patients;

  /// Liste filtrée par la recherche en cours (par nom complet).
  List<Patient> get patientsFiltres {
    if (_recherche.trim().isEmpty) return _patients;
    final q = _recherche.toLowerCase();
    return _patients
        .where((p) => p.nomComplet.toLowerCase().contains(q))
        .toList();
  }

  int get nombrePatients => _patients.length;
  int get nombreUrgents =>
      _patients.where((p) => p.statut == 'urgent').length;
  int get nombreEnAttente =>
      _patients.where((p) => p.statut == 'attente').length;

  bool get chargementFhir => _chargementFhir;
  String? get erreurFhir => _erreurFhir;
  List<PatientFhir> get patientsFhir => _patientsFhir;

  List<Consultation> get dernieresConsultations =>
      _storage.dernieresConsultations();

  /// Toutes les consultations dont la date est postérieure à maintenant,
  /// triées de la plus proche à la plus lointaine.
  List<Consultation> get consultationsAVenir {
    final maintenant = DateTime.now();
    final liste = _storage
        .toutesLesConsultations()
        .where((c) => c.dateHeure.isAfter(maintenant))
        .toList();
    liste.sort((a, b) => a.dateHeure.compareTo(b.dateHeure));
    return liste;
  }

  // ----------------------- Chargement -----------------------

  Future<void> charger() async {
    _patients = _storage.toutLesPatients();
    _trier();
    notifyListeners();
  }

  void _trier() {
    // Urgents d'abord, puis attente, puis actifs ; tri alpha ensuite.
    int rang(String s) => s == 'urgent' ? 0 : (s == 'attente' ? 1 : 2);
    _patients.sort((a, b) {
      final r = rang(a.statut).compareTo(rang(b.statut));
      if (r != 0) return r;
      return a.nomComplet.compareTo(b.nomComplet);
    });
  }

  // ----------------------- Recherche -----------------------

  void rechercher(String texte) {
    _recherche = texte;
    notifyListeners();
  }

  // ----------------------- CRUD Patients -----------------------

  Future<void> ajouterPatient(Patient patient) async {
    await _storage.sauvegarderPatient(patient);
    _patients.add(patient);
    _trier();
    notifyListeners();
    // Synchronisation en arrière-plan.
    _sync.syncSiConnecte(patient);
  }

  Future<void> modifierPatient(Patient patient) async {
    await _storage.sauvegarderPatient(patient);
    await charger();
  }

  Future<void> supprimerPatient(String id) async {
    await _storage.supprimerPatient(id);
    _patients.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  Patient? patientParId(String id) => _storage.patientParId(id);

  // ----------------------- Consultations -----------------------

  List<Consultation> consultationsDuPatient(String patientId) =>
      _storage.consultationsDuPatient(patientId);

  Future<void> ajouterConsultation(Consultation consultation) async {
    await _storage.sauvegarderConsultation(consultation);
    // Met à jour la dernière visite du patient.
    final patient = _storage.patientParId(consultation.patientId);
    if (patient != null) {
      patient.derniereVisite = consultation.dateHeure;
      await _storage.sauvegarderPatient(patient);
    }
    await charger();
  }

  // ----------------------- FHIR -----------------------

  Future<void> chargerPatientsFhir() async {
    _chargementFhir = true;
    _erreurFhir = null;
    notifyListeners();

    try {
      _patientsFhir = await _fhir.recupererPatients();
    } on FhirException catch (e) {
      _erreurFhir = e.message;
      _patientsFhir = [];
    } catch (e) {
      _erreurFhir = 'Une erreur inattendue est survenue.';
      _patientsFhir = [];
    } finally {
      _chargementFhir = false;
      notifyListeners();
    }
  }
}
