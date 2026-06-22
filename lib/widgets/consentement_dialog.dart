// lib/widgets/consentement_dialog.dart
// Dialog modal bloquant de consentement RGPD affiché au premier lancement.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConsentementDialog extends StatelessWidget {
  /// Appelé lorsque l'utilisateur accepte le traitement de ses données.
  final VoidCallback onAccepter;

  const ConsentementDialog({super.key, required this.onAccepter});

  @override
  Widget build(BuildContext context) {
    // PopScope empêche de fermer le dialog avec le bouton retour.
    return PopScope(
      canPop: false,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: const [
            Icon(Icons.privacy_tip_outlined, color: Colors.blue),
            SizedBox(width: 10),
            Expanded(child: Text('Protection des données (RGPD)')),
          ],
        ),
        content: const SingleChildScrollView(
          child: Text(
            'MediConsult traite des données de santé à caractère personnel '
            '(identité des patients, antécédents médicaux, consultations).\n\n'
            'Ces données sont :\n'
            '• stockées localement sur cet appareil de manière chiffrée (AES) ;\n'
            '• protégées par une authentification biométrique ;\n'
            '• utilisées uniquement à des fins de suivi médical.\n\n'
            'Conformément au RGPD, vous disposez d\'un droit d\'accès, de '
            'rectification et de suppression de ces données.\n\n'
            'En appuyant sur « J\'accepte », vous consentez à ce traitement.',
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              // Refus : on quitte l'application.
              SystemNavigator.pop();
            },
            child: const Text('Refuser'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              onAccepter();
            },
            child: const Text('J\'accepte'),
          ),
        ],
      ),
    );
  }
}
