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
}
subprojects {
    // NOTE: this used to force kotlinx-coroutines 1.5.2 and ktor 1.6.8, which
    // Twilio Conversations 1.6.0 required. The vendored plugin now uses
    // conversations-android 6.2.1, which needs ktor 3.x and coroutines 1.8+;
    // re-adding those forces will make the chat client fail at runtime.
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
