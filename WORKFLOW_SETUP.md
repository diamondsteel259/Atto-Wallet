# Getting GitHub Actions Workflows Running

## Current Status
You're seeing "There are no workflow runs yet" because the workflow files haven't been pushed to GitHub yet, or no triggering event has occurred.

## Quick Start - Get Workflows Running

### Step 1: Commit and Push Changes

From your local repository:

```bash
cd /workspace/cmhnnaykv013bpsim2ycco9f2/Atto-Wallet

# Stage all changes
git add .

# Commit with descriptive message
git commit -m "Add iOS implementation and mobile build workflows

- Implemented iOS platform files (Keychain, Room database, formatters)
- Added Android and iOS build jobs to GitHub Actions
- Created dedicated mobile-build workflow
- Updated pipeline to include mobile artifacts"

# Push to GitHub (this will trigger workflows)
git push origin main
```

**What happens after push:**
- `pipeline.yaml` triggers automatically (builds all platforms including mobile)
- Android APK and Bundle will be built
- iOS frameworks will be generated
- All artifacts uploaded to the workflow run

### Step 2: Manually Run Mobile Build (Optional)

After pushing, you can manually trigger the mobile-specific workflow:

1. Go to your repository: https://github.com/diamondsteel259/Atto-Wallet
2. Click **Actions** tab
3. In the left sidebar, click **"Mobile Build (Android & iOS)"**
4. Click **"Run workflow"** button (appears on the right)
5. Select your branch (e.g., `main`)
6. Click **"Run workflow"** button in the dialog

### Step 3: Monitor Workflow Progress

Once triggered, you'll see:
- **Workflow runs list** - Shows running/completed workflows
- **Live logs** - Click on a run to see real-time build logs
- **Artifacts** - Download built APK, AAB, and iOS frameworks after completion

## Workflows Overview

### 1. Pipeline (Auto-triggers on push to main)
**File:** `.github/workflows/pipeline.yaml`
**Triggers:** Push to `main` branch
**Builds:**
- Linux (Debian package)
- macOS (DMG)
- Windows (MSI)
- **Android** (APK + Bundle) ← NEW
- **iOS** (Frameworks) ← NEW
- Web (WASM)

**Artifacts:**
- Desktop installers
- Android APK (debug)
- Android Bundle (release, unsigned)
- iOS frameworks (all architectures)

### 2. Mobile Build (Manual or auto on mobile changes)
**File:** `.github/workflows/mobile-build.yaml`
**Triggers:**
- Manual dispatch (Run workflow button)
- Push to `main` or `develop` when mobile files change
- Pull requests affecting mobile code

**Artifacts:**
- `android-debug-apk` - Install on Android device
- `android-release-bundle` - Submit to Play Store (after signing)
- `ios-frameworks` - Use in Xcode
- `ios-simulator-app` - Test on iOS Simulator

## Expected Build Times

| Platform | Runner | Approx Time |
|----------|--------|-------------|
| Android  | Ubuntu | 5-8 minutes |
| iOS      | macOS  | 10-15 minutes |
| Linux    | Ubuntu | 5-8 minutes |
| macOS    | macOS  | 8-12 minutes |
| Windows  | Windows | 8-12 minutes |

**Note:** macOS runners are slower and more expensive. iOS builds only run when necessary.

## Downloading Built Apps

### After Workflow Completes:

1. Go to the workflow run page
2. Scroll to bottom: **Artifacts** section
3. Click artifact name to download:
   - **android-debug-apk** → ZIP containing APK
   - **android-release-bundle** → ZIP containing AAB
   - **ios-frameworks** → ZIP with frameworks

### Installing Android APK:
```bash
# Extract from ZIP
unzip android-debug-apk.zip

# Install on connected device
adb install composeApp-debug.apk
```

### Using iOS Frameworks:
```bash
# Extract from ZIP
unzip ios-frameworks.zip

# Copy to Xcode project
cp -R composeApp.framework /path/to/iosApp/Frameworks/
```

## Troubleshooting

### "No workflow runs yet"
✅ **Solution:** Push the workflow files to GitHub first
```bash
git push origin main
```

### Workflows not appearing in Actions tab
✅ **Solution:** Ensure workflow files are in `.github/workflows/` directory
✅ Check YAML syntax is valid (no tabs, proper indentation)

### Android build fails
✅ Check Java version (should be 17)
✅ Review error logs in workflow run
✅ Common issues: SDK location, memory limits, signing config

### iOS build fails
✅ macOS runner has Xcode 15.2+ installed
✅ Frameworks built before Xcode build
✅ Check for "Undefined symbols" errors (means missing iOS implementations)

### Artifacts not uploading
✅ Check paths match actual build output locations
✅ Ensure files were created successfully
✅ Review upload-artifact step logs

## Cost Optimization Tips

GitHub Actions has free tier limits:
- **Public repos:** Unlimited minutes
- **Private repos:** 2,000 minutes/month free
  - Linux: 1x multiplier
  - Windows: 2x multiplier
  - macOS: 10x multiplier ⚠️

**iOS builds are expensive!** A 15-minute iOS build = 150 minutes charged.

**Optimization strategies:**
1. Use `workflow_dispatch` for manual control
2. iOS builds only trigger on mobile file changes
3. Use Linux for Android builds (cheapest)
4. Cache Gradle dependencies (already configured)
5. Use pull_request paths filter to avoid unnecessary runs

## Example: Testing Mobile Build

```bash
# 1. Make a mobile code change
echo "// Test change" >> composeApp/src/commonMain/kotlin/cash/atto/wallet/App.kt

# 2. Commit and push
git add .
git commit -m "Test mobile build workflow"
git push origin main

# 3. Watch Actions tab for build progress

# 4. Download artifacts when complete
```

## What Was Implemented

✅ **iOS Platform** (9 files):
- SeedDataSource.ios.kt (Keychain storage)
- PasswordDataSource.ios.kt (per-wallet passwords)
- SaltDataSource.ios.kt (salt generation)
- SeedAESInteractor.ios.kt (stub)
- AppDatabase.ios.kt (Room database)
- Modules.ios.kt (Koin DI)
- QRCodeImage.ios.kt (QR rendering)
- AttoLocalizedFormatter.ios.kt (number formatting)
- AttoDateFormatter.ios.kt (date formatting)

✅ **Build Configuration**:
- iOS targets: iosX64, iosArm64, iosSimulatorArm64
- iOS dependencies: Room + SQLite
- KSP configuration for iOS

✅ **GitHub Actions**:
- Android build job in build.yaml
- iOS build job in build.yaml
- Dedicated mobile-build.yaml workflow
- Updated pipeline.yaml to include mobile artifacts

## Next Steps

1. **Push changes to GitHub** ← START HERE
2. Wait for pipeline workflow to run automatically
3. Check Actions tab for progress
4. Download artifacts
5. Test Android APK on device
6. Test iOS frameworks in Xcode

For production releases, see `MOBILE_BUILD.md` for signing and distribution instructions.

## Support

If workflows fail:
1. Click on the failed run
2. Click on the failed job
3. Review error logs
4. Check the specific step that failed
5. Common issues are documented above

For persistent issues, create a GitHub issue with:
- Workflow run URL
- Error message from logs
- Screenshot of failure
