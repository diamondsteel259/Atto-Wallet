# ProGuard Rules for Atto Wallet
# These rules ensure proper code shrinking while keeping necessary classes

# ============================================================================
# Atto Wallet Application Classes
# ============================================================================

# Keep all Atto Wallet classes and members
-keep class cash.atto.wallet.** { *; }

# Keep Atto Commons Wallet library (cryptocurrency operations)
-keep class cash.atto.commons.** { *; }
-dontwarn cash.atto.commons.**

# ============================================================================
# Jetpack Compose
# ============================================================================

# Keep Compose runtime and UI classes
-keep class androidx.compose.** { *; }
-dontwarn androidx.compose.**

# Keep Compose compiler annotations
-keepattributes *Annotation*

# ============================================================================
# Kotlin
# ============================================================================

# Keep Kotlin metadata for reflection
-keep class kotlin.Metadata { *; }
-keep class kotlin.** { *; }
-dontwarn kotlin.**

# Keep Kotlin coroutines
-keep class kotlinx.coroutines.** { *; }
-dontwarn kotlinx.coroutines.**

# ============================================================================
# Kotlinx Serialization
# ============================================================================

# Keep serialization annotations
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.AnnotationsKt

# Keep serializers
-keepclassmembers class kotlinx.serialization.json.** {
    *** Companion;
}
-keepclasseswithmembers class kotlinx.serialization.json.** {
    kotlinx.serialization.KSerializer serializer(...);
}

# Keep @Serializable classes
-keepclassmembers @kotlinx.serialization.Serializable class ** {
    *** Companion;
    *** INSTANCE;
    kotlinx.serialization.KSerializer serializer(...);
}

# Keep generated serializers
-keep,includedescriptorclasses class cash.atto.wallet.**$$serializer { *; }
-keepclassmembers class cash.atto.wallet.** {
    *** Companion;
}

# ============================================================================
# Ktor HTTP Client
# ============================================================================

# Keep Ktor classes (network communication)
-keep class io.ktor.** { *; }
-dontwarn io.ktor.**

# Fix for "Space characters in SimpleName" DEX error
-keep,allowobfuscation class io.ktor.** { *; }

# ============================================================================
# Room Database
# ============================================================================

# Keep Room database classes
-keep class * extends androidx.room.RoomDatabase
-keep @androidx.room.Entity class *
-keep @androidx.room.Dao class *
-dontwarn androidx.room.**

# Keep Room entity fields
-keepclassmembers class * {
    @androidx.room.* <fields>;
}

# Keep Room DAO methods
-keepclassmembers interface * {
    @androidx.room.* <methods>;
}

# ============================================================================
# Koin Dependency Injection
# ============================================================================

# Keep Koin classes
-keep class org.koin.** { *; }
-keep class org.koin.core.** { *; }
-keep class org.koin.androidx.** { *; }
-dontwarn org.koin.**

# Keep Koin module definitions
-keepclassmembers class * {
    public <init>(...);
}

# ============================================================================
# Android Architecture Components
# ============================================================================

# Keep ViewModel classes
-keep class * extends androidx.lifecycle.ViewModel {
    <init>(...);
}
-keep class androidx.lifecycle.** { *; }
-dontwarn androidx.lifecycle.**

# Keep LiveData
-keep class * extends androidx.lifecycle.LiveData {
    <init>(...);
}

# ============================================================================
# AndroidX Core Libraries
# ============================================================================

# Keep AndroidX classes
-keep class androidx.core.** { *; }
-keep class androidx.activity.** { *; }
-keep class androidx.fragment.** { *; }
-dontwarn androidx.**

# ============================================================================
# ML Kit Barcode Scanning
# ============================================================================

# Keep ML Kit classes (QR code scanning)
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# Keep Google ML classes
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# ============================================================================
# CameraX
# ============================================================================

# Keep CameraX classes
-keep class androidx.camera.** { *; }
-dontwarn androidx.camera.**

# ============================================================================
# Security and Cryptography
# ============================================================================

# Keep security classes (Keystore access)
-keep class javax.crypto.** { *; }
-keep class javax.security.** { *; }
-keep class java.security.** { *; }
-dontwarn javax.crypto.**
-dontwarn javax.security.**

# ============================================================================
# Reflection and Annotations
# ============================================================================

# Keep annotation attributes for reflection
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# ============================================================================
# Logging (Remove in Release)
# ============================================================================

# Remove all logging calls in release builds for better performance
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
    public static *** w(...);
}

# Remove println statements
-assumenosideeffects class kotlin.io.ConsoleKt {
    public static *** println(...);
}

# ============================================================================
# General Rules
# ============================================================================

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelables
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# ============================================================================
# Optimization Settings
# ============================================================================

# Enable aggressive optimization
-optimizationpasses 5
-allowaccessmodification
-dontpreverify

# Optimization filters
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
