plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("kotlin-kapt")
}

android {
    namespace = "app.saltamontes"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"
    //ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "app.saltamontes"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ... Tus dependencias existentes ...
    
    // --- DECLARACIÓN DE VARIABLES EN KOTLIN DSL ---
    val room_version = "2.6.1" 
    
    // --- DEPENDENCIAS DE UBICACIÓN (LocationService.kt) ---
    // En Kotlin DSL, las strings simples requieren comillas dobles, y la llamada es un método.
    implementation("com.google.android.gms:play-services-location:21.0.1")

    // --- DEPENDENCIAS DE ROOM (Persistencia) ---
    // Core de Room
    implementation("androidx.room:room-runtime:$room_version")
    
    // Generador de código (kapt en Groovy se convierte en una llamada de método)
    kapt("androidx.room:room-compiler:$room_version")
    
    // Extensiones de Kotlin para Room
    implementation("androidx.room:room-ktx:$room_version")
}