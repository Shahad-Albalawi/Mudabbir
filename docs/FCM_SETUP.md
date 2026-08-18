# FCM Push Notifications — Mudabbir

The app registers device tokens with `POST /api/device-tokens` when a token is available. Local notifications work without Firebase; **remote push** requires Firebase Cloud Messaging.

## Current behavior (no Firebase)

- Local notifications: enabled via `flutter_local_notifications`
- Token sync: only when you pass `--dart-define=FCM_TEST_TOKEN=your_token` (manual testing)
- Logout: `DELETE /api/device-tokens` revokes the token on the server

## Production setup (Firebase)

### 1. Create Firebase project

1. https://console.firebase.google.com → Add project **Mudabbir**
2. Add Android app: package `com.mudabbir.app`
3. Add iOS app: bundle ID from Xcode
4. Download `google-services.json` → `frontend/android/app/`
5. Download `GoogleService-Info.plist` → `frontend/ios/Runner/`

### 2. Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
cd frontend
flutterfire configure
```

This generates `lib/firebase_options.dart`.

### 3. Add dependencies

In `frontend/pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^3.6.0
  firebase_messaging: ^15.1.3
```

Android: apply Google Services plugin in `android/settings.gradle.kts` / `android/app/build.gradle.kts` (FlutterFire docs).

### 4. Render backend

Set in Render **Environment**:

| Variable | Value |
|----------|--------|
| `FCM_SERVER_KEY` | Firebase → Project settings → Cloud Messaging → Server key (Legacy) or service account for HTTP v1 |

Optional GitHub secret for scheduler pushes: `MUDABBIR_FCM_SERVER_KEY` (same value).

### 5. Enable in app

**Option A — FlutterFire (recommended)**

After `flutterfire configure`, add `google-services.json` and run:

```bash
flutter run --dart-define-from-file=config/release.json
```

**Option B — dart-define (CI / no committed secrets)**

```bash
flutter run \
  --dart-define=FIREBASE_PROJECT_ID=your-project \
  --dart-define=FIREBASE_ANDROID_API_KEY=... \
  --dart-define=FIREBASE_ANDROID_APP_ID=... \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=...
```

When `google-services.json` exists in `android/app/`, Gradle applies the Google Services plugin automatically.

### Verify

1. Login on a physical device (emulator FCM is limited)
2. Check Render logs for device token registration
3. Trigger test from Laravel or Firebase console

## Permissions

`PushNotificationService` requests notification permission on Android 13+ and iOS when initializing.

## References

- [FlutterFire Messaging](https://firebase.flutter.dev/docs/messaging/overview)
- Backend routes: `POST/DELETE /api/device-tokens` in `backend/routes/api.php`
