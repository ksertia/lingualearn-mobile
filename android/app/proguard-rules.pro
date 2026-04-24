# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.**

# Kotlin coroutines
-keep class kotlinx.coroutines.** { *; }
-dontwarn kotlinx.coroutines.**

# GetX
-keep class com.example.** { *; }

# Dio / OkHttp
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# Gson / JSON
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

# Video player (ExoPlayer)
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**

# Audio players
-keep class xyz.luan.audioplayers.** { *; }
-dontwarn xyz.luan.audioplayers.**

# Local notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# Stripe
-keep class com.stripe.android.** { *; }
-dontwarn com.stripe.android.**

# BouncyCastle / Stripe crypto (classes Java SE absentes sur Android)
-dontwarn javax.naming.NamingEnumeration
-dontwarn javax.naming.NamingException
-dontwarn javax.naming.directory.Attribute
-dontwarn javax.naming.directory.Attributes
-dontwarn javax.naming.directory.DirContext
-dontwarn javax.naming.directory.InitialDirContext
-dontwarn javax.naming.directory.SearchControls
-dontwarn javax.naming.directory.SearchResult
-dontwarn net.jcip.annotations.Immutable
-dontwarn net.jcip.annotations.NotThreadSafe
-dontwarn net.jcip.annotations.ThreadSafe
-dontwarn org.bouncycastle.**

# File picker
-keep class com.mr.flutter.plugin.filepicker.** { *; }

# Image picker / Cached network image
-keep class io.flutter.plugins.imagepicker.** { *; }

# WebSocket / STOMP
-keep class ua.valeriishymchuk.stomp_dart_client.** { *; }
-dontwarn ua.valeriishymchuk.**

# Shared preferences / GetStorage
-keep class com.tekartik.sqflite.** { *; }

# Remove debug logs in release
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelable
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
