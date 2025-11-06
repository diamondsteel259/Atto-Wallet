# Build Failures Analysis Report

## Current Status: BLOCKED by Two Critical Issues

After pushing the iOS implementation to GitHub, the CI/CD workflows are revealing **two separate blocking issues** that prevent successful builds.

---

## Issue #1: iOS Dependency Resolution Failure ⚠️ CRITICAL BLOCKER

### Error Message
```
e: ❌ KMP Dependencies Resolution Failure
Source set 'iosMain' couldn't resolve dependencies for all target platforms
Couldn't resolve dependency 'cash.atto:commons-wallet' in 'iosMain' for all target platforms.
The dependency should target platforms: [iosArm64, iosSimulatorArm64, iosX64]
Unresolved platforms: [iosArm64, iosSimulatorArm64, iosX64]
```

### Root Cause
The core dependency `cash.atto:commons-wallet:5.4.0` (line 118 in build.gradle.kts, line 54 in libs.versions.toml) is **not published with iOS artifacts**. This is a third-party library that provides fundamental ATTO cryptocurrency wallet functionality.

**Dependency declaration location:**
- `composeApp/build.gradle.kts` line 118: `implementation(libs.atto.commons.wallet)` in `commonMain`
- `gradle/libs.versions.toml` line 54: `atto-commons-wallet = { module = "cash.atto:commons-wallet", version.ref = "atto-commons" }`

### Impact Scope
This dependency is imported and used extensively across the codebase:

**Files using `cash.atto:commons-wallet` (30+ imports found):**
- Core app state: `AppState.kt`, `WalletManagerRepository.kt`
- ViewModels: `HomeViewModel.kt`, `ReceiveViewModel.kt`, `SendViewModel.kt`, `WalletViewModel.kt`
- All repository classes
- Network communication components
- Cryptographic operations
- Transaction building

**What this library provides:**
- Wallet cryptographic operations (key generation, signing)
- ATTO protocol implementation
- Network communication with ATTO nodes
- Transaction creation and validation
- Address encoding/decoding
- Balance management

### Why This is a Fundamental Blocker
This is **NOT** something we can work around easily:
- It's the core ATTO cryptocurrency library
- It's used in 30+ files across the entire application
- It provides fundamental wallet functionality
- Replacing it would require reimplementing the entire ATTO protocol

**This is an upstream library issue** - the library maintainers need to add iOS targets to their build configuration.

### Possible Solutions

#### Option 1: Contact Library Maintainers (RECOMMENDED)
**Action:** Request that the `cash.atto:commons-wallet` library be rebuilt as a Kotlin Multiplatform library with iOS support.

**Steps:**
1. Identify library repository: Search for "atto commons wallet" on GitHub/GitLab
2. Open issue: "Add iOS targets to commons-wallet for KMP support"
3. Request they add iOS targets: `iosX64()`, `iosArm64()`, `iosSimulatorArm64()`
4. Wait for new release with iOS artifacts

**Timeline:** Days to weeks depending on maintainer responsiveness

**Pros:**
- Proper solution that enables iOS support
- No code changes needed on our end
- Future updates work seamlessly

**Cons:**
- Dependent on external maintainers
- Unknown timeline
- May not be prioritized

#### Option 2: Fork and Rebuild Library
**Action:** Fork the `cash.atto:commons-wallet` library, add iOS targets, publish locally or to custom Maven repository.

**Steps:**
1. Fork/clone the commons-wallet repository
2. Add iOS targets to their build.gradle.kts
3. Build and publish locally using `./gradlew publishToMavenLocal`
4. Update our project to use local version
5. Maintain fork for future updates

**Timeline:** 1-2 days for experienced developer

**Pros:**
- Full control over timeline
- Can proceed immediately
- Can contribute back to upstream

**Cons:**
- Requires maintaining a fork
- Need to manually sync with upstream updates
- May have unexpected iOS compatibility issues in the library code

#### Option 3: Remove iOS Support Temporarily
**Action:** Remove iOS targets from build configuration until upstream library adds iOS support.

**Steps:**
1. Remove iOS target declarations from build.gradle.kts (lines 35-37)
2. Remove iosMain dependencies block (lines 72-76)
3. Remove iOS KSP configuration (lines 214-216)
4. Delete the 9 iOS implementation files we created

**Timeline:** 15 minutes

**Pros:**
- Android and Desktop builds would succeed
- Can deploy those platforms immediately

**Cons:**
- Abandons iOS implementation work
- No iOS app for users
- Would need to redo work when library is ready

#### Option 4: Conditional Dependency (EXPERIMENTAL)
**Action:** Move `atto-commons-wallet` from `commonMain` to platform-specific source sets (androidMain, desktopMain, wasmMain only).

**This would require:**
- Significant architectural changes
- All code using the library moved to platform-specific source sets
- Separate implementations for each platform
- Would break the KMP architecture

**Timeline:** Multiple weeks of refactoring

**Pros:**
- None really - this breaks the KMP model

**Cons:**
- Defeats the purpose of Kotlin Multiplatform
- Massive refactoring required
- Unmaintainable code duplication
- Still doesn't enable iOS

### Recommended Action
**Option 1** (Contact maintainers) combined with **Option 3** (temporarily remove iOS support) if immediate deployment of Android is needed.

**Immediate steps:**
1. Search for the commons-wallet repository
2. Open an issue requesting iOS support
3. If Android needs to be deployed urgently, temporarily remove iOS targets
4. Re-add iOS targets when library is updated

---

## Issue #2: Android DEX Build Failure

### Error Message
```
FAILURE: Build failed with an exception.

Execution failed for task ':composeApp:dexBuilderDebug'.
Error while dexing.
  com.android.tools.r8.CompilationFailedException: Compilation failed to complete, origin: /home/runner/.gradle/caches/transforms-4/5f2d.../ktor-client-core-jvm-3.0.3.jar:/io/ktor/client/plugins/cache/HttpCache$Companion.class
  Caused by: com.android.tools.r8.utils.j: Space characters in SimpleName 'use streaming syntax' are not allowed prior to DEX version 040
```

### Root Cause
Android's DEX (Dalvik Executable) format has a 65K method reference limit. The project dependencies exceed this limit, causing compilation failure. Additionally, there's a specific issue with `ktor-client-core` library having malformed class names with spaces.

**Specific error:** The ktor-client-core-jvm-3.0.3.jar contains a class with space characters in the name (`'use streaming syntax'`), which is invalid for DEX files prior to version 040.

### Current Attempted Fix
Added `multiDexEnabled = true` in `composeApp/build.gradle.kts` line 178:
```kotlin
defaultConfig {
    ...
    multiDexEnabled = true
}
```

**Status:** This fix is **insufficient**. MultiDex alone doesn't solve the malformed class name issue from ktor-client-core.

### Why MultiDex Alone Isn't Enough
1. **Malformed class names:** The space character issue in ktor-client-core still fails even with MultiDex
2. **No shrinking enabled:** `isMinifyEnabled = false` (line 187) means R8/ProGuard not removing unused code
3. **Large dependency tree:** All dependencies pulled in transitively without optimization

### Proper Solution

#### Step 1: Enable R8 Code Shrinking and Obfuscation
Update `composeApp/build.gradle.kts` line 185-189:

```kotlin
buildTypes {
    getByName("release") {
        isMinifyEnabled = true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
    }
    getByName("debug") {
        isMinifyEnabled = false
        // Keep debug builds fast, but MultiDex enabled
    }
}
```

#### Step 2: Create ProGuard Rules File
Create `composeApp/proguard-rules.pro`:

```proguard
# Keep all Atto Wallet classes
-keep class cash.atto.wallet.** { *; }

# Keep Compose runtime
-keep class androidx.compose.** { *; }
-dontwarn androidx.compose.**

# Keep Kotlin metadata
-keep class kotlin.Metadata { *; }
-keepattributes *Annotation*

# Keep Ktor classes
-keep class io.ktor.** { *; }
-dontwarn io.ktor.**

# Keep serialization
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.AnnotationsKt

-keepclassmembers class kotlinx.serialization.json.** {
    *** Companion;
}
-keepclasseswithmembers class kotlinx.serialization.json.** {
    kotlinx.serialization.KSerializer serializer(...);
}

# Keep Room classes
-keep class * extends androidx.room.RoomDatabase
-keep @androidx.room.Entity class *
-dontwarn androidx.room.**

# Keep Koin
-keep class org.koin.** { *; }
-dontwarn org.koin.**

# Remove logging in release builds
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}
```

#### Step 3: Add Ktor-Specific Workaround
If the class name issue persists, add dependency resolution strategy to exclude problematic ktor classes:

```kotlin
configurations.all {
    resolutionStrategy {
        force("io.ktor:ktor-client-core-jvm:3.0.3")
    }
    exclude(group = "io.ktor", module = "ktor-client-core-jvm")
    // Use ktor-client-core instead (multiplatform artifact)
}
```

### Timeline
- **Immediate fix:** 30 minutes to implement ProGuard rules
- **Testing:** 1-2 hours to verify build succeeds and app functions correctly
- **Total:** 2-3 hours

### Expected Outcome
- R8 will shrink unused code, reducing method count below 65K limit
- ProGuard rules protect necessary classes from obfuscation
- Release builds will be smaller and more efficient
- Debug builds remain fast with MultiDex

---

## Build Priority and Sequencing

### Cannot Proceed with iOS Until Issue #1 Resolved
iOS builds will **fail immediately** at dependency resolution before any code compilation. The atto-commons-wallet library issue **must** be resolved first.

**iOS build sequence:**
1. ❌ Dependency resolution (FAILS HERE - missing iOS artifacts)
2. ⏭️ Kotlin compilation (never reached)
3. ⏭️ Framework linking (never reached)
4. ⏭️ Xcode build (never reached)

### Android Builds Can Be Fixed Independently
Android Issue #2 is **solvable** without upstream dependencies. We can fix this ourselves with ProGuard configuration.

**Android build sequence:**
1. ✅ Dependency resolution (succeeds - Android artifacts available)
2. ✅ Kotlin compilation (succeeds)
3. ❌ DEX conversion (FAILS HERE - method count + malformed class names)
4. ⏭️ APK/AAB packaging (never reached)

---

## Recommended Action Plan

### Immediate Actions (Today)

1. **For iOS:**
   - [ ] Research the `cash.atto:commons-wallet` library
   - [ ] Find the GitHub/GitLab repository
   - [ ] Open issue requesting iOS target support
   - [ ] Provide technical details: "Please add iOS targets (iosX64, iosArm64, iosSimulatorArm64) to enable Kotlin Multiplatform Mobile support"

2. **For Android:**
   - [ ] Implement ProGuard rules (Step 1-2 above)
   - [ ] Test locally: `./gradlew assembleRelease`
   - [ ] Verify APK builds successfully
   - [ ] Test APK on Android device/emulator
   - [ ] Push fix to GitHub

### Short-term Actions (This Week)

3. **If iOS library maintainer doesn't respond:**
   - [ ] Evaluate Option 2 (Fork and rebuild library)
   - [ ] Determine if we have resources to maintain fork
   - [ ] Decision point: Continue iOS or pause until library ready?

4. **Android deployment:**
   - [ ] Once Android DEX fix verified, proceed with Play Store submission
   - [ ] Android can launch independently of iOS

### Long-term Actions (Next 2-4 Weeks)

5. **When iOS library becomes available:**
   - [ ] Update dependency version in gradle/libs.versions.toml
   - [ ] Re-run iOS builds in CI/CD
   - [ ] Resume iOS testing and deployment

---

## Files Referenced in This Report

**Build configuration:**
- `composeApp/build.gradle.kts` - Lines 118 (dependency), 178 (multiDex), 185-189 (buildTypes)
- `gradle/libs.versions.toml` - Line 54 (atto-commons version)

**GitHub Actions workflows:**
- `.github/workflows/build.yaml` - Main build workflow (Android + iOS jobs)
- `.github/workflows/mobile-build.yaml` - Mobile-specific workflow
- `.github/workflows/pipeline.yaml` - Pipeline including release

**Documentation:**
- `MOBILE_BUILD.md` - Build instructions
- `WORKFLOW_SETUP.md` - CI/CD setup guide
- `research.md` - Original research document
- `planning.md` - Implementation plan

---

## Summary

**iOS: BLOCKED** - Upstream library (`cash.atto:commons-wallet`) doesn't publish iOS artifacts. Cannot proceed until library maintainer adds iOS support OR we fork and rebuild the library ourselves.

**Android: FIXABLE** - DEX error can be resolved with ProGuard configuration and proper code shrinking. Fix can be implemented in 2-3 hours.

**Desktop/Web: UNAFFECTED** - These platforms should continue to build successfully as they have JVM artifacts available.

**Critical Path:** Android can be deployed independently. iOS blocked on external dependency.
