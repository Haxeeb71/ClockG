# Keep Flutter classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep notifications and alarm manager related
-keep class com.dexterous.** { *; }
-keep class dev.fluttercommunity.plus.androidalarmmanager.** { *; }

# Keep sqflite
-keep class com.tekartik.sqflite.** { *; }

# Keep audioplayers
-keep class xyz.luan.audioplayers.** { *; }

# Flutter deferred components reference Google Play Core; suppress missing classes since we don't use dynamic features
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.play.core.install.**
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-dontwarn io.flutter.embedding.engine.deferredcomponents.**
