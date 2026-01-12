import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.jnkundu.jnk_app"
    // compileSdk = flutter.compileSdkVersion
    compileSdk = 36
    // ndkVersion = flutter.ndkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.jnkundu.jnk_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // minSdk = flutter.minSdkVersion
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        // targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("release")
        }
        debug {
            isMinifyEnabled = false
        }
    }

    dependencies {
        // --- Firebase BoM ---
        implementation(platform("com.google.firebase:firebase-bom:34.4.0"))
        implementation("com.google.firebase:firebase-crashlytics")
        implementation("com.google.firebase:firebase-analytics")

        // --- Twilio + coroutine compatibility fixes ---
        // Force Twilio-compatible coroutine version
        implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.5.2")
        implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.5.2")

        // Force compatible Ktor versions used internally by Twilio
        implementation("io.ktor:ktor-client-core:1.6.8")
        implementation("io.ktor:ktor-client-android:1.6.8")

        // Ensure logging + JSON features
        implementation("io.ktor:ktor-client-logging:1.6.8")
        implementation("io.ktor:ktor-client-json:1.6.8")
        implementation("io.ktor:ktor-client-serialization:1.6.8")

        implementation("org.slf4j:slf4j-api:1.7.36")
        implementation("org.slf4j:slf4j-simple:1.7.36")
    }

    configurations.all {
        resolutionStrategy.eachDependency {
            if (requested.group == "org.jetbrains.kotlinx" && requested.name.startsWith("kotlinx-coroutines")) {
                useVersion("1.5.2")
                because("Twilio SDK requires ExperimentalCoroutineDispatcher from coroutines 1.5.x")
            }
        }
    }

    packagingOptions {
        jniLibs {
            useLegacyPackaging = false
        }
    }

    // packaging {
        // resources {
            // excludes += "META-INF/DEPENDENCIES"
        // }
    // }
}

flutter {
    source = "../.."
}
