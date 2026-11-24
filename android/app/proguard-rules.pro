# Reglas de R8/ProGuard para compilaciones release de ReParte.
# Los plugins de Firebase y Flutter agregan sus propias consumer rules;
# aqui protegemos clases de Flutter y utilidades de serializacion.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# Compatibilidad con Gson (usado por plugins como flutter_local_notifications).
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**

# Flutter referencia Play Core para deferred components (no usados en ReParte).
-dontwarn com.google.android.play.core.**

