plugins {
    scala
    `maven-publish`
    signing
}

group = "com.github.dnf"
version = "0.5.0"

repositories {
    mavenCentral()
}

description = "Human-friendly clock time formatting — how people actually describe times in conversation"

java {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
    withSourcesJar()
    withJavadocJar()
}

dependencies {
    implementation("org.scala-lang:scala3-library_3:3.6.4")
    testImplementation("org.junit.jupiter:junit-jupiter:5.10.1")
    testRuntimeOnly("org.junit.platform:junit-platform-launcher")
}

tasks.withType<ScalaCompile> {
    scalaCompileOptions.additionalParameters = listOf("-Werror")
}

tasks.test {
    useJUnitPlatform()
}

publishing {
    publications {
        create<MavenPublication>("maven") {
            from(components["java"])

            pom {
                name.set("sayable-time")
                description.set("Human-friendly clock time formatting — how people actually describe times in conversation")
                url.set("https://github.com/dnf/sayable")

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
                    url.set("https://github.com/dnf/sayable")
                    connection.set("scm:git:git://github.com/dnf/sayable.git")
                    developerConnection.set("scm:git:ssh://github.com/dnf/sayable.git")
                }
            }
        }
    }
}

signing {
    isRequired = gradle.taskGraph.hasTask("publishToSonatype")
    sign(publishing.publications["maven"])
}
