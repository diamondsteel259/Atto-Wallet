#!/bin/bash

# Temporarily Disable iOS Targets
# This script comments out iOS configuration to unblock Android/Desktop/Web builds
# Run this if you need to deploy other platforms before iOS dependency is resolved

set -e

echo "========================================================"
echo "Temporarily Disable iOS Targets"
echo "========================================================"
echo ""
echo "⚠️  WARNING: This will disable iOS builds temporarily"
echo "This is needed because cash.atto:commons-wallet doesn't support iOS yet"
echo ""
echo "What this script does:"
echo "  1. Comments out iOS target declarations"
echo "  2. Comments out iosMain dependencies"
echo "  3. Comments out iOS KSP configuration"
echo "  4. Removes iOS build job from workflows"
echo ""
echo "This allows Android, Desktop, and Web to build successfully."
echo ""

read -p "❓ Continue with disabling iOS? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Cancelled by user"
    exit 1
fi

echo ""
echo "📝 Creating backup..."
cp composeApp/build.gradle.kts composeApp/build.gradle.kts.backup
cp .github/workflows/build.yaml .github/workflows/build.yaml.backup

echo "✏️  Commenting out iOS targets in build.gradle.kts..."

# Comment out iOS targets
sed -i.tmp 's/^    iosX64()/    \/\/ iosX64()  \/\/ Temporarily disabled - commons-wallet needs iOS support/' composeApp/build.gradle.kts
sed -i.tmp 's/^    iosArm64()/    \/\/ iosArm64()  \/\/ Temporarily disabled/' composeApp/build.gradle.kts
sed -i.tmp 's/^    iosSimulatorArm64()/    \/\/ iosSimulatorArm64()  \/\/ Temporarily disabled/' composeApp/build.gradle.kts

# Comment out iosMain dependencies block
sed -i.tmp '/val iosMain by getting/,/^    }$/ s/^/    \/\/ /' composeApp/build.gradle.kts

# Comment out iOS KSP configuration
sed -i.tmp 's/"kspIosX64",/\/\/ "kspIosX64",  \/\/ Temporarily disabled/' composeApp/build.gradle.kts
sed -i.tmp 's/"kspIosArm64",/\/\/ "kspIosArm64",/' composeApp/build.gradle.kts
sed -i.tmp 's/"kspIosSimulatorArm64",/\/\/ "kspIosSimulatorArm64",/' composeApp/build.gradle.kts

rm composeApp/build.gradle.kts.tmp

echo "✏️  Commenting out iOS build job in workflows..."

# Comment out iOS build job in build.yaml
sed -i.tmp '/build-ios:/,/^$/ s/^/  # /' .github/workflows/build.yaml
rm .github/workflows/build.yaml.tmp

echo ""
echo "✅ iOS targets temporarily disabled"
echo ""
echo "📋 Changes made:"
echo "   • iOS targets commented out in build.gradle.kts"
echo "   • iosMain dependencies commented out"
echo "   • iOS KSP configuration commented out"
echo "   • iOS build job commented out in workflows"
echo ""
echo "💾 Backups created:"
echo "   • composeApp/build.gradle.kts.backup"
echo "   • .github/workflows/build.yaml.backup"
echo ""
echo "🔄 To re-enable iOS later:"
echo "   1. Uncomment all iOS lines in build.gradle.kts"
echo "   2. Uncomment iOS build job in build.yaml"
echo "   Or restore from backups"
echo ""
echo "📤 Next steps:"
echo "   1. Review the changes: git diff"
echo "   2. Test locally: ./gradlew tasks"
echo "   3. Commit: git add . && git commit -m 'Temporarily disable iOS targets'"
echo "   4. Push: git push origin main"
echo ""
