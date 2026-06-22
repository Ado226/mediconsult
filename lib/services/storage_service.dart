// lib/services/storage_service.dart
// Stockage local CHIFFRÉ avec Hive + AES.
// La clé AES (256 bits) est générée une seule fois puis conservée dans
// le coffre-fort sécurisé du système (flutter_secure_storage).
import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/consultation.dart';
import '../models/patient.dart';

class StorageService {
  static const String _cleAesStorageKey = 'hive_aes_key';
  static const String _boxPatients = 'patients';
  static const String _boxConsultations = 'consultations';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  late Box<Patient> _patientsBox;
  late Box<Consultation> _consultationsBox;

  bool _initialise = false;

  /// Initialise Hive, enregistre les adaptateurs et ouvre les box chiffrées.
  Future<void> init() async {
    if (_initialise) return;

    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PatientAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ConsultationAdapter());
    }

    final cipher = HiveAesCipher(await _obtenirCleChiffrement());

    _patientsBox = await Hive.openBox<Patient>(
      _boxPatients,
      encryptionCipher: cipher,
    );
    _consultationsBox = await Hive.openBox<Consultation>(
      _boxConsultations,
      encryptionCipher: cipher,
    );

    _initialise = true;
  }

  /// Récupère la clé AES depuis le stockage sécurisé, ou en génère une.
  Future<List<int>> _obtenirCleChiffrement() async {
    final existante = await _secureStorage.read(key: _cleAesStorageKey);
    if (existante != null) {
      return base64Url.decode(existante);
    }
    // Génère une nouvelle clé AES 256 bits (32 octets).
    final cle = _genererCleAes();
    await _secureStorage.write(
      key: _cleAesStorageKey,
      value: base64Url.encode(cle),
    );
    return cle;
  }

  List<int> _genererCleAes() {
    final rng = Random.secure();
    return List<int>.generate(32, (_) => rng.nextInt(256));
  }

  // ---------------------- CRUD Patients ----------------------

  List<Patient> toutLesPatients() => _patientsBox.values.toList();

  Patient? patientParId(String id) {
    try {
      return _patientsBox.values.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> sauvegarderPatient(Patient patient) async {
    await _patientsBox.put(patient.id, patient);
  }

  Future<void> supprimerPatient(String id) async {
    await _patientsBox.delete(id);
    // Supprime aussi les consultations rattachées.
    final aSupprimer = _consultationsBox.values
        .where((c) => c.patientId == id)
        .map((c) => c.id)
        .toList();
    for (final cid in aSupprimer) {
      await _consultationsBox.delete(cid);
    }
  }

  bool get estVide => _patientsBox.isEmpty;

  // -------------------- CRUD Consultations --------------------

  List<Consultation> toutesLesConsultations() =>
      _consultationsBox.values.toList();

  /// Consultations d'un patient, triées de la plus récente à la plus ancienne.
  List<Consultation> consultationsDuPatient(String patientId) {
    final liste = _consultationsBox.values
        .where((c) => c.patientId == patientId)
        .toList();
    liste.sort((a, b) => b.dateHeure.compareTo(a.dateHeure));
    return liste;
  }

  Future<void> sauvegarderConsultation(Consultation consultation) async {
    await _consultationsBox.put(consultation.id, consultation);
  }

  Future<void> supprimerConsultation(String id) async {
    await _consultationsBox.delete(id);
  }

  /// Les 3 dernières consultations, tous patients confondus.
  List<Consultation> dernieresConsultations({int limite = 3}) {
    final liste = toutesLesConsultations();
    liste.sort((a, b) => b.dateHeure.compareTo(a.dateHeure));
    return liste.take(limite).toList();
  }

  Future<void> fermer() async {
    await _patientsBox.close();
    await _consultationsBox.close();
    _initialise = false;
  }
}
