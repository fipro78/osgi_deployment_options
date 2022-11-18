# Deployment options for OSGi applications in the cloud/edge

This repository contains the sources for building and verifiying the different deployment options for OSGi applications.  
It contains a simple example application to verify some basic OSGi techniques. This application is published in different deployment variants in different containers to inspect container size and startup performance.


## Example application

The example application is a small Gogo Shell commandline application. It includes small services and commands to verify some basic OSGi specification implementations:
- [Declarative Services](https://docs.osgi.org/specification/osgi.cmpn/8.0.0/service.component.html)
- [Event Admin Service](https://docs.osgi.org/specification/osgi.cmpn/8.0.0/service.event.html)
- [Configuration Admin Service](https://docs.osgi.org/specification/osgi.cmpn/8.0.0/service.cm.html)


The following folders contain the service related implementations:
- `org.fipro.service.api` = StringModifier Service API
- `org.fipro.service.impl` = StringModifier Service Implementations
- `org.fipro.service.configurable` = A configurable service
- `org.fipro.service.eventhandler` = An EventHandler published via DS

The following folders contain the application related implementations:
- `org.fipro.service.command` - The Gogo Shell commands to trigger the service executions
- `org.fipro.service.app` - The application project for building the executable jar via bndtools


As the intention is to publish the application in a container, the Gogo Shell is started in non-interactive mode and made accessible via telnet. This is done by setting the system property `gosh.args` to the following value:

```
-Dgosh.args="--nointeractive -c telnetd -i 0.0.0.0 -p 11311 start
```

Once the application is started, you can access the application via:

```
telnet localhost 11311
```

Once the session is established the "message of the day" and the Gogo Shell prompt will appear. The "message of the day" shows the available commands provided by the example application:

```
===========================================
Welcome to the OSGi Test app via Gogo Shell
===========================================

It has four commands:

1. configure <param>
Uses the ConfigAdmin to set the given param as value for the "welcome" command.

2. welcome
Print out a message that contains the value that was set via the "configure" command.

3. consume <param>
Sends an event via EventAdmin to pass the value of the given param. The triggered EventHandler will simply print out a message that contains the value.

4. modify <param>
Triggers a StringModifier service and prints out the result.
```

Of course the common Gogo Shell commands will also work.

__Note:__  
Once connected to the application and operating in the Gogo Shell, you can close the connection via [CTRL] + [+]. The telnet session can then be closed via the `quit` command. Don't exit the Gogo Shell via `exit 0` as this will stop the Gogo Shell process and then stop the container as there is no running service anymore.

Further information about the Gogo Shell:
- [Apache Felix Gogo](https://felix.apache.org/documentation/subprojects/apache-felix-gogo.html)
- [OSGi enRoute Gogo](https://enroute.osgi.org/FAQ/500-gogo.html)
- [Liferay OSGI and Shell Access Via Gogo Shell](https://liferay.dev/blogs/-/blogs/liferay-osgi-and-shell-access-via-gogo-shell)


__Note:__  
On starting the containers ensure to expose the port via `-p11311:11311` to be able to connect to the application in the container via telnet.

## Deployment Variants

This repository contains the sources for creating and benchmarking different deployment variants for Java OSGi applications. The above example application is therefore created in the following flavors:
- Multiple JARs in a folder structure
- Executable JAR
- Custom JRE with jlink
- Native Executable with GraalVM

### Multiple JARs in a folder structure

This is the default variant in which multiple JARs / OSGi bundles are located inside a folder. There is an additional configuration file to define which bundles should be installed in the OSGi runtime. The application is started via the OSGi launcher, for Equinox this is `org.eclipse.osgi:org.eclipse.core.runtime.adaptor.EclipseStarter`.

As the OSGi framework is doing the loading of bundles and classes, the application can be started via:

```
java -jar org.eclipse.osgi-3.17.200.jar
```

This deployment variant requires a Java Runtime to be installed on the host system.

Further information about the folder layout etc. with Equinox can be found here: [Getting and using the Equinox OSGi implementation](https://www.eclipse.org/equinox/documents/quickstart-framework.php)

### Executable JAR

This is the default deployment variant proposed by Bndtools. The executable JAR is a single JAR file that includes each required bundle as embedded JAR file (instead of a flattened fat JAR). It also contains the configuration files. The application is started via the OSGi launcher, in the executable JAR format this is the `aQute.launcher.pre.EmbeddedLauncher`.

Also in this case the OSGi framework is doing the loading of bundles and classes. If the name of the executable JAR is `app.jar` the application can be started via:

```
java -jar app.jar
```

This deployment variant requires a Java Runtime to be installed on the host system.

The build is using the [bnd Maven Plugins](https://github.com/bndtools/bnd/tree/master/maven).

Further information can be found here:
 - [bnd](https://bnd.bndtools.org/)
 - [Bndtools](https://bndtools.org/)
 - [bnd Maven Plugins](https://github.com/bndtools/bnd/tree/master/maven)
 - [bnd Gradle Plugins](https://github.com/bndtools/bnd/tree/master/gradle-plugins)

### Custom JRE with jlink

For creating a custom JRE the `jlink` tool can be used that comes with a JDK. The description of the `jlink` command says:  

___assemble and optimize a set of modules and their dependencies into a custom runtime image___

[The jlink Command](https://docs.oracle.com/en/java/javase/17/docs/specs/man/jlink.html)

This means that for creating a custom runtime image JPMS (Java Platform Module System) is required. For an OSGi application this is an issue, as most of the available OSGi bundles do not contain a module-info.class, so they are not really participating in JPMS. At least trying to create a custom runtime image via `jlink` from the folder structure or the executable jar creates errors like:

```
automatic module cannot be used with jlink
```

There are tools that can be used to handle this issue, e.g. [ModiTect](https://github.com/moditect/moditect). Those tools can add a `module-info.class` to an existing bundle. But this creates a new artifact, so this approach might create issues related to security and OSS as the original published OSS artifact is modified.

Bndtools added JPMS support to handle this. You can use the [bnd JPMS support](https://bnd.bndtools.org/chapters/330-jpms.html) for creating the `module-info.class` on your own bundles, e.g. by adding the `-jpms-module-info` instruction to the `bnd-maven-plugin` configuration.  
But it can also be used to add a `module-info.class` to the exported executable jar by adding the `-jpms-module-info` instruction to the `.bndrun` file, like this:

```
-jpms-module-info: \
    equinox_${project.artifactId};\
        version=${project.version};\
        ee=JavaSE-${java.specification.version}
-jpms-module-info-options: jdk.unsupported;static=false
```

This will make the exported executable jar itself a JPMS module which can be used to create a custom runtime image using `jlink`.

__Note:__  
Sometimes the `module-info.class` generation fails or creates incorrect results. It is possible to adjust the generation via the `-jpms-module-info` and the `-jpms-module-info-options` instructions. For example the `org.osgi.service.cm` package is exported via the `org.osgi.service.cm` bundle and the `org.apache.felix.configadmin` bundle which creates a conflict in the resulting module. To adjust the default generation you can add the following instructions:

```
-jpms-module-info:org.fipro.service.command;modules='org.apache.felix.configadmin'
-jpms-module-info-options: org.osgi.service.cm;ignore="true"
```

The first instruction will add the module `org.apache.felix.configadmin` to the required modules. The second instruction tells that the module `org.osgi.service.cm` should be ignored. This will result in a correctly defined '`module-info.class` inside the module that only requires `org.apache.felix.configadmin`.

The command for creating the custom runtime image could look like this:

```
$JAVA_HOME/bin/jlink \
  --add-modules equinox_app \
  --module-path equinox-app.jar \
  --no-header-files \
  --no-man-pages \
  --output /app/jre
```

__Note:__  
Via the `--compress=2` parameter it is possible to compress the resulting JRE.

The application can then be started via

```
/app/jre/bin/java -m equinox_app/aQute.launcher.pre.EmbeddedLauncher
```

This approach is inspired by [OSGi Configuration Admin / Kubernetes Integration Prototype](https://github.com/rotty3000/osgi-config-aff).

### Native Executable with GraalVM

To create a native executable you can use the `native-image` tool provided by GraalVM.

___Native Image is a technology to compile Java code ahead-of-time to a binary – a native executable. A native executable includes only the code required at run time, that is the application classes, standard-library classes, the language runtime, and statically-linked native code from the JDK.___

[GraalVM Native Image - Getting Started](https://www.graalvm.org/22.2/reference-manual/native-image/)

A native image can be created:
- From a class
- From a JAR (classpath)
- From a module (modulepath)

The OSGi Module Layer does not fit into this. With [OSGi Core Release 8](https://docs.osgi.org/specification/osgi.core/8.0.0/index.html) the [Connect Specification](https://docs.osgi.org/specification/osgi.core/8.0.0/framework.connect.html) was added to allow bundles to exist and to be installed into the OSGi Framework from the flat class path, the module path (Java Platform Module System), a jlink image, or a native image. This actually allows to start an OSGi application even without the Module Layer in control.


## OSGi Connect & Atomos

With [OSGi Core Release 8](https://docs.osgi.org/specification/osgi.core/8.0.0/index.html) the [Connect Specification](https://docs.osgi.org/specification/osgi.core/8.0.0/framework.connect.html) was added to allow bundles to exist and to be installed into the OSGi Framework from the flat class path, the module path (Java Platform Module System), a jlink image, or a native image.  
[Apache Felix Atomos](https://github.com/apache/felix-atomos) is an implementation of the OSGi Connect Specification. Integrating it into the application allows to start the application from a flat classpath or a modulepath. Using Atomos also allows the creation of a custom runtime image via `jlink` and the creation of a native executable using the GraalVM `native-image` tool.

Further information:
- Ubiquitous OSGi - Android, Graal Substrate, Java Modules, Flat Class Path
    - [Abstract & Slides](https://www.eclipsecon.org/2020/sessions/ubiquitous-osgi-android-graal-substrate-java-modules-flat-class-path)
    - [Video](https://www.youtube.com/watch?v=KxmtzjHBumU)
- OSGi R8, Felix 7, Atomos and the future of OSGi@Eclipse
    - [Abstract & Slides](https://adapt.to/2021/en/schedule/osgi-r8-felix-7-atomos-and-the-future-of-osgi-eclipse.html)
    - [Video](https://www.youtube.com/watch?v=oitFMbztf5s)

There are several issues you might face when using Atomos. I list some of them here:
- The executable jar with Atomos created with Bndtools is not working (`org.osgi.framework.BundleException: Error reading bundle content.`)  
[Bndtools issue 5243](https://github.com/bndtools/bnd/issues/5243)  
But it does work to create a custom runtime image using `jlink` and the executable jar.
- Stacktrace when starting Atomos with Equinox on modulepath having the bundles inside a folder (`java.lang.ClassNotFoundException: sun.misc.Unsafe`)  
[Atomos issue 51](https://github.com/apache/felix-atomos/issues/51)  
Only an annoying printstacktrace when Unsafe can not be loaded, should not cause any issues.
- Atomos launcher is not taking system properties passed via -D  
[Atomos issue 54](https://github.com/apache/felix-atomos/issues/54)  
Some arguments need to be passed as program arguments so they are taken up by the Atomos launcher, e.g. `java -cp "bundles/*" org.apache.felix.atomos.Atomos gosh.args="--nointeractive -c telnetd -i 0.0.0.0 -p 11311 start"`
- Including and starting Jetty misses some packages  
[Atomos issue 57](https://github.com/apache/felix-atomos/issues/57)   
Need to be added via program argument parameter `org.osgi.framework.system.packages.extra=javax.rmi.ssl`

## GraalVM Native Image

Building a native image with GraalVM happens under a "closed world assumption". This means all the bytecode in your application that can be called at run time must be known at build time. It is therefore quite complicated to build a native image out of a OSGi based application, as OSGi is highly dynamic.

* The classloading issue is solved by integrating Atomos (OSGi Connect) to the application.
* The dynamics on reflection for services etc. needs to be configured accordingly.

### Configuring handling of dynamics

Configuring the "Reachability Metadata" is the most challenging task for creating a native image out of an OSGi based application. In this repository the following approach was followed:

* The metadata was collected using the tracing agent

```
$GRAALVM_HOME/bin/java \
-agentlib:native-image-agent=config-output-dir=META-INF/native-image \
--add-modules ALL-MODULE-PATH \
--module-path atomos_lib/ \
--module org.apache.felix.atomos \
gosh.home=.
```

* The collected metadata was modified to fix some issues

__reflect-config.json: use global access rules instead of specific method access (in case not every method was called while tracing)__
    
```
"allDeclaredConstructors" : true,
"allPublicConstructors": true,
"allDeclaredMethods" : true,
"allPublicMethods" : true,
"allDeclaredFields" : true,
"allPublicFields" : true
```
__reflect-config.json: Removal of critical entries, e.g. `sun.misc.Unsafe`, `java.net.SetAccessible/0x0000000800c80000`, `sun.misc.*`__

__Update of `java.lang.*` entries to ensure the Gogo Shell commands are working correctly (e.g. lb)__

```
  {
    "name": "java.lang.Boolean",
    "allDeclaredConstructors" : true,
    "allPublicConstructors" : true,
    "allDeclaredMethods" : true,
    "allPublicMethods" : true
  },
  {
    "name": "java.lang.String",
    "allDeclaredConstructors" : true,
    "allPublicConstructors" : true,
    "allDeclaredMethods" : true,
    "allPublicMethods" : true
  },
```
  
__resource-config.json: Ensure to add all services and resources that are necessary__
    
```
{
  "resources":{
  "includes":[
    {
      "pattern":"META-INF/services/.*$"
    }, 
    {
      "pattern":"org/eclipse/equinox/internal/event/ExternalMessages.properties"
    },
    {
      "pattern":"org/eclipse/osgi/internal/url/SetAccessible.bytes"
    }
  ]},
  "bundles":[]
}
```

The gathering of reachability metadata is described in more detail in the official [GraalVM Documentation - Native Image Reachability Metadata](https://www.graalvm.org/22.2/reference-manual/native-image/metadata/)

Further information about GraalVM Native Images and Reachability Metadata:
- [GraalVM Native Image - Getting Started](https://www.graalvm.org/22.2/reference-manual/native-image/)
- [GraalVM Native Image - Reachability Metadata](https://www.graalvm.org/22.2/reference-manual/native-image/metadata/)
- [GraalVM Native Image - Collect Metadata with the Tracing Agent](https://www.graalvm.org/22.2/reference-manual/native-image/metadata/AutomaticMetadataCollection/)
- [GraalVM Native Image - Accessing Resources in Native Image](https://www.graalvm.org/22.2/reference-manual/native-image/dynamic-features/Resources/)
- [GraalVM Native Image - Reflection in Native Image](https://www.graalvm.org/22.2/reference-manual/native-image/dynamic-features/Reflection/)
- [GraalVM Native Image - Build a Native Executable with Reflection](https://www.graalvm.org/22.2/reference-manual/native-image/guides/build-with-reflection/)

__Note:__  
There are also tools that can help in generating the metadata, e.g. the Atomos Maven Plugin is able to do this in the build process.

### Building

Building a native image can be done in different ways. One way is to use the official build plugins:
- [Maven plugin for GraalVM Native Image building](https://graalvm.github.io/native-build-tools/latest/maven-plugin.html)
- [Gradle plugin for GraalVM Native Image building](https://graalvm.github.io/native-build-tools/latest/gradle-plugin.html)

The issue facing with this approach is, that the resulting native image is platform-dependent, e.g. if you execute the build on Windows you will get a Windows executable.

Alternatively you can use a multi-stage build that uses the official GraalVM container images for the build stage.  
Use the community edition container to be able to specify the version to use explicitly:

```
FROM ghcr.io/graalvm/graalvm-ce:ol8-java17-22.2.0 AS build
```

In this case you need to install the `native-image` tool additionally in order to be able to build a native image.


Alternatively you can also use the native-image container image:

```
FROM ghcr.io/graalvm/native-image:22.2.0 AS build
```

But the documentation says that "using `ghcr.io/graalvm/native-image` you will always get the latest update available for Native Image, the latest OS, the latest Java version, and the latest GraalVM version". This might not be desirable in a production case if the base image might change suddenly.

This repository is using the multi-stage build using the community edition container image to create a statically linked native executable which is then placed in the smallest possible image (e.g. `scratch`).

- [GraalVM Community Images](https://www.graalvm.org/22.2/docs/getting-started/container-images/)
- [GraalVM Community Edition Container Images](https://github.com/graalvm/container)
- [GraalVM GitHub Container Registry](https://github.com/orgs/graalvm/packages)
- [Build a Statically Linked or Mostly-Statically Linked Native Executable](https://www.graalvm.org/22.2/reference-manual/native-image/guides/build-static-executables/)
- [Containerise a Native Executable and Run in a Docker Container](https://www.graalvm.org/22.2/reference-manual/native-image/guides/containerise-native-executable-and-run-in-docker-container/)

__Note:__
You can also use a multi-stage build for executing the Maven build on a target architecture container.

__Note:__  
For building a native image only using the classpath variant and listing all jars explicitly worked. Using the classpath variant with a folder or a folder and a wildcard failed with an error. Using the modulepath variant using the executable jar (remember the folder variant fails for modules) also fails as embedded jars are not resolved correctly.  
I opened this [GraalVM GitHub Issue](https://github.com/graalvm/container/issues/64) for some of the errors related to modulepath and classpath usage.

__Note:__
On Windows, the `native-image` builder will only work when it’s executed from the x64 Native Tools Command Prompt.  
(e.g. via Visual Studio interface: enter x64 in the Windows search box and select _x64 Native Tools Command Prompt_)  
[Using GraalVM and Native Image on Windows 10](https://medium.com/graalvm/using-graalvm-and-native-image-on-windows-10-9954dc071311)  


### Execution

The Atomos Module support expects to have full introspection of the Java Platform Module System. As this was not available in older versions of the GraalVM, Atomos needs either a folder that contains the original jars there where used to build the native executable, or a generated index file. This is necessary so Atomos is able to discover the available bundles and load additional bundle entries at runtime.

This actually means, if you want to execute the statically compiled native executable that does not contain a dedicated index file, you need to place the folder `atomos_lib` next to the executable, that contains the original jars. For the generation of the index file, the native image needs to be created using the `atomos-maven-plugin`. This repository is not using the `atomos-maven-plugin` as it uses the multi-stage build with GraalVM container images instead of the Maven build.

__Note:__  
As GraalVM 22 introduced introspection support, this might change in the future.

- [Building Substrate Examples](https://github.com/apache/felix-atomos/blob/master/atomos.examples/SUBSTRATE.md)
- [Apache Felix Atomos - GitHub Issue #50](https://github.com/apache/felix-atomos/issues/50)

## Container

The application variants created via the `org.fipro.service.app` project are put in containers. The goal is to create small containers to reduce the time it takes to load an image (e.g. into a Kubernetes cluster) and to reduce the needed storage in an image registry and the container runtime.

### Base images

When planning to containerize a Java application, the first decision to make is which base image to use. For this the base image size is taken as the leading criteria here. Other criterias can be security, additional required tooling, target infrastructure. The following tables only compare the image sizes:

| Image                | Size     |
| :---                 |      ---:|
| alpine:3             |  5.54 MB |
| debian:bullseye-slim | 80.50 MB |
| ubuntu:jammy         | 77.84 MB |

Related to Java the main difference between Alpine Linux and Debian/Ubuntu is the libc implementation. Alpine uses musl while Debian/Ubuntu are using glibc.

| Image                | Size     |
| :---                 |      ---:|
| eclipse-temurin:17-jdk-jammy<br>(Ubuntu base image with JDK)  | ~ 455 MB |
| eclipse-temurin:17-jdk-alpine<br>(Alpine base image with JDK) | ~ 356 MB |
| eclipse-temurin:17-jre-jammy<br>(Ubuntu base image with JRE)  | ~ 266 MB |
| eclipse-temurin:17-jre-alpine<br>(Alpine base image with JRE) | ~ 168 MB |
| ibm-semeru-runtimes:open-17-jdk-jammy                         | ~ 477 MB |
| ibm-semeru-runtimes:open-17-jre-jammy                         | ~ 272 MB |

### Interlude: Distroless

_"Distroless" images contain only your application and its runtime dependencies. They do not contain package managers, shells or any other programs you would expect to find in a standard Linux distribution._

["Distroless" Container Images](https://github.com/GoogleContainerTools/distroless)

Distroless images are intended to create a smaller attack surface, reduce compliance scope, and results in a small, performant image.

| Image                             |  Size     |
| :---                              |       ---:|
| [gcr.io/distroless/static-debian11](https://github.com/GoogleContainerTools/distroless/tree/main/base) |   2.36 MB |
| [gcr.io/distroless/base-debian11](https://github.com/GoogleContainerTools/distroless/tree/main/base)   |  20.32 MB |
| [gcr.io/distroless/java17-debian11](https://github.com/GoogleContainerTools/distroless/tree/main/java) | 230.88 MB |

Compared to an Alpine based Temurin JRE image, the Distroless Java image is bigger, as it is based on Debian with glibc. For production use Distroless images can still be relevant because of security reasons.

Further information:
- [Dockerizing with Distroless](https://medium.com/@luke_perry_dev/dockerizing-with-distroless-f3b84ae10f3a)
- [Distroless is for Security if not for Size](https://dwdraju.medium.com/distroless-is-for-security-if-not-for-size-6eac789f695f)


### Container best practices

There are several things that should be considered as best practice when creating containers for Java applications. Some of these are:
- Install only what you need in production (JRE vs. JDK)
- Use multi-stage builds (e.g. create JRE via jlink in first stage and create final container only with the result)
- Don't run Java apps as root
- Properly shutdown and handle events to terminate a Java application
- Take care of "container-awareness" in current Java versions

Further information on best practices:
- [10 best practices to build a Java container with Docker](https://snyk.io/blog/best-practices-to-build-java-containers-with-docker/)
- [Java 17: What’s new in OpenJDK's container awareness](https://developers.redhat.com/articles/2022/04/19/java-17-whats-new-openjdks-container-awareness#)
- [Eclipse OpenJ9 Blog: Innovations for Java running in containers](https://blog.openj9.org/2021/06/15/innovations-for-java-running-in-containers/)
- [How To Configure Java Heap Size Inside a Docker Container](https://www.baeldung.com/ops/docker-jvm-heap-size)
- [Tini - A tiny but valid init for containers](https://github.com/krallin/tini)


## Build

This repository is using Maven for building the application and the Docker containers. It therefore makes use of a ___Maven first___ approach. The ___Maven first___ approach assumes that everyone working in the project has the tooling ready to build Java projects with Maven. For building the images from the build results the `fabric8io/docker-maven-plugin` is used.

The sources for building the Docker images and the build itself are located in the project `org.fipro.service.app`.
- src/main/resources  
Contains additional resources like start scripts and configurations needed inside the Docker container
- src/main/docker  
Contains the different explicit Docker files that are used for building the images.

The build is first copying the resources for building the images in subfolders below `target/deployment`. The `fabric8io/docker-maven-plugin` is then using those subfolders as context folder together with the corresponding Docker files from `src/main/docker`.

Using the ___Maven first___ approach and the `fabric8io/docker-maven-plugin` it is quite easy to create different deployment variant containers from single source.

Further information:
 - [fabric8io/docker-maven-plugin - GitHub](https://github.com/fabric8io/docker-maven-plugin)
 - [fabric8io/docker-maven-plugin - Documentation](http://dmp.fabric8.io/)

__Note:__  
The alternative to this would be a ___Docker first___ approach. In detail this means that a multi-stage build is set up in which the first step is to checkout the sources and run the build in one container, and then create the production container with only the build result. It should be also possible to combine the ___Docker first___ approach with a build that uses the `fabric8io/docker-maven-plugin` for creating the final Docker images. Such a setup would be more complicated related to the creation and publishing of images, as it means to create images from inside an image. Therefore this repository is not making use of this approach.

The build can be triggered from the parent directory via

```
mvn clean verify
```

This will by default build the bundles, the application and create the different Docker images based on Eclipse Temurin 17. The following profiles are available to build different variants:

- temurin_17
- graalvm_17
- temurin_11
- semeru_17

To build the Temurin 17 and the GraalVM 17 containers at once, execute the build by specifying the profiles like this:

```
mvn clean verify -Ptemurin_17,graalvm_17
```

## Benchmark

Additionally to verify the container size with different deployment variants, this repository verifies the startup performance of the different variants. The benchmark is not 100% accurate, but gives an indication of the relation between deployment variant and startup performance.

The benchmark consists of several parts:
- benchmark client bundle
- benchmark service
- benchmark app

### Benchmark Client Bundle

The benchmark client bundle is located in the folder `org.fipro.osgi.benchmark`.
It contains an _Immediate Component_ that can be configured via the following system properties:

- `container.init`  
Tell the application to quit directly. Used to kill the application after startup, so the bundle cache is created.
- `benchmark.appid`, `benchmark.executionid`, `benchmark.starttime`  
The _appid_ of the deployment variant, used to identify the application.  
The _executionid_ which is a simple increment.  
The _starttime_ is the timestamp in milliseconds directly before the application is started.  
This three properties need to be set in combination in order to trigger the benchmark service all.
- `benchmark.host`  
The benchmark service host URL, used for creating the service URL that should be called. Defaults to "localhost".

__Note:__  
For the benchmark this bundle needs to be started as last bundle of the application. To ensure that this happens, the bundle symbolic name is `zorg.fipro.osgi` and the `org.fipro.service.app/equinox-app.bndrun` file contains the following instruction:

```
-runstartlevel: \
    order = sortbynameversion, \
    begin = -1
```

Further information on this:
- [bnd | Startlevels](https://bnd.bndtools.org/chapters/305-startlevels.html)
- [bnd | -runstartlevel](https://bnd.bndtools.org/instructions/runstartlevel.html)

### Application Container Image Updates

__coreutils__
The Benchmark Service requires the timestamps in milliseconds for the time measurement. busybox does not support the `%N` format option, therefore you don't get the time in nanoseconds/milliseconds in a default Alpine container. You only get a precision in seconds. It is necessary to install `coreutils` in the containers in order to be able to get the starttime in milliseconds.  
Installing `coreutils` increases the image size about 2.5 MB.

__java.net.http module__
The Benchmark Client Bundle is using the `java.net.http.HttpClient` for sending the request to the Benchmark Service. To start the application in the _Atomos Folder modulepath_ variant, you need to ensure that the `java.net.http` module is added.

```
java --add-modules=ALL-MODULE-PATH,java.net.http -p bundles -m org.apache.felix.atomos org.osgi.framework.system.packages=""
```

While this has almost no effect on the Temurin JRE containers, the size of the GraalVM native executable becomes about 8 MB bigger with that change.

__shell script support__
For the time measurement a shell script is used that starts the application multiple times in a for-loop. While this is working in the Alpine based images, the GraalVM native executable image based on `scratch` or even `distroless-static` does not support shell scripts. For the benchmark execution the base image of the GraalVM native executable image is therefore changed to `alpine:3`.


### Benchmark Service

The Benchmark Service is located in the folder `org.fipro.osgi.benchmark.service`. It is a JAX-RS service based on the OSGi JAX-RS Whiteboard that simple accepts POST requests and stores the sent startup times. Additionally it provides a resource to request the stored data via `<host>:<port>/benchmark/details`, e.g. `http://localhost:8080/benchmark/details` in the default configuration.

### Benchmark App 

The Benchmark App is located in the folder `org.fipro.osgi.benchmark.app`. This is the application project for the Benchmark Service that is using the [Apache Aries JAX-RS Whiteboard](https://github.com/apache/aries-jax-rs-whiteboard) and a Jetty server.

The Benchmark App build contains the building of the Benchmark App Container, and also the benchmark execution. For this it utilizes `io.fabric8:docker-maven-plugin`. It starts each deployment variant container sequentially (to avoid side effects caused by multiple parallel container processes) and executes the `start_benchmark.sh` scripts in the containers.

As the benchmark execution is taking quite a while, it might not be desirable to run this with every build. Additionally it only makes sense the execute the benchmark if the Benchmark App container is still running after the build (the `io.fabric8:docker-maven-plugin` by default is configured to stop the started containers afterwards). The plugin can be configured via the system property `-Ddocker.keepRunning=true` which avoids the stopping and removal of the created containers.

```
mvn -Ddocker.keepRunning=true clean verify
```

The Benchmark Service and the Benchmark App are also only build if that system property is set to true.

As the parameter `-Ddocker.keepRunning=true` does not remove the created containers, a consecutive executed build will fail, as the containers can't be created twice. For cleaning up the profile `kill` is available, which only removes the previously created benchmark containers.

```
mvn clean -Pkill
```

By default the scripts are configured to execute the application start-stop process 10 times. This can be adjusted by setting the system property `benchmark.iteration_count`.

The following example command will trigger a build that builds the Temurin 17 and the GraalVM 17 builds and then executes the benchmark with an iteration count of 5.

```
mvn -Ddocker.keepRunning=true -Dbenchmark.iteration_count=5 clean verify -Ptemurin_17,graalvm_17
```

If you run into a timeout because you increased the `benchmark.iteration_count`, you can increase the wait timeout via the `container.timeout` property.

```
mvn -Ddocker.keepRunning=true -Dbenchmark.iteration_count=100 -Dcontainer.timeout=2000000 clean verify
```


Once the build is finished you can access the benchmark results via: [http://localhost:8080/benchmark/details](http://localhost:8080/benchmark/details)

### Clean start vs. bundle cache

OSGi framework typically use a bundle cache. That cache contains several information, sometimes even related to bundle startup order etc. Starting Equinox in the folder based deployment variant builds up the bundle cache on first start, which intends to reduce the startup time on consecutive starts. The Bndtools created executable jar by default does a clean start. To see if a clean start vs. using the bundle cache has an effect on the startup time, the `start_benchmark.sh` scripts are starting the applications first by using the cache, and then with a clean start.

Using the Equinox launcher to start an application in a folder structure __without a cache__ add `-Dorg.osgi.framework.storage.clean=onFirstInit`

```
java -Dorg.osgi.framework.storage.clean=onFirstInit -jar org.eclipse.osgi-3.17.200.jar
```

Using the Bnd launcher to start an application as executable jar __with a cache__ add `-Dlaunch.keep=true -Dlaunch.storage.dir=cache`

```
java -Dlaunch.keep=true -Dlaunch.storage.dir=cache -jar app.jar
```

Using Atomos the parameter `org.osgi.framework.storage.clean=onFirstInit` needs to be passed as program argument to be evaluated correctly.

```
java -cp "bundles/*" org.apache.felix.atomos.Atomos org.osgi.framework.storage.clean=onFirstInit
```

__Note:__  
If you intend to create a container with a folder based Equinox application that contains a bundle cache, check if you can use a multi-stage build where you start the application in the first container and then copy the application together with the bundle cache to the target container.

__Note:__  
When starting a folder based Equinox application, by default the bundle cache is located in the folder _configuration_ relative to the Equinox OSGi bundle. For the Atomos variant where all jars are placed in the _bundles_ folder this means, the bundle cache is located in _bundles/configuration_. This can be changed by setting the property `org.osgi.framework.storage`, which needs to be passed as program argument for the Atomos variant.

## Benchmark Results

The following tables show the results for the created image sizes and the average time it took to start the application inside the container. Please note that these numbers are an average over 100 start-stop-cycles inside a container. So they are not 100% accurate and will show different numbers in detail in each test run. The measurement is only intended to show the basic implications of the different deployment options.

### Eclipse Temurin 17

| Deployment (plain OSGi)         | Image Size | Benchmark Image Size | Startup clean | Startup cache |
| :---                            |        ---:|                  ---:|           ---:|           ---:|
| folder-app:17_temurin           | \~ 171 MB  |            \~ 173 MB |     \~ 982 ms |     \~ 901 ms |
| executable-app:17_temurin       | \~ 174 MB  |            \~ 174 MB |    \~ 1087 ms |    \~ 1099 ms |
| jlink-app:17_temurin            | \~  75 MB  |            \~  79 MB |    \~ 1336 ms |    \~ 1345 ms |
| jlink-compressed-app:17_temurin | \~  53 MB  |            \~  56 MB |    \~ 1497 ms |    \~ 1505 ms |


| Deployment (OSGi Connect)              | Image Size | Benchmark Image Size | Startup clean | Startup cache |
| :---                            |        ---:|                  ---:|           ---:|           ---:|
| folder-atomos-app:17_temurin<br>classpath<br>modulepath           | \~ 171 MB  |            \~ 173 MB |     <br>\~ 1122 ms<br>\~ 1194 ms |     <br>\~ 973 ms<br>\~ 1052 ms |
| jlink-atomos-app:17_temurin            | \~  75 MB  |            \~  79 MB |    \~ 1439 ms |    \~ 1326 ms |
| jlink-atomos-compressed-app:17_temurin | \~  53 MB  |            \~  56 MB |    \~ 1593 ms |    \~ 1445 ms |

### Eclipse Temurin 11

| Deployment (plain OSGi)         | Benchmark Image Size | Startup clean | Startup cache |
| :---                            |                  ---:|           ---:|           ---:|
| folder-app:17_temurin           |            \~ 161 MB |    \~ 1146 ms |     \~ 1077 ms |
| executable-app:17_temurin       |            \~ 164 MB |    \~ 1229 ms |    \~ 1290 ms |
| jlink-app:17_temurin            |            \~  76 MB |    \~ 1426 ms |    \~ 1417 ms |
| jlink-compressed-app:17_temurin |            \~  54 MB |    \~ 1502 ms |    \~ 1541 ms |


| Deployment (OSGi Connect)       | Benchmark Image Size | Startup clean | Startup cache |
| :---                            |                  ---:|           ---:|           ---:|
| folder-atomos-app:17_temurin<br>classpath<br>modulepath           |            \~ 161 MB |     <br>\~ 1317 ms<br>\~ 1363 ms |     <br>\~ 1154 ms<br>\~ 1219 ms |
| jlink-atomos-app:17_temurin            |            \~  76 MB |    \~ 1534 ms |    \~ 1408 ms |
| jlink-atomos-compressed-app:17_temurin |            \~  54 MB |    \~ 1605 ms |    \~ 1504 ms |

### IBM Semeru 17

| Deployment (plain OSGi)        | Benchmark Image Size | Startup clean | Startup cache |
| :---                           |                  ---:|           ---:|           ---:|
| folder-app:17_openj9           |            \~ 276 MB |     \~ 998 ms |     \~ 875 ms |
| executable-app:17_openj9       |            \~ 278 MB |    \~ 1067 ms |    \~ 1072 ms |
| jlink-app:17_openj9            |            \~ 163 MB |    \~ 2445 ms |    \~ 2426 ms |
| jlink-compressed-app:17_openj9 |            \~ 140 MB |    \~ 2600 ms |    \~ 2551 ms |


| Deployment (OSGi Connect)              | Benchmark Image Size | Startup clean | Startup cache |
| :---                            |                  ---:|           ---:|           ---:|
| folder-atomos-app:17_openj9<br>classpath<br>modulepath           |            \~ 276 MB |     <br>\~ 944 ms<br>\~ 1023 ms |     <br>\~ 944 ms<br>\~ 1029 ms |
| jlink-atomos-app:17_openj9            | \~ 163 MB  |    \~ 2330 ms |    \~ 2337 ms |
| jlink-atomos-compressed-app:17_openj9 | \~ 140 MB  |    \~ 2463 ms |    \~ 2445 ms |

__Note:__  
After a discussion with some IBM experts at the EclipseCon Europe we discovered some options to improve the startup performance.

### IBM Semeru 17 - -Xquickstart

In this scenario the same images are used as in the IBM Semeru 17 scenario. Only the [-Xquickstart](https://www.eclipse.org/openj9/docs/xquickstart/) option is set to improve the startup performance.

| Deployment (plain OSGi)        | Benchmark Image Size | Startup clean | Startup cache |
| :---                           |                  ---:|           ---:|           ---:|
| folder-app:17_openj9           |            \~ 276 MB |     \~ 940 ms |     \~ 833 ms |
| executable-app:17_openj9       |            \~ 278 MB |    \~ 1048 ms |    \~ 1046 ms |
| jlink-app:17_openj9            |            \~ 163 MB |    \~ 1498 ms |    \~ 1483 ms |
| jlink-compressed-app:17_openj9 |            \~ 140 MB |    \~ 1636 ms |    \~ 1636 ms |


| Deployment (OSGi Connect)              | Benchmark Image Size | Startup clean | Startup cache |
| :---                            |                  ---:|           ---:|           ---:|
| folder-atomos-app:17_openj9<br>classpath<br>modulepath           |            \~ 276 MB |     <br>\~ 912 ms<br>\~ 981 ms |     <br>\~ 917 ms<br>\~ 980 ms |
| jlink-atomos-app:17_openj9            | \~ 163 MB  |    \~ 1458 ms |    \~ 1464 ms |
| jlink-atomos-compressed-app:17_openj9 | \~ 140 MB  |    \~ 1615 ms |    \~ 1610 ms |

### IBM Semeru 17 - -Xshareclasses

In this scenario images are created that contain a shared class cache. For this a multi-stage build is used that is first creating a shared class cache with a default size and then ensures to limit the size of the shared class cache in a second step to avoid wasted space. For this the [-Xshareclasses](https://www.eclipse.org/openj9/docs/xshareclasses/) option is used together with the [-Xscmx](https://www.eclipse.org/openj9/docs/xscmx/) JVM option. The script that does the cache creation and optimization is located [here](org.fipro.service.app/src/main/resources/init_scc_size.sh).  
The application together with the created class cache is then copied to the final production image. Additional information is available at [Introduction to class data sharing](https://www.eclipse.org/openj9/docs/shrc/)

__Note:__  
To use the `-Xshareclasses` option with a custom runtime image with `jlink` you need to ensure that the module `openj9.sharedclasses` is added to the extra modules. Otherwise the shareclasses support is missing in the custom runtime.  
Also note that [class sharing is enabled by default](https://blog.openj9.org/2019/10/15/openj9-class-sharing-is-enabled-by-default/), which is especially important to know when trying to run a custom JRE image that was created using `jlink` in a default IBM Semeru container. If the module `openj9.sharedclasses` is not included in the custom JRE, it won't start on the default IBM Semeru container. Copying it to another container will work if the shared class cache is not enabled.

| Deployment (plain OSGi)        | Benchmark Image Size | Startup clean | Startup cache |
| :---                           |                  ---:|           ---:|           ---:|
| folder-app:17_openj9           |            \~ 296 MB |     \~ 621 ms |     \~ 555 ms |
| executable-app:17_openj9       |            \~ 298 MB |    \~  913 ms |    \~  914 ms |
| jlink-app:17_openj9            |            \~ 187 MB |    \~  974 ms |    \~  971 ms |
| jlink-compressed-app:17_openj9 |            \~ 164 MB |    \~ 1057 ms |    \~ 1036 ms |


| Deployment (OSGi Connect)              | Benchmark Image Size | Startup clean | Startup cache |
| :---                            |                  ---:|           ---:|           ---:|
| folder-atomos-app:17_openj9<br>classpath<br>modulepath           |            \~ 276 MB |     <br>\~ 657 ms<br>\~ 719 ms |     <br>\~ 669 ms<br>\~ 719 ms |
| jlink-atomos-app:17_openj9            | \~ 188 MB  |    \~ 1011 ms |    \~ 1017 ms |
| jlink-atomos-compressed-app:17_openj9 | \~ 165 MB  |    \~ 1050 ms |    \~ 1126 ms |

Compared to the images without the shared class cache the size of the containers is about 20 - 25 MB bigger.

### GraalVM 17

For the GraalVM we only have benchmark results inside the container with an Alpine base image. The scratch image does not have shell scripting support.  

| Deployment (OSGi Connect)              | Image Size | Benchmark Image Size | Startup clean | Startup cache |
| :---                            |        ---:|                  ---:|           ---:|           ---:|
| graalvm:17                             | \~  38 MB  |            \~  46 MB |             - |             - |
| graalvm:17-alpine                      | \~  43 MB  |            \~  54 MB |      \~ 39 ms |      \~ 29 ms |

### Observations

- for folder based plain OSGi the clean start is slower than using a bundle cache
- for the plain OSGi executable jar and the custom runtime images based on it the clean start is likely as fast as the start with cache
- for the Atomos deployment variants the clean start is typically slower than the start with cache
- the startup performance of a custom runtime image created with the IBM Semeru (OpenJ9) `jlink` command is about twice as slow compared to the version created with Eclipse Temurin.
- using the `-Xquickstart` option the startup performance can be easily improved without any additional steps, which looks like a good way for small commandline applications.
- using the `-Xshareclasses` option to include and use a shared class cache the startup time can be improved further but of course on cost of image size.
- The smaller we get in size, the slower the startup. At least if we compare folder vs. executable vs. jlink vs. jlink compressed. The reason is probably the the format of the executable jar with embedded jars.

__Note:__  
The current results only investigate container size vs. startup performance. The effects on the runtime performance is NOT considered as of now. The Hotspot VM is able to optimize at runtime, which means that for long running applications like servers, the runtime performance can improve over time, which is for example not possible for native images created using GraalVM.

## Future Investigation: Processing time effects

TBD: maybe use APP4MC Migration to investigate the processing performance of the deployment variants.

## Future Investigation: Checkpoint and Restore

- [Instant On Java Cloud Applications with Checkpoint and Restore](https://www.youtube.com/watch?v=E_5MgOYnEpY)
- [Coordinated Restore at Checkpoint](https://github.com/CRaC/docs)
- [Liberty InstantOn startup for cloud native Java applications](https://openliberty.io/blog/2022/09/29/instant-on-beta.html)

