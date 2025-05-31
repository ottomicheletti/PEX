//plugins {
//    id("com.android.application")
//    // START: FlutterFire Configuration
//    id("com.google.gms.google-services")
//    // END: FlutterFire Configuration
//    id("kotlin-android")
//    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
//    id("dev.flutter.flutter-gradle-plugin")
//}
//
//android {
//    namespace = "com.catolica.agpop"
//    compileSdk = flutter.compileSdkVersion
//    ndkVersion = "27.0.12077973"
//
//    compileOptions {
//        sourceCompatibility = JavaVersion.VERSION_11
//        targetCompatibility = JavaVersion.VERSION_11
//    }
//
//    kotlinOptions {
//        jvmTarget = JavaVersion.VERSION_11.toString()
//    }
//
//    defaultConfig {
//        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
//        applicationId = "com.catolica.agpop"
//        // You can update the following values to match your application needs.
//        // For more information, see: https://flutter.dev/to/review-gradle-config.
//        minSdk = 23
////        minSdkVersion = 23
//        targetSdk = flutter.targetSdkVersion
//        versionCode = flutter.versionCode
//        versionName = flutter.versionName
//    }
//
//    buildTypes {
//        release {
//            // TODO: Add your own signing config for the release build.
//            // Signing with the debug keys for now, so `flutter run --release` works.
//            signingConfig = signingConfigs.getByName("debug")
//        }
//    }
//}
//
//flutter {
//    source = "../.."
//}

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.catolica.agpop"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    // --- START: Core Library Desugaring configuration ---
    compileOptions {
        // Enable core library desugaring
        isCoreLibraryDesugaringEnabled = true
        // Set Java compatibility to 1.8 (Java 8) as required by desugaring
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        // Ensure JVM target also matches Java 8 for consistency with desugaring
        jvmTarget = JavaVersion.VERSION_1_8.toString()
    }
    // --- END: Core Library Desugaring configuration ---

    defaultConfig {
        applicationId = "com.catolica.agpop"
        minSdk = 23 // Correctly set
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// --- ADD THIS DEPENDENCIES BLOCK HERE ---
dependencies {
    // This is the actual library that provides the desugared APIs
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4") // Use latest stable version
}