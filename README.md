# Traditional Gems

Traditional Gems is a Flutter application that helps users discover and explore traditional and cultural places — hotels, restaurants, attractions and local stores — across Algeria. It was developed as a professional client request for PhD research exploring the discovery of traditional tourism places, UX and localized content delivery.

This repository contains the full client mobile application, built with Flutter and Firebase, intended as a sample client project for academic research and practical deployment.

---

## Highlights

- Cross-platform Flutter app (Android / iOS)
- Firestore-backed PointOfInterest (POI) model with real-time streams and CRUD operations
- Local persistent favorites using SharedPreferences
- Internationalization (Arabic / English / French)
- Light / Dark theming and careful surface/background contrast
- Admin features for adding, editing, and managing recommended POIs
- Clickable social links (Facebook, Instagram, TikTok) in place details
- Robust UI fallbacks — category-based icons when no image is provided

## Project Structure (selected)

- lib/models - POI model and enums
- lib/services - Firebase helper methods and streams
- lib/providers - state management (Provider)
- lib/pages - app screens (Discover, Admin, Settings, Place details, Forms)
- lib/widgets - reusable UI components and cards
- lib/theme - centralized colors and theme data
- assets - images and icons

## Local development

Prerequisites: Flutter SDK (>= 3.9.x), configured Android/iOS toolchains, and a Firebase project.

1. Clone the repository

	git clone https://github.com/zaki-mj/traditio.git
	cd traditio

2. Install dependencies

	flutter pub get

3. Firebase setup

	- Add your Firebase Android/iOS config files (google-services.json / GoogleService-Info.plist) to the respective platform folders.
	- Ensure Firestore rules and indexes are configured for the `points_of_interest` collection used by the app.

4. Run the app

	flutter run

## Important behavior notes

- Favorites are persisted locally in SharedPreferences; clearing favorites from the Settings screen affects only local device state.
- Recommended POIs are stored as a boolean flag on each Firestore document and surfaced via a filtered stream — admin changes propagate in realtime.
- When a POI has no image URL, the app displays a category-specific icon locally (no update to Firestore or cloud data required).

## Localization

Translations are kept in `lib/l10n` and the app supports Arabic (ar), English (en), and French (fr).

## Testing & linting

Run static analysis:

	flutter analyze

Add or run unit/widget tests with `flutter test`.

## Contribution & License

This project was created for a client request tied to PhD research. If you would like to contribute, please open an issue or a pull request. Include a clear description of the change and any relevant testing steps.

Unless otherwise noted, this repository uses an open-source-compatible license — check the root for a LICENSE file.

---

If you'd like I can further expand this README with architecture diagrams, API contract details, or setup helper scripts (e.g., firebase emulator setup). Let me know which you'd like next.
