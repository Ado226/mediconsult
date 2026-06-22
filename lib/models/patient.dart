// lib/models/patient.dart
// Modèle Patient — stocké localement via Hive (box chiffrée AES).
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

part 'patient.g.dart';

@HiveType(typeId: 0)
class Patient extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String nom;

  @HiveField(2)
  late String prenom;

  @HiveField(3)
  late DateTime dateNaissance;

  @HiveField(4)
  late String telephone;

  @HiveField(5)
  late String groupeSanguin;

  @HiveField(6)
  late String antecedents;

  @HiveField(7)
  late String statut; // 'actif', 'attente', 'urgent'

  @HiveField(8)
  DateTime? derniereVisite;

  @HiveField(9)
  bool estSynchronise = false;

  Patient();

  /// Constructeur pratique pour créer un patient complet.
  Patient.complet({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.dateNaissance,
    required this.telephone,
    required this.groupeSanguin,
    required this.antecedents,
    this.statut = 'actif',
    this.derniereVisite,
    this.estSynchronise = false,
  });

  // ---- Logique métier (testée dans test/models/patient_test.dart) ----

  /// Nom complet au format « Prénom Nom ».
  String get nomComplet => '$prenom $nom';

  /// Initiales en majuscules (2 lettres).
  String get initiales {
    final p = prenom.isNotEmpty ? prenom[0] : '';
    final n = nom.isNotEmpty ? nom[0] : '';
    return '$p$n'.toUpperCase();
  }

  /// Âge calculé à partir de la date de naissance.
  int get age {
    final maintenant = DateTime.now();
    var ans = maintenant.year - dateNaissance.year;
    final aEuAnniversaire = (maintenant.month > dateNaissance.month) ||
        (maintenant.month == dateNaissance.month &&
            maintenant.day >= dateNaissance.day);
    if (!aEuAnniversaire) ans--;
    return ans;
  }

  /// Couleur associée au statut clinique du patient.
  Color get couleurStatut {
    switch (statut) {
      case 'urgent':
        return Colors.red;
      case 'attente':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  /// Libellé lisible du statut.
  String get libelleStatut {
    switch (statut) {
      case 'urgent':
        return 'Urgent';
      case 'attente':
        return 'En attente';
      default:
        return 'Actif';
    }
  }

  /// Dernière visite formatée (ou « Aucune visite »).
  String get derniereVisiteFormatee {
    if (derniereVisite == null) return 'Aucune visite';
    return DateFormat('dd/MM/yyyy', 'fr_FR').format(derniereVisite!);
  }
}
