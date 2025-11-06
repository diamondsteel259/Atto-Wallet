#!/bin/bash

# Commit and Push iOS Disable Changes
# This commits the iOS disable changes to fix builds

set -e

echo "========================================================"
echo "Commit iOS Disable Changes"
echo "========================================================"
echo ""

echo "📋 Changes to commit:"
echo "  ✓ build.gradle.kts - iOS targets commented out"
echo "  ✓ build.yaml - iOS build job commented out"
echo "  ✓ pipeline.yaml - iOS artifacts removed from release"
echo ""

# Stage the changes
echo "📦 Staging changes..."
git add composeApp/build.gradle.kts
git add .github/workflows/build.yaml
git add .github/workflows/pipeline.yaml

# Create commit
echo "💾 Creating commit..."
git commit -m "Temporarily disable iOS targets until commons-wallet adds support

The cash.atto:commons-wallet library does not publish iOS artifacts,
which blocks iOS builds at dependency resolution. This commit temporarily
disables iOS targets to allow Android, Desktop, and Web to build successfully.

Changes:
- Commented out iOS targets in build.gradle.kts (iosX64, iosArm64, iosSimulatorArm64)
- Commented out iosMain dependencies block
- Commented out iOS KSP configuration
- Commented out iOS build job in workflows/build.yaml
- Removed iOS artifacts from pipeline release

iOS implementation code remains intact. When commons-wallet library adds
iOS support, uncomment these lines to re-enable iOS builds.

See BUILD_FAILURES_REPORT.md for detailed analysis and solutions.

Android DEX fix (ProGuard) already applied in previous commits.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

echo ""
echo "🚀 Pushing to GitHub..."
git push origin main

echo ""
echo "========================================================"
echo "✅ DONE! iOS TEMPORARILY DISABLED"
echo "========================================================"
echo ""
echo "📊 What was changed:"
echo "   ✓ iOS targets commented out in build.gradle.kts"
echo "   ✓ iOS build job disabled in GitHub Actions"
echo "   ✓ iOS artifacts removed from release pipeline"
echo ""
echo "🎯 Expected results in GitHub Actions:"
echo "   ✅ Android - Should build successfully (ProGuard fix applied)"
echo "   ✅ Desktop (Linux/Mac/Windows) - Should build successfully"
echo "   ✅ Web (WASM) - Should build successfully"
echo "   ⏸️  iOS - Disabled (no build job runs)"
echo ""
echo "📥 After successful build, download artifacts:"
echo "   • android-apk (Debug APK for testing)"
echo "   • android-bundle (Release AAB for Play Store)"
echo "   • linux (DEB package)"
echo "   • macos (DMG installer)"
echo "   • windows (MSI installer)"
echo "   • web (WASM bundle)"
echo ""
echo "🔮 To re-enable iOS in the future:"
echo "   1. Wait for commons-wallet library to add iOS support"
echo "   2. Uncomment iOS lines in build.gradle.kts"
echo "   3. Uncomment iOS build job in workflows/build.yaml"
echo "   4. Uncomment iOS artifacts in pipeline.yaml"
echo "   5. Push and iOS will build"
echo ""
echo "📖 For details, see BUILD_FAILURES_REPORT.md"
echo ""
