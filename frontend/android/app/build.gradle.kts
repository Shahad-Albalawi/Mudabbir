plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.mudabbir.app"
    compileSdk = flutter.compileSdkVersion
    // Work around corrupted SDK Build-Tools 35.0.0 on some machines; use an installed revision.
    buildToolsVersion = "36.1.0"
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.mudabbir.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
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
            signingConfig = when {
                keystorePropertiesFile.exists() -> signingConfigs.getByName("release")
                System.getenv("CI") != null -> throw GradleException(
                    "Release signing requires frontend/android/key.properties on CI. " +
                        "Copy key.properties.example and configure upload keystore secrets."
                )
                else -> {
                    // Local dev only: debug keystore until key.properties is configured.
                    signingConfigs.getByName("debug")
                }
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

// Flutter CLI expects APKs under `<project>/build/app/outputs/flutter-apk/`, while AGP 8+
// may leave copies only under `android/app/build/...`. Mirror them so `flutter run` works.
afterEvaluate {
    val mirrorApksToFlutterToolPath = {
        val toolOutDir = rootProject.projectDir.parentFile.resolve("build/app/outputs/flutter-apk")
        toolOutDir.mkdirs()
        val pluginDir = project.layout.buildDirectory.get().asFile.resolve("outputs/flutter-apk")
        pluginDir.takeIf { it.isDirectory }?.listFiles()
            ?.filter { it.isFile && it.extension == "apk" }
            ?.forEach { apk ->
                apk.copyTo(toolOutDir.resolve(apk.name), overwrite = true)
            }
    }
    listOf("assembleDebug", "assembleRelease").forEach { taskName ->
        tasks.named(taskName).configure { doLast { mirrorApksToFlutterToolPath() } }
    }
    tasks.findByName("assembleProfile")?.let {
        tasks.named("assembleProfile").configure { doLast { mirrorApksToFlutterToolPath() } }
    }
}
