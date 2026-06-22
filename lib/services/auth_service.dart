// lib/services/auth_service.dart
// Authentification : biométrie (local_auth) + gestion du consentement RGPD
// et du rôle utilisateur, persistés dans flutter_secure_storage.
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class AuthService {
  static const String _cleConsentement = 'consentement_rgpd';
  static const String _cleRole = 'role_utilisateur';
  static const String _cleEmail = 'email_utilisateur';
  static const String _cleMotDePasse = 'hash_mot_de_passe';

  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // ---------------------- Consentement RGPD ----------------------

  /// Vrai si l'utilisateur n'a jamais donné son consentement.
  Future<bool> estPremierLancement() async {
    final valeur = await _storage.read(key: _cleConsentement);
    return valeur == null;
  }

  Future<void> enregistrerConsentement() async {
    await _storage.write(
      key: _cleConsentement,
      value: DateTime.now().toIso8601String(),
    );
  }

  // ---------------------- Authentification biométrique ----------------------

  /// Indique si l'appareil dispose de capteurs biométriques disponibles.
  Future<bool> biometrieDisponible() async {
    try {
      final supporte = await _auth.isDeviceSupported();
      final possible = await _auth.canCheckBiometrics;
      return supporte && possible;
    } catch (_) {
      return false;
    }
  }

  /// Lance l'authentification biométrique (empreinte / Face ID).
  Future<bool> authentifierBiometrie() async {
    try {
      return await _auth.authenticate(
        localizedReason:
            'Identifiez-vous pour accéder à vos données médicales',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  // ---------------------- Connexion email / mot de passe ----------------------

  String _hacher(String valeur) =>
      sha256.convert(utf8.encode(valeur)).toString();

  /// Connexion par identifiants. En l'absence de compte enregistré, le premier
  /// couple email/mot de passe saisi est mémorisé (mode démonstration locale).
  Future<bool> connexion({
    required String email,
    required String motDePasse,
    required String role,
  }) async {
    final emailEnregistre = await _storage.read(key: _cleEmail);
    final hashEnregistre = await _storage.read(key: _cleMotDePasse);
    final hashSaisi = _hacher(motDePasse);

    if (emailEnregistre == null || hashEnregistre == null) {
      // Premier compte : on l'enregistre.
      await _storage.write(key: _cleEmail, value: email);
      await _storage.write(key: _cleMotDePasse, value: hashSaisi);
      await definirRole(role);
      return true;
    }

    final ok = email == emailEnregistre && hashSaisi == hashEnregistre;
    if (ok) await definirRole(role);
    return ok;
  }

  // ---------------------- Rôle utilisateur ----------------------

  Future<void> definirRole(String role) async {
    await _storage.write(key: _cleRole, value: role);
  }

  Future<String> obtenirRole() async {
    return await _storage.read(key: _cleRole) ?? 'medecin';
  }

  Future<String?> obtenirEmail() async {
    return await _storage.read(key: _cleEmail);
  }

  Future<void> deconnexion() async {
    // On efface uniquement la session de rôle ; les identifiants restent.
    await _storage.delete(key: _cleRole);
  }
}
