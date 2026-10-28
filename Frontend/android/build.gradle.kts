allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Flutter 3.47+ defaults flutter.ndkVersion to 28.2.13676358, but the jni package
// inherits it via `ndkVersion = flutter.ndkVersion`. Override to use locally
// installed NDK 27.2.12479018 for all subprojects that pick up the Flutter default.
subprojects {
    afterEvaluate {
        val androidExt = extensions.findByName("android")
        if (androidExt != null) {
            val currentNdk = (androidExt as com.android.build.gradle.BaseExtension).ndkVersion
            if (currentNdk == "28.2.13676358") {
                (androidExt as com.android.build.gradle.BaseExtension).ndkVersion = "27.2.12479018"
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
