import org.jetbrains.kotlin.gradle.tasks.KotlinCompile
import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.examplee.al_haiwan"

    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        // 🔥 Java 18 (matches your installed JDK)
        sourceCompatibility = JavaVersion.VERSION_18
        targetCompatibility = JavaVersion.VERSION_18
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.examplee.al_haiwan"
        minSdk = flutter.minSdkVersion
        // Updated target SDK to meet Play Store requirement (at least 35)
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Load keystore properties if present (keystore file should be listed in .gitignore)
    val keystorePropertiesFile = rootProject.file("key.properties")
    val keystoreProperties = Properties()
    if (keystorePropertiesFile.exists()) {
        keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it as String) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        release {
            // adjust minify/shrinker settings as needed for your app
            isMinifyEnabled = false
            // Ensure resource shrinking is disabled when code shrinking (minification) is disabled
            // Prevents: "Removing unused resources requires unused code shrinking to be turned on"
            isShrinkResources = false
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

/**
 * ✅ NEW, NON-DEPRECATED Kotlin configuration
 * ✅ Matches Java 18
 * ✅ Fixes JVM mismatch permanently
 */
tasks.withType<KotlinCompile>().configureEach {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_18)
    }
}
