// lib/screens/login_screen.dart
// Écran de connexion : email/mot de passe + biométrie, choix du rôle,
// et affichage du consentement RGPD au premier lancement.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../widgets/consentement_dialog.dart';
import 'home_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'medecin@mediconsult.bf');
  final _motDePasseController = TextEditingController(text: 'demo1234');
  final _authService = AuthService();

  String _role = 'medecin';
  bool _enChargement = false;
  bool _biometrieDispo = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verifierConsentement();
      _verifierBiometrie();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _motDePasseController.dispose();
    super.dispose();
  }

  /// Affiche le dialog RGPD bloquant si c'est le premier lancement.
  Future<void> _verifierConsentement() async {
    final premier = await _authService.estPremierLancement();
    if (premier && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => ConsentementDialog(
          onAccepter: _authService.enregistrerConsentement,
        ),
      );
    }
  }

  Future<void> _verifierBiometrie() async {
    final dispo = await _authService.biometrieDisponible();
    if (mounted) setState(() => _biometrieDispo = dispo);
  }

  Future<void> _connexionIdentifiants() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _enChargement = true);

    final auth = context.read<AuthProvider>();
    final ok = await auth.connexion(
      email: _emailController.text.trim(),
      motDePasse: _motDePasseController.text,
      role: _role,
    );

    if (!mounted) return;
    setState(() => _enChargement = false);

    if (ok) {
      _allerAccueil();
    } else {
      _afficherErreur('Identifiants incorrects.');
    }
  }

  Future<void> _connexionBiometrie() async {
    final auth = context.read<AuthProvider>();
    auth.changerRole(_role);
    final ok = await auth.connexionBiometrie();
    if (!mounted) return;
    if (ok) {
      _allerAccueil();
    } else {
      _afficherErreur('Authentification biométrique échouée ou annulée.');
    }
  }

  void _allerAccueil() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeShell()),
    );
  }

  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withValues(alpha: 0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.medical_services_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'MediConsult',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Consultation médicale • Master e-Santé',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Sélecteur de rôle.
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<String>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(
                          value: 'medecin',
                          label: Text('Médecin'),
                          icon: Icon(Icons.badge_outlined),
                        ),
                        ButtonSegment(
                          value: 'patient',
                          label: Text('Patient'),
                          icon: Icon(Icons.person_outline),
                        ),
                      ],
                      selected: {_role},
                      onSelectionChanged: (s) =>
                          setState(() => _role = s.first),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Email.
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Adresse e-mail',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Veuillez saisir votre e-mail';
                      }
                      if (!v.contains('@')) {
                        return 'Adresse e-mail invalide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Mot de passe.
                  TextFormField(
                    controller: _motDePasseController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Mot de passe',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Veuillez saisir votre mot de passe';
                      }
                      if (v.length < 6) {
                        return 'Au moins 6 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Bouton connexion.
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _enChargement ? null : _connexionIdentifiants,
                      icon: _enChargement
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.login),
                      label: const Text('Connexion'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Row(
                    children: const [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('ou'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Biométrie.
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _connexionBiometrie,
                      icon: const Icon(Icons.fingerprint),
                      label: Text(
                        _biometrieDispo
                            ? 'Se connecter avec la biométrie'
                            : 'Biométrie (non détectée sur cet appareil)',
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
