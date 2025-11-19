# Application Mobile Flutter

## Installation

```bash
flutter pub get
flutter run
```

## Configuration

Avant de lancer l'application, modifiez le fichier `lib/services/api_service.dart` et remplacez `YOUR_API_URL_HERE` par l'URL de votre API déployée.

## Fonctionnalités

- Création de compte (privé ou pro)
- Connexion
- Affichage du profil
- Gestion des entreprises (ajout, suppression)
- CRUD des publications
- Recherche de publications

## Génération de l'APK

```bash
flutter build apk --release
```

L'APK sera généré dans `build/app/outputs/flutter-apk/app-release.apk`

