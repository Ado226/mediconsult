// lib/models/consultation.dart
// Modèle Consultation — rattaché à un patient via patientId.
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

part 'consultation.g.dart';

@HiveType(typeId: 1)
class Consultation extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String patientId;

  @HiveField(2)
  late DateTime dateHeure;

  @HiveField(3)
  late String motif;

  @HiveField(4)
  late String diagnostic;

  @HiveField(5)
  late String traitement;

  @HiveField(6)
  late String noteMedecin;

  @HiveField(7)
  bool estSynchronisee = false;

  Consultation();

  Consultation.complete({
    required this.id,
    required this.patientId,
    required this.dateHeure,
    required this.motif,
    required this.diagnostic,
    required this.traitement,
    required this.noteMedecin,
    this.estSynchronisee = false,
  });

  /// Date et heure formatées (ex. « 22/06/2026 à 14h30 »).
  String get dateHeureFormatee =>
      DateFormat("dd/MM/yyyy 'à' HH'h'mm", 'fr_FR').format(dateHeure);

  /// Date seule formatée.
  String get dateFormatee =>
      DateFormat('dd/MM/yyyy', 'fr_FR').format(dateHeure);
}
