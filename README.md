# ONYX iOS - reconstruction officielle

Projet SwiftUI iOS original, conçu pour Xcode et Codemagic.

## Fonctionnalités
- Catalogue de liens vers les plateformes officielles françaises : france.tv, ARTE, TF1+, M6+, BFMTV, Pluto TV, Rakuten TV, Crunchyroll et ADN.
- Catégories TV, Films et séries, Animés.
- Favoris et historique stockés localement avec UserDefaults.
- Ajout et stockage local de sources vidéo personnelles autorisées.
- Lecteur AVPlayer pour les URL directes HLS (.m3u8) et MP4, avec bouton de bascule vers la source suivante.
- Les plateformes avec DRM, authentification ou restrictions ouvrent leur site officiel. Aucun DRM n'est contourné.

## Important
Cette reconstruction ne réutilise pas les flux tiers, clés d'API ou identifiants trouvés dans l'APK fourni. Les services officiels peuvent nécessiter une connexion, une application, un abonnement ou être soumis à des restrictions territoriales. Les URL de catalogue sont des points d'entrée officiels, pas des liens directs de flux.

## Compilation
- Ouvrir `ONYXIOS.xcodeproj` dans Xcode.
- Schéma : `ONYXIOS`.
- iOS Deployment Target : 16.0.
- Codemagic : le fichier `codemagic.yaml` compile une application non signée pour simulateur et archive le `.app` dans un ZIP.

Le Bundle Identifier de démonstration est `fr.onyx.ios`. Change-le si nécessaire avant une distribution signée.
