# Repository Cleanup Plan

## Issues to Address

### 1. CodeQL Analysis Failures

**Problem:** CodeQL security scanning is failing in GitHub Actions

**Possible Causes:**
- CodeQL may be auto-enabled by GitHub for public repositories
- CodeQL doesn't support Kotlin Multiplatform properly
- CodeQL configuration may be outdated or misconfigured

**Solutions:**

#### Option A: Disable CodeQL (if not needed)
If security scanning isn't required, disable CodeQL:

1. **Via GitHub UI:**
   - Go to repository Settings
   - Navigate to "Code security and analysis"
   - Disable "CodeQL analysis"

2. **Via Workflow (if there's a codeql.yml file):**
   - Delete `.github/workflows/codeql.yml` or similar
   - Commit and push

#### Option B: Fix CodeQL Configuration
If security scanning is needed, configure CodeQL properly for KMP:

1. Create `.github/workflows/codeql.yml`:
```yaml
name: "CodeQL"

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  schedule:
    - cron: '0 0 * * 1'  # Weekly on Monday

jobs:
  analyze:
    name: Analyze
    runs-on: ubuntu-latest
    permissions:
      actions: read
      contents: read
      security-events: write

    strategy:
      fail-fast: false
      matrix:
        language: [ 'java' ]  # CodeQL treats Kotlin as Java

    steps:
    - name: Checkout repository
      uses: actions/checkout@v5

    - name: Set up JDK
      uses: actions/setup-java@v5
      with:
        distribution: 'temurin'
        java-version: '17'
        cache: 'gradle'

    - name: Initialize CodeQL
      uses: github/codeql-action/init@v3
      with:
        languages: ${{ matrix.language }}

    - name: Build
      run: ./gradlew compileKotlin --no-daemon

    - name: Perform CodeQL Analysis
      uses: github/codeql-action/analyze@v3
```

### 2. Commons SDK / commons-wallet Dependency Issues

**Problem:** The `cash.atto:commons-wallet` library is causing build failures

**Current Usage:**
- Located in `gradle/libs.versions.toml` line 54: `atto-commons-wallet`
- Referenced in `composeApp/build.gradle.kts` line 118 in `commonMain` dependencies
- Used extensively throughout the codebase (30+ files)

**Issues:**
1. **iOS blocker:** Library doesn't publish iOS artifacts
2. **Potential version conflicts:** May need version update
3. **ProGuard rules:** Need proper keep rules (already added)

**Solutions:**

#### For iOS Issue:
See `BUILD_FAILURES_REPORT.md` for detailed solutions.

**Quick fixes:**
1. **Temporarily disable iOS builds:**
```kotlin
// In composeApp/build.gradle.kts
// Comment out iOS targets:
// iosX64()
// iosArm64()
// iosSimulatorArm64()
```

2. **Wait for upstream library update:**
   - Contact library maintainers
   - Request iOS target support

3. **Use local fork:**
   - Fork cash.atto:commons-wallet
   - Add iOS targets
   - Publish to mavenLocal()

#### For Dependency Management:
Clean up dependency declarations:

```kotlin
// In build.gradle.kts, ensure clear dependency structure
commonMain.dependencies {
    // Core dependencies
    implementation(libs.atto.commons.wallet)  // Clear what this provides
}

// Platform-specific overrides if needed
androidMain.dependencies {
    // Android-specific version if needed
}
```

---

## Cleanup Checklist

### High Priority (Breaking Builds)

- [ ] **Fix or disable CodeQL**
  - [ ] Check if CodeQL workflow exists in `.github/workflows/`
  - [ ] If exists and failing: Fix configuration or delete file
  - [ ] If auto-enabled by GitHub: Disable in repository settings
  - [ ] Verify workflows pass after change

- [ ] **Address iOS dependency blocker**
  - [ ] Option 1: Temporarily disable iOS targets (quick fix)
  - [ ] Option 2: Contact commons-wallet maintainers
  - [ ] Option 3: Fork and add iOS support ourselves
  - [ ] Document chosen approach

- [ ] **Push Android DEX fix**
  - [ ] Run `./commit-android-dex-fix.sh`
  - [ ] Verify Android build succeeds in CI/CD

### Medium Priority (Maintenance)

- [ ] **Clean up workflow files**
  - [ ] Review all `.github/workflows/*.yaml` files
  - [ ] Remove unused workflows
  - [ ] Consolidate duplicate jobs
  - [ ] Add clear comments

- [ ] **Dependency audit**
  - [ ] Review `gradle/libs.versions.toml`
  - [ ] Check for outdated versions
  - [ ] Remove unused dependencies
  - [ ] Document why each dependency is needed

- [ ] **Documentation cleanup**
  - [ ] Review all *.md files in root
  - [ ] Remove outdated documentation
  - [ ] Update README with current status
  - [ ] Consolidate build instructions

### Low Priority (Code Quality)

- [ ] **ProGuard optimization**
  - [ ] Test release build with current ProGuard rules
  - [ ] Adjust rules if needed for smaller APK
  - [ ] Verify no runtime crashes from over-obfuscation

- [ ] **Workflow optimization**
  - [ ] Cache Gradle dependencies properly
  - [ ] Parallelize independent jobs
  - [ ] Reduce build matrix if possible

---

## Immediate Action Items

### 1. Check for CodeQL Workflow (1 minute)
```bash
cd /workspace/cmhnnaykv013bpsim2ycco9f2/Atto-Wallet
ls -la .github/workflows/ | grep -i codeql
```

**If file exists:**
- Read the file
- Determine if it's needed
- Fix or delete

**If file doesn't exist:**
- CodeQL is auto-enabled by GitHub
- Disable in repository Settings > Code security and analysis

### 2. Choose iOS Strategy (5 minutes)

**Quick fix (15 minutes):**
Comment out iOS targets in `build.gradle.kts` to unblock other platforms:

```kotlin
// Temporarily disabled until commons-wallet adds iOS support
// iosX64()
// iosArm64()
// iosSimulatorArm64()
```

Also comment out:
- iosMain dependencies block
- iOS KSP configuration

This allows Android/Desktop/Web to build successfully.

**OR**

**Long-term fix (research required):**
- Search for `cash.atto/commons-wallet` repository
- Open issue requesting iOS support
- Wait for response

### 3. Push Android Fix (5 minutes)

Already prepared, just execute:
```bash
cd /workspace/cmhnnaykv013bpsim2ycco9f2/Atto-Wallet
./commit-android-dex-fix.sh
```

---

## Scripts to Run

### Quick Cleanup Script

Create `cleanup.sh`:
```bash
#!/bin/bash
set -e

echo "=== Atto Wallet Repository Cleanup ==="
echo ""

# Check for CodeQL
echo "1. Checking for CodeQL workflow..."
if [ -f .github/workflows/codeql.yml ] || [ -f .github/workflows/codeql.yaml ]; then
    echo "   ⚠️  CodeQL workflow found"
    echo "   Action: Review and fix or delete"
else
    echo "   ✅ No CodeQL workflow file"
    echo "   Note: May be auto-enabled by GitHub - check repository settings"
fi
echo ""

# Check build status
echo "2. Checking Gradle build..."
./gradlew tasks > /dev/null 2>&1 && echo "   ✅ Gradle configuration valid" || echo "   ❌ Gradle configuration has errors"
echo ""

# List workflow files
echo "3. Current workflow files:"
ls -1 .github/workflows/
echo ""

# Check for iOS targets
echo "4. iOS targets in build.gradle.kts:"
grep -E "ios[A-Z]" composeApp/build.gradle.kts || echo "   ℹ️  No iOS targets found"
echo ""

echo "=== Cleanup Recommendations ==="
echo "1. Fix/disable CodeQL (see CLEANUP_PLAN.md)"
echo "2. Address iOS dependency blocker (see BUILD_FAILURES_REPORT.md)"
echo "3. Push Android DEX fix (run ./commit-android-dex-fix.sh)"
echo ""
```

---

## Expected Timeline

| Task | Time | Priority |
|------|------|----------|
| Check and fix/disable CodeQL | 15 min | HIGH |
| Choose iOS strategy | 5 min | HIGH |
| Push Android DEX fix | 5 min | HIGH |
| Verify builds pass | 30 min | HIGH |
| **TOTAL IMMEDIATE** | **~1 hour** | |
| | | |
| Contact commons-wallet maintainers | 30 min | MEDIUM |
| Documentation cleanup | 1 hour | MEDIUM |
| Dependency audit | 1 hour | LOW |

---

## Success Criteria

✅ **Cleanup Complete When:**
1. All GitHub Actions workflows pass (except iOS if disabled)
2. Android builds successfully produce APK/AAB
3. Desktop builds produce DMG/MSI/DEB
4. Web build produces WASM bundle
5. No failing CI/CD jobs
6. Documentation is up-to-date
7. Repository is ready for production deployment

---

## Notes

**About CodeQL:**
- CodeQL is GitHub's semantic code analysis engine
- Often auto-enabled for public repositories
- Provides security vulnerability scanning
- Can fail on Kotlin Multiplatform projects if not configured correctly
- Not required for builds to work - can be disabled

**About commons-wallet:**
- Third-party ATTO cryptocurrency library
- Outside our control
- iOS support requires upstream changes
- Android/Desktop/Web work fine with current version

**Priority:**
1. Get builds passing (CodeQL, Android DEX)
2. Deploy working platforms (Android, Desktop, Web)
3. Address iOS when upstream library is ready
