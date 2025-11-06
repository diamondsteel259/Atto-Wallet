# Mobile Build Guide - Android & iOS

This document explains how to build the ATTO Wallet mobile apps using GitHub Actions and locally.

## GitHub Actions Builds

### Automated Builds

The repository now includes GitHub Actions workflows that automatically build Android and iOS apps.

#### Main Build Workflow (`.github/workflows/build.yaml`)
Builds all platforms including Android and iOS alongside Desktop and Web builds.

**Triggered on:**
- Workflow call (manual or from other workflows)

**Jobs:**
- `build-android` - Builds Android APK and Bundle
- `build-ios` - Builds iOS frameworks and app for simulator

#### Mobile-Specific Workflow (`.github/workflows/mobile-build.yaml`)
Dedicated workflow for Android and iOS builds with detailed output.

**Triggered on:**
- Manual dispatch (Actions tab → Mobile Build → Run workflow)
- Push to `main` or `develop` branches (when mobile files change)
- Pull requests affecting `composeApp/` or `iosApp/`

**Artifacts produced:**
- `android-debug-apk` - Debug APK for testing
- `android-release-bundle` - Release AAB (unsigned)
- `ios-frameworks` - Compiled iOS frameworks (all architectures)
- `ios-simulator-app` - iOS app for simulator testing

### How to Trigger Manual Build

1. Go to your repository on GitHub
2. Click **Actions** tab
3. Select **Mobile Build (Android & iOS)** workflow
4. Click **Run workflow** button
5. Select branch and click **Run workflow**

### Downloading Build Artifacts

1. Go to the completed workflow run
2. Scroll to **Artifacts** section at the bottom
3. Download the artifacts you need:
   - **android-debug-apk** - Install on Android device/emulator
   - **android-release-bundle** - Submit to Google Play Store (after signing)
   - **ios-frameworks** - Use in Xcode projects
   - **ios-simulator-app** - Install on iOS Simulator

---

## Local Build Instructions

### Prerequisites

**For Android:**
- Java 17 (JDK)
- Android SDK (via Android Studio recommended)
- Gradle 8.x (included via wrapper)

**For iOS:**
- macOS with Xcode 15.2+
- Java 17 (JDK)
- Gradle 8.x (included via wrapper)

### Building Android Locally

#### 1. Debug APK (for testing)
```bash
./gradlew assembleDebug
```
Output: `composeApp/build/outputs/apk/debug/composeApp-debug.apk`

#### 2. Release Bundle (for Play Store)
```bash
./gradlew bundleRelease
```
Output: `composeApp/build/outputs/bundle/release/composeApp-release.aab`

Note: Release builds need to be signed before distribution. Configure signing in `build.gradle.kts` or sign manually using `jarsigner`.

#### 3. Install on connected device
```bash
./gradlew installDebug
```

### Building iOS Locally

#### 1. Build iOS Frameworks

For Apple Silicon Mac (M1/M2/M3):
```bash
./gradlew linkDebugFrameworkIosSimulatorArm64
```

For Intel Mac:
```bash
./gradlew linkDebugFrameworkIosX64
```

For Physical iOS Device:
```bash
./gradlew linkDebugFrameworkIosArm64
```

Build all architectures:
```bash
./gradlew linkDebugFrameworkIosSimulatorArm64 linkDebugFrameworkIosArm64 linkDebugFrameworkIosX64
```

Frameworks are generated in:
- `composeApp/build/bin/iosSimulatorArm64/debugFramework/`
- `composeApp/build/bin/iosArm64/debugFramework/`
- `composeApp/build/bin/iosX64/debugFramework/`

#### 2. Build iOS App with Xcode

```bash
cd iosApp
xcodebuild -project iosApp.xcodeproj \
  -scheme iosApp \
  -configuration Debug \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
  build
```

Or open `iosApp/iosApp.xcodeproj` in Xcode and:
1. Select target device/simulator
2. Click **Product → Build** (⌘B)
3. Click **Product → Run** (⌘R) to install and launch

#### 3. Run on Simulator
```bash
# From Xcode
Product → Run (⌘R)

# Or from command line
cd iosApp
xcodebuild -project iosApp.xcodeproj \
  -scheme iosApp \
  -configuration Debug \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
  run
```

---

## Troubleshooting

### Android Issues

**Problem: "SDK location not found"**
```bash
# Create local.properties
echo "sdk.dir=/path/to/Android/sdk" > local.properties
```

**Problem: Build fails with memory error**
```bash
# Increase Gradle memory in gradle.properties
org.gradle.jvmargs=-Xmx4g -XX:MaxMetaspaceSize=512m
```

**Problem: Signing errors on release build**
- Release builds need signing configuration
- For CI/CD, use unsigned builds and sign separately
- For local development, configure signing in `build.gradle.kts`

### iOS Issues

**Problem: "Framework not found"**
```bash
# Rebuild the framework for correct architecture
./gradlew clean
./gradlew linkDebugFrameworkIosSimulatorArm64
```

**Problem: "No such module 'composeApp'"**
- Ensure framework is built before opening Xcode
- Check framework search paths in Xcode Build Settings
- Clean Xcode build folder: Product → Clean Build Folder (⌘⇧K)

**Problem: Xcode build fails with "Undefined symbols"**
- Ensure all iOS implementation files exist
- Rebuild Kotlin framework: `./gradlew clean linkDebugFrameworkIosSimulatorArm64`
- Check that all `expect`/`actual` declarations are satisfied

**Problem: iOS app crashes on launch**
- Check Xcode console for errors
- Verify Keychain implementation in iOS datasources
- Ensure database directory creation succeeds

---

## CI/CD Setup

### GitHub Actions Configuration

The workflows use:
- **Ubuntu** for Android builds (fastest, cheapest)
- **macOS** for iOS builds (required for Xcode)

### Cost Optimization

- macOS runners are more expensive than Linux
- iOS builds only run when mobile files change
- Artifacts have 30-day retention
- Use `workflow_dispatch` for manual builds to avoid unnecessary runs

### Secrets Configuration (for signed releases)

Add these secrets to your repository for production releases:

**Android:**
- `ANDROID_KEYSTORE_FILE` - Base64 encoded keystore
- `ANDROID_KEYSTORE_PASSWORD` - Keystore password
- `ANDROID_KEY_ALIAS` - Key alias
- `ANDROID_KEY_PASSWORD` - Key password

**iOS:**
- `IOS_CERTIFICATE` - Base64 encoded certificate
- `IOS_CERTIFICATE_PASSWORD` - Certificate password
- `IOS_PROVISIONING_PROFILE` - Base64 encoded provisioning profile
- `APPLE_ID` - Apple ID for App Store Connect
- `APP_SPECIFIC_PASSWORD` - App-specific password

---

## Platform Status

| Platform | Build Status | Implementation Status | Distribution Ready |
|----------|--------------|----------------------|-------------------|
| Android  | ✅ Working   | ✅ Complete          | ✅ Yes (needs signing) |
| iOS      | ✅ Working   | ✅ Complete          | ⚠️ Needs code signing |

### Android
- **Complete**: All features implemented and tested
- **Build**: APK and AAB generated successfully
- **Distribution**: Ready for Google Play Store (after signing)
- **Security**: Uses Android Keystore for secure storage

### iOS
- **Complete**: All platform-specific implementations added
- **Build**: Frameworks generate successfully, Xcode builds
- **Distribution**: Needs Apple Developer account and code signing
- **Security**: Uses iOS Keychain for secure storage

---

## Next Steps

### For Android Release
1. Configure signing keys in `build.gradle.kts`
2. Build signed release: `./gradlew bundleRelease`
3. Upload AAB to Google Play Console
4. Complete store listing and submit for review

### For iOS Release
1. Enroll in Apple Developer Program ($99/year)
2. Create App ID and provisioning profiles
3. Configure code signing in Xcode
4. Archive app: Product → Archive
5. Upload to App Store Connect
6. Complete app metadata and submit for review

### For TestFlight (iOS Beta Testing)
1. Archive app in Xcode with release configuration
2. Upload to App Store Connect via Xcode
3. Add beta testers in App Store Connect
4. Distribute via TestFlight

---

## Support

For build issues:
1. Check this guide first
2. Review workflow logs in GitHub Actions
3. Search existing issues in the repository
4. Create new issue with detailed error logs

## Implementation Details

The iOS implementation includes:
- ✅ iOS Keychain secure storage (SeedDataSource, PasswordDataSource, SaltDataSource)
- ✅ Room database for iOS (AppDatabase.ios.kt)
- ✅ Koin dependency injection (Modules.ios.kt)
- ✅ QR code rendering (QRCodeImage.ios.kt)
- ✅ Localized formatters (AttoLocalizedFormatter, AttoDateFormatter)
- ✅ Build configuration for all iOS targets (x64, ARM64, SimulatorARM64)

All expect/actual declarations satisfied. iOS has feature parity with Android/Desktop.
