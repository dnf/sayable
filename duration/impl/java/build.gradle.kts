plugins {
    `java-library`
    `maven-publish`
    signing
}

group = "com.github.dnf"
version = "0.1.0"

repositories {
    mavenCentral()
}

description = "Human-friendly duration formatting — how people actually talk about elapsed time"

java {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
    withSourcesJar()
    withJavadocJar()
}

tasks.withType<JavaCompile> {
    options.encoding = "UTF-8"
    options.compilerArgs.addAll(listOf("-Xlint:all", "-Werror"))
}

tasks.javadoc {
    (options as StandardJavadocDocletOptions).addStringOption("Xdoclint:none", "-quiet")
}

dependencies {
    testImplementation("org.junit.jupiter:junit-jupiter:5.10.1")
    testRuntimeOnly("org.junit.platform:junit-platform-launcher")
}

tasks.test {
    useJUnitPlatform()
}

publishing {
    publications {
        create<MavenPublication>("maven") {
            from(components["java"])

            pom {
                name.set("sayable-duration")
                description.set("Human-friendly duration formatting — how people actually talk about elapsed time")
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
