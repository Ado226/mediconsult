// lib/providers/auth_provider.dart
// Gestion d'état de l'authentification et du rôle utilisateur.
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthProvider(this._authService);

  bool _connecte = false;
  String _role = 'medecin'; // 'medecin' ou 'patient'
  String? _email;

  bool get estConnecte => _connecte;
  String get role => _role;
  String? get email => _email;
  bool get estMedecin => _role == 'medecin';
  bool get estPatient => _role == 'patient';

  /// Connexion par email + mot de passe.
  Future<bool> connexion({
    required String email,
    required String motDePasse,
    required String role,
  }) async {
    final ok = await _authService.connexion(
      email: email,
      motDePasse: motDePasse,
      role: role,
    );
    if (ok) {
      _connecte = true;
      _role = role;
      _email = email;
      notifyListeners();
    }
    return ok;
  }

  /// Connexion via biométrie (le rôle déjà enregistré est réutilisé).
  Future<bool> connexionBiometrie() async {
    final ok = await _authService.authentifierBiometrie();
    if (ok) {
      _connecte = true;
      _role = await _authService.obtenirRole();
      _email = await _authService.obtenirEmail();
      notifyListeners();
    }
    return ok;
  }

  Future<bool> biometrieDisponible() => _authService.biometrieDisponible();

  Future<void> deconnexion() async {
    await _authService.deconnexion();
    _connecte = false;
    _email = null;
    notifyListeners();
  }

  void changerRole(String role) {
    _role = role;
    notifyListeners();
  }
}
