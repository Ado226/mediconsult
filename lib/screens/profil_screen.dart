// lib/screens/profil_screen.dart
// Profil de l'utilisateur connecté + sécurité + déconnexion.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'login_screen.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  Future<void> _deconnexion(BuildContext context) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (confirme == true && context.mounted) {
      await context.read<AuthProvider>().deconnexion();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor:
                      theme.colorScheme.primary.withValues(alpha: 0.15),
                  child: Icon(
                    auth.estMedecin ? Icons.badge : Icons.person,
                    size: 44,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  auth.email ?? 'Utilisateur',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text(auth.estMedecin ? 'Médecin' : 'Patient'),
                  avatar: Icon(
                    auth.estMedecin ? Icons.medical_services : Icons.person,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const _Section(titre: 'Sécurité'),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.fingerprint, color: Colors.green),
                  title: Text('Authentification biométrique'),
                  subtitle: Text('Activée pour cette application'),
                  trailing: Icon(Icons.check_circle, color: Colors.green),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.lock, color: Colors.green),
                  title: Text('Chiffrement des données (AES)'),
                  subtitle: Text('Base locale Hive chiffrée'),
                  trailing: Icon(Icons.check_circle, color: Colors.green),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.privacy_tip, color: Colors.green),
                  title: Text('Consentement RGPD'),
                  subtitle: Text('Recueilli au premier lancement'),
                  trailing: Icon(Icons.check_circle, color: Colors.green),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const _Section(titre: 'À propos'),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('MediConsult'),
                  subtitle: Text('Version 1.0.0 — Master Télémédecine & e-Santé'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.cloud_outlined),
                  title: Text('Interopérabilité'),
                  subtitle: Text('Serveur FHIR HAPI R4 (test public)'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          OutlinedButton.icon(
            onPressed: () => _deconnexion(context),
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text('Déconnexion',
                style: TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String titre;
  const _Section({required this.titre});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        titre,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }
}
