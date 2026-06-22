// lib/services/fhir_service.dart
// Appels API REST vers un serveur FHIR public de test (HAPI FHIR R4).
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

/// Représentation allégée d'une ressource Patient FHIR.
class PatientFhir {
  final String id;
  final String nomComplet;
  final String genre;
  final String dateNaissance;

  PatientFhir({
    required this.id,
    required this.nomComplet,
    required this.genre,
    required this.dateNaissance,
  });
}

/// Exception métier pour les erreurs réseau / API.
class FhirException implements Exception {
  final String message;
  FhirException(this.message);
  @override
  String toString() => message;
}

class FhirService {
  static const String _baseUrl = 'https://hapi.fhir.org/baseR4';
  static const Duration _timeout = Duration(seconds: 15);

  final Connectivity _connectivity = Connectivity();

  /// Vérifie qu'une connexion réseau est disponible.
  Future<bool> estConnecte() async {
    final resultats = await _connectivity.checkConnectivity();
    return !resultats.contains(ConnectivityResult.none);
  }

  /// GET /Patient — récupère une liste de patients depuis le serveur FHIR.
  Future<List<PatientFhir>> recupererPatients({int nombre = 20}) async {
    if (!await estConnecte()) {
      throw FhirException('Aucune connexion réseau disponible.');
    }

    final uri = Uri.parse('$_baseUrl/Patient?_count=$nombre');

    try {
      final reponse = await http.get(
        uri,
        headers: {'Accept': 'application/fhir+json'},
      ).timeout(_timeout);

      if (reponse.statusCode != 200) {
        throw FhirException(
          'Erreur serveur FHIR (code ${reponse.statusCode}).',
        );
      }

      final Map<String, dynamic> bundle = json.decode(reponse.body);
      final List<dynamic> entries = bundle['entry'] ?? [];

      return entries
          .map((e) => _parserPatient(e['resource'] as Map<String, dynamic>))
          .toList();
    } on FhirException {
      rethrow;
    } catch (e) {
      throw FhirException('Échec de la requête : délai dépassé ou erreur réseau.');
    }
  }

  PatientFhir _parserPatient(Map<String, dynamic> resource) {
    final id = resource['id']?.toString() ?? 'inconnu';

    String nom = 'Nom inconnu';
    final names = resource['name'] as List<dynamic>?;
    if (names != null && names.isNotEmpty) {
      final premier = names.first as Map<String, dynamic>;
      final famille = premier['family']?.toString() ?? '';
      final donnes = (premier['given'] as List<dynamic>?)?.join(' ') ?? '';
      final assemble = '$donnes $famille'.trim();
      if (assemble.isNotEmpty) nom = assemble;
    }

    return PatientFhir(
      id: id,
      nomComplet: nom,
      genre: resource['gender']?.toString() ?? 'non précisé',
      dateNaissance: resource['birthDate']?.toString() ?? 'non précisée',
    );
  }
}
