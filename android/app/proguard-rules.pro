# Flutter / Plugin rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# audioplayers
-keep class xyz.luan.** { *; }

# flutter_tts
-keep class com.tundralabs.fluttertts.** { *; }

# record
-keep class com.llfbandit.record.** { *; }

# permission_handler
-keep class com.baseflow.permissionhandler.** { *; }

# shared_preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# path_provider
-keep class io.flutter.plugins.pathprovider.** { *; }

# flutter_svg / xml
-keep class com.caverock.androidsvg.** { *; }

# Kotlin (defensive)
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keepattributes Signature

# Google Play Core — referenciado por el embedding de Flutter pero NO usamos
# carga dinámica de features, así que avisamos a R8 que no se queje.
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
