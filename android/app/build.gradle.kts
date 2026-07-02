import java.util.Properties

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseKeystoreProperties = Properties()
val releaseKeystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKeystoreProperties = releaseKeystorePropertiesFile.exists()

if (hasReleaseKeystoreProperties) {
    releaseKeystorePropertiesFile.inputStream().use {
        releaseKeystoreProperties.load(it)
    }
}

fun releaseKeystoreProperty(name: String): String? =
    releaseKeystoreProperties.getProperty(name)?.trim()?.takeIf { it.isNotEmpty() }

val releaseStoreFile = releaseKeystoreProperty("storeFile")?.let { file(it) }
val hasCompleteReleaseSigning =
    hasReleaseKeystoreProperties &&
        releaseStoreFile?.exists() == true &&
        releaseKeystoreProperty("storePassword") != null &&
        releaseKeystoreProperty("keyPassword") != null &&
        releaseKeystoreProperty("keyAlias") != null

android {
    namespace = "com.faddgraphics.faddompet"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.faddgraphics.faddompet"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasCompleteReleaseSigning) {
            create("release") {
                storeFile = releaseStoreFile
                storePassword = releaseKeystoreProperty("storePassword")
                keyPassword = releaseKeystoreProperty("keyPassword")
                keyAlias = releaseKeystoreProperty("keyAlias")
            }
        }
    }

    buildTypes {
        release {
            signingConfig =
                if (hasCompleteReleaseSigning) {
                    signingConfigs.getByName("release")
                } else {
                    logger.warn(
                        "Release keystore not configured. Using debug signing for local developer build. Create android/key.properties and a release keystore before publishing.",
                    )
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

dependencies {
    implementation("androidx.core:core:1.17.0")
}
