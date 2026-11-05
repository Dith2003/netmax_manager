import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Firma de la versión instalable. Se toma de android/key.properties (en tu equipo, no se
// sube a GitHub) o de variables de entorno (secretos del flujo de GitHub Actions).
// Si no hay llave, se firma con la de depuración (solo sirve para versiones de prueba).
val llave = Properties().apply {
    val archivo = rootProject.file("key.properties")
    if (archivo.exists()) archivo.inputStream().use { load(it) }
}
fun datoLlave(propiedad: String, variable: String): String? =
    llave.getProperty(propiedad) ?: System.getenv(variable)
val archivoLlave = datoLlave("storeFile", "NETMAX_KEYSTORE")
val hayLlave = archivoLlave != null && file(archivoLlave).exists()

android {
    namespace = "com.netmax.netmax_manager"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // No cambiar: con este id Android reconoce las actualizaciones de la app.
        applicationId = "com.netmax.netmax_manager"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hayLlave) {
            create("netmax") {
                storeFile = file(archivoLlave!!)
                storePassword = datoLlave("storePassword", "NETMAX_KEYSTORE_PASSWORD")
                keyAlias = datoLlave("keyAlias", "NETMAX_KEY_ALIAS")
                keyPassword = datoLlave("keyPassword", "NETMAX_KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hayLlave) {
                signingConfigs.getByName("netmax")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
