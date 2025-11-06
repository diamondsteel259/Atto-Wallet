#!/bin/bash

# Commit and Push Android DEX Fix
# This script commits ProGuard configuration to fix Android DEX build errors

set -e  # Exit on error

echo "========================================================"
echo "Atto Wallet - Android DEX Fix"
echo "========================================================"
echo ""

# Check if we're in a git repository
if [ ! -d .git ]; then
    echo "❌ Error: Not in a git repository"
    echo "Run this script from the Atto-Wallet directory"
    exit 1
fi

# Show current branch
BRANCH=$(git branch --show-current)
echo "📍 Current branch: $BRANCH"
echo ""

# Check git status
echo "📋 Changes to be committed:"
git status --short
echo ""

# Ask for confirmation
read -p "❓ Commit and push Android DEX fix to '$BRANCH'? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Cancelled by user"
    exit 1
fi

echo ""
echo "✅ Proceeding with commit and push..."
echo ""

# Stage the changes
echo "📦 Staging changes..."
git add composeApp/build.gradle.kts
git add composeApp/proguard-rules.pro
git add BUILD_FAILURES_REPORT.md

# Create commit
echo "💾 Creating commit..."
git commit -m "Fix Android DEX build error with ProGuard configuration

Android Build Issue:
- DEX compilation was failing with \"Space characters in SimpleName\" error
- Method count exceeded 65K limit (Android DEX limitation)
- ktor-client-core-jvm had malformed class names with spaces

Solution Implemented:
- Added comprehensive ProGuard rules (proguard-rules.pro)
- Enabled R8 code shrinking for release builds
- ProGuard configuration includes:
  * Keep rules for Atto Wallet classes
  * Keep rules for critical dependencies (Compose, Ktor, Room, Koin)
  * Aggressive optimization with proper exclusions
  * Logging removal in release builds

Files Changed:
- composeApp/build.gradle.kts: Enabled minification for release builds
- composeApp/proguard-rules.pro: Comprehensive ProGuard rules (NEW FILE)
- BUILD_FAILURES_REPORT.md: Detailed analysis of both build failures (NEW FILE)

Expected Outcome:
- Release builds will use R8 to shrink code below 65K method limit
- Malformed ktor classes handled by obfuscation
- Debug builds remain fast with MultiDex enabled
- Smaller, more optimized APK/AAB files

Note: iOS builds still blocked by upstream dependency issue (see BUILD_FAILURES_REPORT.md)

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

echo ""
echo "🚀 Pushing to remote..."
git push origin $BRANCH

echo ""
echo "========================================================"
echo "✅ ANDROID DEX FIX PUSHED!"
echo "========================================================"
echo ""
echo "📊 What was fixed:"
echo "   ✅ Added ProGuard rules to shrink Android code"
echo "   ✅ Enabled R8 minification for release builds"
echo "   ✅ Comprehensive keep rules for all dependencies"
echo "   ✅ Debug builds remain fast with MultiDex"
echo ""
echo "🔍 Next steps:"
echo "   1. Monitor GitHub Actions for Android build"
echo "   2. Workflow should build successfully now"
echo "   3. Download APK/AAB artifacts after build completes"
echo ""
echo "⚠️  iOS builds still blocked:"
echo "   - See BUILD_FAILURES_REPORT.md for details"
echo "   - Upstream library (cash.atto:commons-wallet) needs iOS support"
echo "   - Android can be deployed independently"
echo ""
echo "📖 For complete details, see BUILD_FAILURES_REPORT.md"
echo ""
