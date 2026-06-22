# MediConsult — Application de Consultation Médicale

> Projet du **Master Télémédecine & e-Santé** — *Technologie Mobile pour la Santé* (Séance 5, Option B).
> Application mobile Flutter de consultation médicale intégrant UI + Données + API + Sécurité.

---

## 🎯 Présentation

**MediConsult** permet à un médecin de gérer ses patients et leurs consultations :
liste de patients, fiche détaillée, prise de notes de consultation, rendez-vous,
le tout avec **stockage local chiffré**, **authentification biométrique** et
**interopérabilité FHIR**.

- **Public cible :** médecins et patients.
- **Problème adressé :** centraliser et sécuriser le suivi des consultations en mobilité.

---

## ✅ Fonctionnalités obligatoires (cahier des charges)

| # | Fonctionnalité | Implémentation |
|---|----------------|----------------|
| 1 | Écran de connexion + **biométrie** | `local_auth`, rôle médecin/patient |
| 2 | **Navigation par onglets** (4 écrans) | `NavigationBar` Material 3 |
| 3 | **Formulaire** avec validation | Ajout patient + nouvelle consultation |
| 4 | **Liste** en `Card` + codes couleur | Avatar initiales, statut vert/orange/rouge, recherche, swipe-to-delete |
| 5 | **Stockage local chiffré** | Hive + `HiveAesCipher` (clé AES-256 dans `flutter_secure_storage`) |
| 6 | **Appel API REST FHIR** | `GET https://hapi.fhir.org/baseR4/Patient` |
| 7 | **Consentement RGPD** | Dialog bloquant au premier lancement |

### Bonus implémentés
- 📊 Graphique (`fl_chart`) — répartition des patients sur le tableau de bord.
- 🔔 Notifications locales (`flutter_local_notifications`).
- 🔄 Service de synchronisation (`sync_service`).
- 🌗 Thème clair **et** sombre (Material 3).

---

## 🏗️ Architecture

```
lib/
├── main.dart                  # Init (Hive chiffré, seed, notifications) + runApp
├── app.dart                   # MaterialApp, thème M3, localisation FR
├── models/                    # Patient, Consultation (Hive @HiveType)
├── services/                  # auth · fhir · storage · sync
├── providers/                 # AuthProvider · PatientsProvider (Provider)
├── screens/                   # login · dashboard · patients · détail · ajout · RDV · profil
└── widgets/                   # carte_patient · consentement_dialog
```

**Séparation en couches :** UI (screens/widgets) → État (providers) → Services → Stockage/API.

---

## 🔐 Sécurité (Séance 4)

- **Biométrie** via `local_auth` (`FlutterFragmentActivity` côté Android).
- **Chiffrement AES** de la base Hive ; clé générée aléatoirement et stockée
  dans le coffre-fort sécurisé du système.
- **Hachage SHA-256** du mot de passe (`crypto`).
- **Consentement RGPD** recueilli et horodaté.

---

## 🚀 Démarrage

```bash
# 1. Installer les dépendances
flutter pub get

# 2. Générer les adaptateurs Hive (déjà fournis, mais régénérables)
flutter pub run build_runner build --delete-conflicting-outputs

# 3. Lancer les tests
flutter test

# 4. Lancer l'application
flutter run
```

---

## 🧪 Tests unitaires

`test/models/patient_test.dart` couvre la logique métier du modèle `Patient` :
nom complet, initiales, couleur de statut, calcul d'âge, valeur par défaut de
synchronisation. **8 tests, tous au vert.**

```bash
flutter test
# 00:00 +8: All tests passed!
```

---

## 📦 Dépendances principales

`google_fonts`, `fl_chart`, `hive` / `hive_flutter`, `http`,
`connectivity_plus`, `local_auth`, `flutter_secure_storage`, `crypto`,
`intl`, `provider`, `flutter_local_notifications`.

---

## 👤 Données de démonstration

5 patients fictifs sont insérés au premier lancement (Aminata Sawadogo,
Moussa Kaboré, Fatoumata Traoré, Ibrahim Ouédraogo, Mariam Diallo) afin de
permettre une démonstration immédiate.

---

*Master Télémédecine & e-Santé — Technologie Mobile pour la Santé.*
