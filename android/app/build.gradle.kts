plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
        import java.io.FileInputStream

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localProperties.load(FileInputStream(localPropertiesFile))
}

val flutterVersionCode = localProperties.getProperty("flutter.versionCode") ?: "1"
val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0"

// load key store for signing if key store file exists
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use {
        keystoreProperties.load(it)
    }
}

android {
    namespace = "de.tu_chemnitz.etit.sse.openstop"
    compileSdk = 36
    // Momentary fix. Alternatively the following line can also be commented out. See: https://github.com/flutter/flutter/issues/139427
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    sourceSets["main"].java.srcDirs("src/main/kotlin")

    defaultConfig {
        applicationId = "de.tu_chemnitz.etit.sse.openstop"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // properties of 'signingConfigs' are definied in /android/key.properties
    // a key.properties file needs to be created referencing the key(store) bound with verified app links
    signingConfigs {
        create("general") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    // due to using verified app links the app has to be signed with a certain key to be able to login to OSM
    // to enable login a certain 'signingConfigs' needs to be referenced for 'release' and 'debug'
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("general")
        }
        debug {
            // if key store file does not exist sign with debug keys
            signingConfig = if (keystorePropertiesFile.exists()) signingConfigs.getByName("general") else signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
