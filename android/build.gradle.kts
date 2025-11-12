allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    configurations.all {
        resolutionStrategy {
            force("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.5.2")
            force("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.5.2")
            force("io.ktor:ktor-client-core:1.6.8")
            force("io.ktor:ktor-client-android:1.6.8")
            force("io.ktor:ktor-client-logging:1.6.8")
            force("io.ktor:ktor-client-json:1.6.8")
            force("io.ktor:ktor-client-serialization:1.6.8")
        }
    }
}
subprojects {
    configurations.all {
        resolutionStrategy {
            // Force versions to include ExperimentalCoroutineDispatcher
            force("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.5.2")
            force("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.5.2")
            // Force Ktor 1.6.x that Twilio expects
            force("io.ktor:ktor-client-core:1.6.8")
            force("io.ktor:ktor-client-android:1.6.8")
        }
    }
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
