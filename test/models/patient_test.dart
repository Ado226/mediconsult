// test/models/patient_test.dart
// Tests unitaires de la logique métier du modèle Patient.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suivi_medical/models/patient.dart';

void main() {
  group('Patient', () {
    Patient creer({
      String nom = 'Sawadogo',
      String prenom = 'Aminata',
      DateTime? dateNaissance,
      String statut = 'actif',
    }) {
      return Patient.complet(
        id: 'test',
        nom: nom,
        prenom: prenom,
        dateNaissance: dateNaissance ?? DateTime(1990, 1, 1),
        telephone: '+226 70 00 00 00',
        groupeSanguin: 'A+',
        antecedents: '',
        statut: statut,
      );
    }

    test('nomComplet retourne "Prénom Nom"', () {
      final p = creer(prenom: 'Aminata', nom: 'Sawadogo');
      expect(p.nomComplet, equals('Aminata Sawadogo'));
    });

    test('initiales = 2 premières lettres en majuscules', () {
      final p = creer(prenom: 'aminata', nom: 'sawadogo');
      expect(p.initiales, equals('AS'));
    });

    test('statut urgent → couleur rouge', () {
      final p = creer(statut: 'urgent');
      expect(p.couleurStatut, equals(Colors.red));
    });

    test('statut attente → couleur orange', () {
      final p = creer(statut: 'attente');
      expect(p.couleurStatut, equals(Colors.orange));
    });

    test('statut actif → couleur verte', () {
      final p = creer(statut: 'actif');
      expect(p.couleurStatut, equals(Colors.green));
    });

    test('calcul de l\'âge correct', () {
      final maintenant = DateTime.now();
      // Anniversaire déjà passé cette année → âge = 30.
      final naissance = DateTime(maintenant.year - 30, 1, 1);
      final p = creer(dateNaissance: naissance);
      expect(p.age, equals(30));
    });

    test('âge tient compte de l\'anniversaire non encore passé', () {
      final maintenant = DateTime.now();
      // Naissance demain, il y a 25 ans → l'anniversaire n'a pas eu lieu → 24.
      final demain = maintenant.add(const Duration(days: 1));
      final naissance = DateTime(maintenant.year - 25, demain.month, demain.day);
      final p = creer(dateNaissance: naissance);
      expect(p.age, equals(24));
    });

    test('estSynchronise = false par défaut', () {
      final p = creer();
      expect(p.estSynchronise, isFalse);
    });
  });
}
