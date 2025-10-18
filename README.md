# Alumni-Connect

> A Flutter-based alumni networking app connecting graduates through communities, posts, opportunities and events. Built with Firebase (Auth, Firestore, Storage) and Google Sign-In for fast onboarding.

---

## Table of contents

* [Demo](#demo)
* [Key features](#key-features)
* [Tech stack](#tech-stack)
* [Architecture & folders](#architecture--folders)
* [Setup & local development](#setup--local-development)
* [Firebase configuration](#firebase-configuration)
* [Running the app](#running-the-app)
* [Testing](#testing)
* [How to contribute](#how-to-contribute)
* [Roadmap](#roadmap)
* [Troubleshooting](#troubleshooting)
* [License](#license)

---



## Key features

* Google Sign-In (Firebase Authentication)
* Communities: view joined communities and explore others (horizontal and grid/list views)
* Community feed: posts filtered by `communityId` with content, author, and timestamp
* Create / Edit posts (text, optional media upload)
* Opportunities & Events: list and detail screens
* Profile screen with basic user info and joined communities
* Bottom navigation (Community / Mentoring / Profile)
* Real-time data using Cloud Firestore

---

## Tech stack

* Flutter (Dart)
* Firebase: Authentication, Cloud Firestore, Storage
* Google Sign-In
* Platform: Android (Kotlin) and iOS

---

## Architecture & folders (high-level)

```
/lib
  /models        # Data models (User, Community, Post, Event, Opportunity)
  /services      # Firebase service wrappers (auth_service, firestore_service)
  /pages         # UI pages (CommunitiesPage, CommunityFeedPage, ProfilePage...)
  /widgets       # Reusable widgets (CommunityTile, PostCard...)
  /utils         # Helpers (date formatting, validators)
/assets
  /images
  /screenshots
/test            # Unit / widget tests (if any)
```

> The codebase uses provider/riverpod/get_it (pick whichever you used) or plain StatefulWidgets for state management. If you use a specific pattern, replace this line with the pattern name and a short note.

---

## Setup & local development

1. **Clone the repo**

```bash
git clone https://github.com/Sharathmedijala/Alumni-connect.git
cd Alumni-connect
```

2. **Install Flutter and dependencies**

* Ensure Flutter SDK is installed and `flutter` is on your PATH. Minimum stable Flutter version: check your project's `pubspec.yaml` `environment:` field.

```bash
flutter pub get
```

3. **Platform tooling**

* Android: install Android Studio, Android SDK, and configure an emulator or connect a device.
* iOS: Xcode (macOS required).

---

## Firebase configuration

This project requires a Firebase project. Follow these steps:

1. Create a Firebase project at [https://console.firebase.google.com](https://console.firebase.google.com)
2. Add Android and/or iOS apps to the project.
3. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) and place them in the platform-specific folders:

   * Android: `android/app/google-services.json`
   * iOS: `ios/Runner/GoogleService-Info.plist`
4. Enable **Authentication → Sign-in method → Google**.
5. Create Firestore database (start in test mode for development) and configure collections: `users`, `communities`, `posts`, `events`, `opportunities`.
6. (Optional) Enable Firebase Storage for media uploads.

**Environment / config file**

If the project uses a `.env` or `lib/config.dart`, populate it with your Firebase project values. Do NOT commit API keys or service files to a public repository.

---

## Running the app

Run on Android emulator or connected device:

```bash
flutter run
```

Build release APK for Android:

```bash
flutter build apk --release
```

---

## Testing

If tests exist run:

```bash
flutter test
```

Add widget and unit tests for key UI flows and service classes where possible.

---

## How to contribute

1. Fork the repository
2. Create a branch: `git checkout -b feat/your-feature`
3. Make changes and add tests
4. Commit, push and open a Pull Request with a clear description of what you changed

Please follow the existing code style and include screenshots/GIFs for UI changes.

---

## Roadmap (suggested)

* Notifications for new posts in joined communities
* Search across communities and opportunities
* Richer profiles (resume upload, skills, graduation year)
* Admin panel for community moderation
* Progressive Web App (PWA) support

---

## Troubleshooting

* **Google Sign-In not working**: double-check `SHA-1` (Android) added in Firebase console and that the OAuth client matches the package name.
* **Firestore permission errors**: verify Firestore rules or temporarily open rules while developing (remember to tighten before production).
* **Missing platform files**: confirm `google-services.json` / `GoogleService-Info.plist` are in the expected paths.

---

## Credits

Built by :
Sharath Medijala
M S Suhel
M Vishnuvardhan


---


