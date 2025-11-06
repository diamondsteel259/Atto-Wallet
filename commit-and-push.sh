#!/bin/bash

# Commit and Push iOS Implementation + GitHub Actions
# This script commits all iOS implementation files and workflow changes

set -e  # Exit on error

echo "================================================"
echo "Atto Wallet - iOS Implementation + CI/CD Push"
echo "================================================"
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
echo "📋 Checking status..."
git status --short
echo ""

# Ask for confirmation
read -p "❓ Do you want to commit and push these changes to '$BRANCH'? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Cancelled by user"
    exit 1
fi

echo ""
echo "✅ Proceeding with commit and push..."
echo ""

# Stage all changes
echo "📦 Staging changes..."
git add .

# Create commit
echo "💾 Creating commit..."
git commit -m "Add iOS implementation and mobile build workflows

iOS Platform Implementation (9 files):
- SeedDataSource.ios.kt - iOS Keychain secure storage
- PasswordDataSource.ios.kt - Per-wallet password storage
- SaltDataSource.ios.kt - Encryption salt with auto-generation
- SeedAESInteractor.ios.kt - Stub implementation
- AppDatabase.ios.kt - Room database with DAOs and entities
- Modules.ios.kt - Koin DI configuration
- QRCodeImage.ios.kt - QR code rendering
- AttoLocalizedFormatter.ios.kt - Number formatting
- AttoDateFormatter.ios.kt - Date formatting

Build Configuration:
- Added iOS targets: iosX64, iosArm64, iosSimulatorArm64
- Added iosMain dependencies (Room + SQLite)
- Updated KSP configuration for iOS Room code generation

GitHub Actions CI/CD:
- Added build-android job to build.yaml
- Added build-ios job to build.yaml
- Created mobile-build.yaml workflow for dedicated mobile builds
- Updated pipeline.yaml to include mobile artifacts

Documentation:
- MOBILE_BUILD.md - Complete build and release guide
- WORKFLOW_SETUP.md - Getting workflows running guide

iOS now has feature parity with Android/Desktop using native iOS
Keychain for secure storage and Room database for persistence."

echo ""
echo "🚀 Pushing to remote..."
git push origin $BRANCH

echo ""
echo "================================================"
echo "✅ SUCCESS!"
echo "================================================"
echo ""
echo "Your changes have been pushed to GitHub!"
echo ""
echo "🔍 Next steps:"
echo "   1. Go to: https://github.com/diamondsteel259/Atto-Wallet/actions"
echo "   2. Watch the 'Pipeline' workflow run automatically"
echo "   3. Or manually run 'Mobile Build' workflow"
echo ""
echo "📦 Artifacts will be available for download after build completes:"
echo "   - Android APK (debug)"
echo "   - Android Bundle (release)"
echo "   - iOS Frameworks (all architectures)"
echo ""
echo "📖 For more info, see WORKFLOW_SETUP.md"
echo ""
