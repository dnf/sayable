plugins {
    kotlin("jvm") version "2.3.10"
    `maven-publish`
    signing
}

group = "com.github.dnf"
version = "0.1.0"

repositories {
    mavenCentral()
}

description = "Human-friendly age formatting the way parents actually talk"

java {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
    withSourcesJar()
    withJavadocJar()
}

kotlin {
    explicitApi()
}

tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile> {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        allWarningsAsErrors.set(true)
        progressiveMode.set(true)
        freeCompilerArgs.addAll(
            "-Xjsr305=strict"       // strict nullability for Java interop
        )
    }
}

dependencies {
    testImplementation(kotlin("test"))
    testImplementation("org.junit.jupiter:junit-jupiter:5.10.1")
}

tasks.test {
    useJUnitPlatform()
}

publishing {
    publications {
        create<MavenPublication>("maven") {
            from(components["java"])

            pom {
                name.set("parent-time")
                description.set("Human-friendly age formatting the way parents actually talk")
                url.set("https://github.com/dnf/parent-time")

                licenses {
                    license {
                        name.set("MIT License")
                        url.set("https://opensource.org/licenses/MIT")
                    }
                }

                developers {
                    developer {
                        name.set("Don Neufeld")
                    }
                }

                scm {
                    url.set("https://github.com/dnf/parent-time")
                    connection.set("scm:git:git://github.com/dnf/parent-time.git")
                    developerConnection.set("scm:git:ssh://github.com/dnf/parent-time.git")
                }
            }
        }
    }
}

signing {
    // Only sign when publishing to Maven Central (requires GPG key)
    isRequired = gradle.taskGraph.hasTask("publishToSonatype")
    sign(publishing.publications["maven"])
}
