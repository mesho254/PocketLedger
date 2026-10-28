allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Flutter 3.47+ defaults flutter.ndkVersion to 28.2.13676358, but the jni package
// inherits it via `ndkVersion = flutter.ndkVersion`. Override to use locally
// installed NDK 27.2.12479018 for all subprojects that pick up the Flutter default.
subprojects {
    if (project.name != "app") {
        afterEvaluate {
            val androidExt = extensions.findByName("android")
            if (androidExt is com.android.build.gradle.BaseExtension) {
                androidExt.ndkVersion = "27.2.12479018"
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
