import java.util.Properties
import java.io.FileInputStream

val keystorePropertiesFile = file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
val keystoreFilePath = (keystoreProperties["RELEASE_STORE_FILE"] as String?)?.trim()
val resolvedKeystoreFile = if (keystoreFilePath != null && keystoreFilePath.isNotBlank()) file(keystoreFilePath) else null

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.mm.one_x"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.mm.one_x"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (resolvedKeystoreFile == null) throw GradleException("RELEASE_STORE_FILE is missing or empty in key.properties")
            val storePassword = keystoreProperties["RELEASE_STORE_PASSWORD"] as String?
            val keyAlias = keystoreProperties["RELEASE_KEY_ALIAS"] as String?
            val keyPassword = keystoreProperties["RELEASE_KEY_PASSWORD"] as String?
            if (storePassword.isNullOrBlank()) throw GradleException("RELEASE_STORE_PASSWORD is missing or empty in key.properties")
            if (keyAlias.isNullOrBlank()) throw GradleException("RELEASE_KEY_ALIAS is missing or empty in key.properties")
            if (keyPassword.isNullOrBlank()) throw GradleException("RELEASE_KEY_PASSWORD is missing or empty in key.properties")
            storeFile = resolvedKeystoreFile
            this.storePassword = storePassword
            this.keyAlias = keyAlias
            this.keyPassword = keyPassword
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
        }
    }
}

flutter {
    source = "../.."
}
