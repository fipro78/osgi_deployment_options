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
java -jar org.eclipse.osgi-3.18.500.jar
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

The build is using the [bnd Maven Plugins](https://github.com/bndtools/bnd/tree/master/maven-plugins).

Further information can be found here:
 - [bnd](https://bnd.bndtools.org/)
 - [Bndtools](https://bndtools.org/)
 - [bnd Maven Plugins](https://github.com/bndtools/bnd/tree/master/maven-plugins)
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

[GraalVM Native Image - Getting Started](https://www.graalvm.org/reference-manual/native-image/)

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
If creating an executable jar with Atomos is required, the usage of the [Spring Boot Loader](https://docs.spring.io/spring-boot/docs/current/reference/html/executable-jar.html) is suggested and shown in the [Atomos Spring Loader Example](https://github.com/apache/felix-atomos/tree/master/atomos.examples/atomos.examples.springloader)
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

The gathering of reachability metadata is described in more detail in the official [GraalVM Documentation - Native Image Reachability Metadata](https://www.graalvm.org/reference-manual/native-image/metadata/)

Further information about GraalVM Native Images and Reachability Metadata:
- [GraalVM Native Image - Getting Started](https://www.graalvm.org/reference-manual/native-image/)
- [GraalVM Native Image - Reachability Metadata](https://www.graalvm.org/reference-manual/native-image/metadata/)
- [GraalVM Native Image - Collect Metadata with the Tracing Agent](https://www.graalvm.org/reference-manual/native-image/metadata/AutomaticMetadataCollection/)
- [GraalVM Native Image - Accessing Resources in Native Image](https://www.graalvm.org/reference-manual/native-image/dynamic-features/Resources/)
- [GraalVM Native Image - Reflection in Native Image](https://www.graalvm.org/reference-manual/native-image/dynamic-features/Reflection/)

__Note:__  
There are also tools that can help in generating the metadata, e.g. the Atomos Maven Plugin is able to do this in the build process.

### Building

Building a native image can be done in different ways. One way is to use the official build plugins:
- [Maven plugin for GraalVM Native Image building](https://graalvm.github.io/native-build-tools/latest/maven-plugin.html)
- [Gradle plugin for GraalVM Native Image building](https://graalvm.github.io/native-build-tools/latest/gradle-plugin.html)

The issue facing with this approach is, that the resulting native image is platform-dependent, e.g. if you execute the build on Windows you will get a Windows executable.

Alternatively you can use a multi-stage build that uses the official GraalVM container images for the build stage.  

__Note:__  
[In June 2023 Oracle announced](https://medium.com/graalvm/a-new-graalvm-release-and-new-free-license-4aab483692f5) that with version 23 the distribution is named __Oracle GraalVM__ and distributed under the [GraalVM Free License](https://blogs.oracle.com/cloud-infrastructure/post/graalvm-free-license). This means the previously named __Oracle GraalVM Enterprise__ is now available for free.  

Use the __Oracle GraalVM__ container image from the [Oracle Container Registry](https://container-registry.oracle.com/ords/f?p=113:10::::::) or alternatively the __GraalVM Community Edition__ container from the [GitHub Container Registry](https://github.com/orgs/graalvm/packages). But the most current version is only published via the Oracle Container Registry.

For a multi-stage build you first need to choose the GraalVM image for building the native executable. There are native-image container images that can directly be used without the need for further modifications, for example in the [Oracle Container Registry](https://container-registry.oracle.com/ords/f?p=113:10::::::):

```
FROM container-registry.oracle.com/graalvm/native-image:21-muslib-ol9 AS build
```

Or from the [GitHub Container Registry](https://github.com/orgs/graalvm/packages):

```
FROM ghcr.io/graalvm/native-image-community:21-muslib-ol9 AS build
```
__Note:__  
Using the native-image container image, the ENTRYPOINT is `native-image`, so you need to either pass the right parameters, or override the ENTRYPOINT so the command is called with the approriate parameters in a multi-stage-build.


Alternatively you can use the jdk image for the desired version from the [Oracle Container Registry](https://container-registry.oracle.com/ords/f?p=113:10::::::):

```
FROM container-registry.oracle.com/graalvm/jdk:21-muslib-ol9 AS build
```

Or alternatively the base community edition image from the [GitHub Container Registry](https://github.com/orgs/graalvm/packages):

```
FROM ghcr.io/graalvm/jdk-community:21-ol9 AS build
```

But using the jdk image or the community edition base image you need to install the `native-image` tool in order to be able to build a native image. Additionally you need to install `musl` if the resulting executable should finally be included in an `alpine` or `scratch` image, to get the smallest possible result.

```
# Set up musl, in order to produce a static image compatible to alpine
# See 
# https://github.com/oracle/graal/issues/2824 and 
# https://github.com/oracle/graal/blob/vm-ce-22.0.0.2/docs/reference-manual/native-image/StaticImages.md
ARG RESULT_LIB="/musl"
RUN mkdir ${RESULT_LIB} && \
    curl -L -o musl.tar.gz https://more.musl.cc/10.2.1/x86_64-linux-musl/x86_64-linux-musl-native.tgz && \
    tar -xvzf musl.tar.gz -C ${RESULT_LIB} --strip-components 1 && \
    cp /usr/lib/gcc/x86_64-redhat-linux/8/libstdc++.a ${RESULT_LIB}/lib/
ENV CC=/musl/bin/gcc
RUN curl -L -o zlib.tar.gz https://zlib.net/zlib-1.2.13.tar.gz && \
    mkdir zlib && tar -xvzf zlib.tar.gz -C zlib --strip-components 1 && \
    cd zlib && ./configure --static --prefix=/musl && \
    make && make install && \
    cd / && rm -rf /zlib && rm -f /zlib.tar.gz
ENV PATH="$PATH:/musl/bin"

# Install native-image
RUN gu install native-image
```

This repository is using the multi-stage build using the native-image community edition container image to create a statically linked native executable which is then placed in the smallest possible image (e.g. `scratch`). The Docker files for reference can be found [here](org.fipro.service.app/src/main/docker/graalvm_native_scratch).

Below are some links to use the GraalVM Community Edition from the GitHub Container Registry:
- [GraalVM Community Images](https://www.graalvm.org/docs/getting-started/container-images/)
- [GraalVM Community Edition Container Images](https://github.com/graalvm/container)
- [GraalVM GitHub Container Registry](https://github.com/orgs/graalvm/packages)
- [Build a Statically Linked or Mostly-Statically Linked Native Executable](https://www.graalvm.org/reference-manual/native-image/guides/build-static-executables/)
- [Containerise a Native Executable and Run in a Docker Container](https://www.graalvm.org/reference-manual/native-image/guides/containerise-native-executable-and-run-in-docker-container/)

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

When planning to containerize a Java application, the first decision to make is which base image to use. For this the base image size is taken as the leading criteria here. Other criterias can be security, additional required tooling, target infrastructure. The following tables only compare the image sizes (values taken from images pulled on 2023/12/10):

| Image                | Size     |
| :---                 |      ---:|
| alpine:3             |  7.33 MB |
| debian:bullseye-slim | 80.55 MB |
| ubuntu:jammy         | 77.82 MB |

Related to Java the main difference between Alpine Linux and Debian/Ubuntu is the libc implementation. Alpine uses musl while Debian/Ubuntu are using glibc.

| Image                | Size (11)    | Size (17)    | Size (21)    |
| :---                 |          ---:|          ---:|          ---:|
| eclipse-temurin:xx-jdk-jammy<br>(Ubuntu base image with JDK)  | \~ 392 MB | \~ 407 MB | \~ 435 MB |
| eclipse-temurin:xx-jdk-alpine<br>(Alpine base image with JDK) | \~ 290 MB | \~ 304 MB | \~ 332 MB |
| eclipse-temurin:xx-jre-jammy<br>(Ubuntu base image with JRE)  | \~ 254 MB | \~ 269 MB | \~ 292 MB |
| eclipse-temurin:xx-jre-alpine<br>(Alpine base image with JRE) | \~ 154 MB | \~ 167 MB | \~ 190 MB |
| ibm-semeru-runtimes:open-xx-jdk-jammy                         | \~ 473 MB | \~ 482 MB | \~ xxx MB |
| ibm-semeru-runtimes:open-xx-jre-jammy                         | \~ 274 MB | \~ 275 MB | \~ xxx MB |

### Interlude: Distroless

_"Distroless" images contain only your application and its runtime dependencies. They do not contain package managers, shells or any other programs you would expect to find in a standard Linux distribution._

["Distroless" Container Images](https://github.com/GoogleContainerTools/distroless)

Distroless images are intended to create a smaller attack surface, reduce compliance scope, and results in a small, performant image.

| Image                             |  Size     |
| :---                              |       ---:|
| [gcr.io/distroless/static-debian11](https://github.com/GoogleContainerTools/distroless/tree/main/base) |   2.45 MB |
| [gcr.io/distroless/base-debian11](https://github.com/GoogleContainerTools/distroless/tree/main/base)   |  20.45 MB |
| [gcr.io/distroless/java11-debian11](https://github.com/GoogleContainerTools/distroless/tree/main/java) | 209.12 MB |
| [gcr.io/distroless/java17-debian11](https://github.com/GoogleContainerTools/distroless/tree/main/java) | 226.07 MB |
| [gcr.io/distroless/static-debian12](https://github.com/GoogleContainerTools/distroless/tree/main/base) |   1.98 MB |
| [gcr.io/distroless/base-debian12](https://github.com/GoogleContainerTools/distroless/tree/main/base)   |  20.68 MB |
| [gcr.io/distroless/java17-debian12](https://github.com/GoogleContainerTools/distroless/tree/main/java) | 225.66 MB |

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

- temurin_11
- temurin_17
- temurin_21
- graalvm_17
- graalvm_21
- graalvm_ce_17
- graalvm_ce_21
- semeru_17

To build the Temurin 17 and the Oracle GraalVM 17 containers at once, execute the build by specifying the profiles like this:

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
mvn -Ddocker.keepRunning=true -Dbenchmark.iteration_count=5 clean verify -Pjava17,temurin_17,graalvm_17
```

```
mvn -Ddocker.keepRunning=true -Dbenchmark.iteration_count=5 clean verify -Pjava11,temurin_11
```

```
mvn -Ddocker.keepRunning=true -Dbenchmark.iteration_count=5 clean verify -Ptemurin_21,graalvm_21
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
java -Dorg.osgi.framework.storage.clean=onFirstInit -jar org.eclipse.osgi-3.18.500.jar
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

### Eclipse Temurin 21

| Deployment (plain OSGi)         | Benchmark Image Size | Startup clean | Startup cache |
| :---                            |                  ---:|           ---:|           ---:|
| folder-app:11_temurin           |            \~ 194 MB |    \~  920 ms |    \~ 1023 ms |
| executable-app:11_temurin       |            \~ 195 MB |    \~ 1073 ms |    \~ 1112 ms |
| jlink-app:11_temurin            |            \~  87 MB |    \~ 1315 ms |    \~ 1355 ms |
| jlink-compressed-app:11_temurin |            \~  62 MB |    \~ 1455 ms |    \~ 1464 ms |


| Deployment (OSGi Connect)       | Benchmark Image Size | Startup clean | Startup cache |
| :---                            |                  ---:|           ---:|           ---:|
| folder-atomos-app:11_temurin<br>classpath<br>modulepath           |            \~ 194 MB |     <br>\~ 1275 ms<br>\~  1204 ms |     <br>\~ 988 ms<br>\~ 1020 ms |
| jlink-atomos-app:11_temurin            |            \~  87 MB |    \~ 1293 ms |    \~ 1308 ms |
| jlink-atomos-compressed-app:11_temurin |            \~  62 MB |    \~ 1441 ms |    \~ 1442 ms |

### Eclipse Temurin 17

| Deployment (plain OSGi)         | Image Size | Benchmark Image Size | Startup clean | Startup cache |
| :---                            |        ---:|                  ---:|           ---:|           ---:|
| folder-app:17_temurin           | \~ 169 MB  |            \~ 171 MB |     \~ 984 ms |    \~ 1019 ms |
| executable-app:17_temurin       | \~ 170 MB  |            \~ 172 MB |    \~ 1086 ms |    \~ 1149 ms |
| jlink-app:17_temurin            | \~  78 MB  |            \~  81 MB |    \~ 1425 ms |    \~ 1409 ms |
| jlink-compressed-app:17_temurin | \~  56 MB  |            \~  58 MB |    \~ 1511 ms |    \~ 1489 ms |


| Deployment (OSGi Connect)              | Image Size | Benchmark Image Size | Startup clean | Startup cache |
| :---                            |        ---:|                  ---:|           ---:|           ---:|
| folder-atomos-app:17_temurin<br>classpath<br>modulepath           | \~ 169 MB  |            \~ 171 MB |     <br>\~ 1479 ms<br>\~  1450 ms |     <br>\~ 960 ms<br>\~ 1072 ms |
| jlink-atomos-app:17_temurin            | \~  78 MB  |            \~  81 MB |    \~ 1394 ms |    \~ 1350 ms |
| jlink-atomos-compressed-app:17_temurin | \~  56 MB  |            \~  58 MB |    \~ 1526 ms |    \~ 1528 ms |

### Eclipse Temurin 11

| Deployment (plain OSGi)         | Benchmark Image Size | Startup clean | Startup cache |
| :---                            |                  ---:|           ---:|           ---:|
| folder-app:11_temurin           |            \~ 159 MB |    \~ 1136 ms |    \~ 1070 ms |
| executable-app:11_temurin       |            \~ 160 MB |    \~ 1208 ms |    \~ 1187 ms |
| jlink-app:11_temurin            |            \~  79 MB |    \~ 1387 ms |    \~ 1433 ms |
| jlink-compressed-app:11_temurin |            \~  57 MB |    \~ 1589 ms |    \~ 1556 ms |


| Deployment (OSGi Connect)       | Benchmark Image Size | Startup clean | Startup cache |
| :---                            |                  ---:|           ---:|           ---:|
| folder-atomos-app:11_temurin<br>classpath<br>modulepath           |            \~ 159 MB |     <br>\~ 1611 ms<br>\~ 1494 ms |     <br>\~ 1098 ms<br>\~ 1163 ms |
| jlink-atomos-app:11_temurin            |            \~  79 MB |    \~ 1411 ms |    \~ 1436 ms |
| jlink-atomos-compressed-app:11_temurin |            \~  57 MB |    \~ 1589 ms |    \~ 1556 ms |

### IBM Semeru 17

| Deployment (plain OSGi)        | Benchmark Image Size | Startup clean | Startup cache |
| :---                           |                  ---:|           ---:|           ---:|
| folder-app:17_openj9           |            \~ 278 MB |    \~ 1101 ms |    \~ 1017 ms |
| executable-app:17_openj9       |            \~ 279 MB |    \~ 1288 ms |    \~ 1200 ms |
| jlink-app:17_openj9            |            \~ 166 MB |    \~ 2591 ms |    \~ 2604 ms |
| jlink-compressed-app:17_openj9 |            \~ 143 MB |    \~ 2748 ms |    \~ 2777 ms |


| Deployment (OSGi Connect)              | Benchmark Image Size | Startup clean | Startup cache |
| :---                            |                  ---:|           ---:|           ---:|
| folder-atomos-app:17_openj9<br>classpath<br>modulepath           |            \~ 278 MB |     <br>\~ 1041 ms<br>\~ 1126 ms |     <br>\~ 1039 ms<br>\~ 1124 ms |
| jlink-atomos-app:17_openj9            | \~ 166 MB  |    \~ 2492 ms |    \~ 2562 ms |
| jlink-atomos-compressed-app:17_openj9 | \~ 143 MB  |    \~ 3309 ms |    \~ 2714 ms |

__Note:__  
After a discussion with some IBM experts at the EclipseCon Europe we discovered some options to improve the startup performance.

### IBM Semeru 17 - -Xquickstart

In this scenario the same images are used as in the IBM Semeru 17 scenario. Only the [-Xquickstart](https://www.eclipse.org/openj9/docs/xquickstart/) option is set to improve the startup performance.

| Deployment (plain OSGi)        | Benchmark Image Size | Startup clean | Startup cache |
| :---                           |                  ---:|           ---:|           ---:|
| folder-app:17_openj9           |            \~ 278 MB |    \~ 1052 ms |    \~ 1022 ms |
| executable-app:17_openj9       |            \~ 279 MB |    \~ 1222 ms |    \~ 1198 ms |
| jlink-app:17_openj9            |            \~ 166 MB |    \~ 1656 ms |    \~ 1645 ms |
| jlink-compressed-app:17_openj9 |            \~ 143 MB |    \~ 1777 ms |    \~ 1794 ms |


| Deployment (OSGi Connect)              | Benchmark Image Size | Startup clean | Startup cache |
| :---                            |                  ---:|           ---:|           ---:|
| folder-atomos-app:17_openj9<br>classpath<br>modulepath           |            \~ 278 MB |     <br>\~ 1016 ms<br>\~ 1097 ms |     <br>\~ 1021 ms<br>\~ 1108 ms |
| jlink-atomos-app:17_openj9            | \~ 166 MB  |    \~ 1603 ms |    \~ 1630 ms |
| jlink-atomos-compressed-app:17_openj9 | \~ 143 MB  |    \~ 1714 ms |    \~ 1725 ms |

### IBM Semeru 17 - -Xshareclasses

In this scenario images are created that contain a shared class cache. For this a multi-stage build is used that is first creating a shared class cache with a default size and then ensures to limit the size of the shared class cache in a second step to avoid wasted space. For this the [-Xshareclasses](https://www.eclipse.org/openj9/docs/xshareclasses/) option is used together with the [-Xscmx](https://www.eclipse.org/openj9/docs/xscmx/) JVM option. The script that does the cache creation and optimization is located [here](org.fipro.service.app/src/main/resources/init_scc_size.sh).  
The application together with the created class cache is then copied to the final production image. Additional information is available at [Introduction to class data sharing](https://www.eclipse.org/openj9/docs/shrc/)

__Note:__  
To use the `-Xshareclasses` option with a custom runtime image with `jlink` you need to ensure that the module `openj9.sharedclasses` is added to the extra modules. Otherwise the shareclasses support is missing in the custom runtime.  
Also note that [class sharing is enabled by default](https://blog.openj9.org/2019/10/15/openj9-class-sharing-is-enabled-by-default/), which is especially important to know when trying to run a custom JRE image that was created using `jlink` in a default IBM Semeru container. If the module `openj9.sharedclasses` is not included in the custom JRE, it won't start on the default IBM Semeru container. Copying it to another container will work if the shared class cache is not enabled.

| Deployment (plain OSGi)        | Benchmark Image Size | Startup clean | Startup cache |
| :---                           |                  ---:|           ---:|           ---:|
| folder-app:17_openj9           |            \~ 299 MB |    \~  721 ms |    \~  641 ms |
| executable-app:17_openj9       |            \~ 301 MB |    \~ 1004 ms |    \~ 1010 ms |
| jlink-app:17_openj9            |            \~ 189 MB |    \~ 1083 ms |    \~ 1098 ms |
| jlink-compressed-app:17_openj9 |            \~ 166 MB |    \~ 1177 ms |    \~ 1200 ms |


| Deployment (OSGi Connect)              | Benchmark Image Size | Startup clean | Startup cache |
| :---                            |                  ---:|           ---:|           ---:|
| folder-atomos-app:17_openj9<br>classpath<br>modulepath           |            \~ 302 MB |     <br>\~ 734 ms<br>\~ 831 ms |     <br>\~ 750 ms<br>\~ 801 ms |
| jlink-atomos-app:17_openj9            | \~ 190 MB  |    \~ 1110 ms |    \~ 1180 ms |
| jlink-atomos-compressed-app:17_openj9 | \~ 167 MB  |    \~ 1170 ms |    \~ 1224 ms |

Compared to the images without the shared class cache the size of the containers is about 20 - 25 MB bigger.

__Note:__  
The combination of using Atomos with the modulepath and the OpenJ9 `-Xshareclasses` option leads to an `IllegalAccessError`. See https://github.com/eclipse-equinox/equinox/issues/158 for further details.  
Until a fix is included in Equinox, this can be fixed locally by adding `--add-reads org.eclipse.osgi=openj9.sharedclasses`. This increases the class cache size up to 80 MB.

### GraalVM Community 17

For the GraalVM we only have benchmark results inside the container with an Alpine base image. The scratch image does not have shell scripting support.  

| Deployment (OSGi Connect)              | Image Size | Benchmark Image Size | Startup clean | Startup cache |
| :---                            |        ---:|                  ---:|           ---:|           ---:|
| graalvm-ce:17                             | \~  41 MB  |            \~  50 MB |             - |             - |
| graalvm-ce:17-alpine                      | \~  46 MB  |            \~  58 MB |      \~ 58 ms |      \~ 63 ms |

### GraalVM Community 21

For the GraalVM we only have benchmark results inside the container with an Alpine base image. The scratch image does not have shell scripting support.  

| Deployment (OSGi Connect)              | Image Size | Benchmark Image Size | Startup clean | Startup cache |
| :---                            |        ---:|                  ---:|           ---:|           ---:|
| graalvm-ce:21                             | \~  42 MB  |            \~  53 MB |             - |             - |
| graalvm-ce:21-alpine                      | \~  48 MB  |            \~  60 MB |      \~ 62 ms |      \~ 38 ms |

### Oracle GraalVM 17

For the GraalVM we only have benchmark results inside the container with an Alpine base image. The scratch image does not have shell scripting support.  

| Deployment (OSGi Connect)              | Image Size | Benchmark Image Size | Startup clean | Startup cache |
| :---                            |        ---:|                  ---:|           ---:|           ---:|
| graalvm:17                             | \~  47 MB  |            \~  58 MB |             - |             - |
| graalvm:17-alpine                      | \~  52 MB  |            \~  65 MB |      \~ 52 ms |      \~ 45 ms |

### Oracle GraalVM 21

For the GraalVM we only have benchmark results inside the container with an Alpine base image. The scratch image does not have shell scripting support.  

| Deployment (OSGi Connect)              | Image Size | Benchmark Image Size | Startup clean | Startup cache |
| :---                            |        ---:|                  ---:|           ---:|           ---:|
| graalvm:21                             | \~  46 MB  |            \~  57 MB |             - |             - |
| graalvm:21-alpine                      | \~  52 MB  |            \~  64 MB |      \~ 49 ms |      \~ 29 ms |

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

## Future Investigation: Checkpoint/Restore in Userspace (CRIU)

Get AOT like startup performance with JIT runtime performance and behavior using [CRIU](https://criu.org/Main_Page).

There are two variants available:

### OpenJDK CRaC

Azul Systems developed CRaC in OpenJDK. They also provide a Zulu JDK with CRaC support for Linux since April 2023.

To create checkpoint data:
- start the application with the ```-XX:CRaCCheckpointTo=<path>``` parameter
- create the checkpoint 
  - programmatically via ```jdk.crac.Core``` API
  - manually via ```jcmd <PID> JDK.checkpoint``` command in a separate shell process


To restore an application from a checkpoint use the parameter ```-XX:CRaCRestoreFrom=<path>```

Current state July 2023:
- Only available for Linux, but no Alpine (musl)
- Building a custom JRE (jlink) currently not easily possible  
(need to manually copy criu to the system)
- Containers with CRaC support not available out-of-the-box
- No support for graphical user interfaces (actually not really the scope)
- As OSGi opens the nested jars at runtime, the checkpoint creation fails with exceptions

Further information:
- [Coordinated Restore at Checkpoint](https://github.com/CRaC/docs)
- [Azul Coordinated Restore at Checkpoint](https://www.azul.com/products/components/crac/)
- [Java on CRaC: Superfast JVM Application Startup](https://www.youtube.com/watch?v=bWmuqh6wHgE)
- [What the CRaC](https://www.youtube.com/watch?v=Y9sEXOGlvoA)
- [How to Run a Java Application with CRaC in a Docker Container](https://foojay.io/today/how-to-run-a-java-application-with-crac-in-a-docker-container/)


### OpenJ9 CRIU / Open Liberty InstantOn

CRIU support in OpenJ9 is prebuilt in IBM Semeru containers. Open Liberty uses this feature and provides containers with the InstantOn feature for Liberty server applications.

Enable the CRIU support in OpenJ9 via the ```-XX:+EnableCRIUSupport``` parameter.

To create a checkpoint you need to use the ```org.eclipse.openj9.criu.CRIUSupport``` API. In this example the checkpoint creation is done in the [BenchmarkCRIUSupport](/org.fipro.osgi.benchmark.criu/src/main/java/org/fipro/osgi/benchmark/criu/BenchmarkCRIUSupport) immediate component.

To create a container with checkpoint data, a three step process is needed.
 - Create an image with the application
  - Start the container to create the checkpoint
  - Create a new image from the base one with checkpoint data and a changed CMD to start the application via `criu restore` 
  
  To execute the process more easily, the shell script [build_criu_image_docker.sh](/org.fipro.service.app.criu/src/main/resources/build_criu_image_docker.sh) is used. Note the use of special Linux capabilities and the disabling of the default security profile on starting the container for checkpoint creation.

CRIU needs the original PID and TID when it restores a checkpointed process. To ensure that the PID is available in a container, we invoke a dummy command 1000 times so the Java process can start with PID/TIDs >1000, which on restore are very likely to be free. Thanks [Younes Manton](https://github.com/ymanton) for this and many other hints via this [GitHub Issue](https://github.com/eclipse-openj9/openj9/issues/18229)!

Starting a checkpointed Java process is done by directly calling the `criu` command:

```
criu restore --unprivileged -D /app/checkpointData --shell-job -v4 --log-file=restore.log
```

To start the container with the application which is restored from checkpoint, you also need to use the necessary Linux capabilities and disable the default security profile. The start for the container of this example can be done via the [start_container_docker.sh](/org.fipro.service.app.criu/src/main/resources/start_container_docker.sh) script.

__Note:__  
With Podman the disabling of the default security profile is not necessary, but the Podman commands need to be executed in a rootful container or all podman commands need to be executed as root via `sudo`.

On trying to restore the Java process from checkpoint multiple times for the benchmark, I noticed that only the first restore operation succeeds. Further restore operations after the first on stopped fail. The reasons where on the one hand the changed `stdout` and `stderr` files created to handle the std out/err/in to terminals in unprivileged mode. On the other hand there where issues with missing temporary files I haven't digged deeper into. Could be caused by the OSGi runtime as additional bundles for the benchmark request processing are loaded.

Instead of starting the process in the same container multiple times, the container itself is created and started multiple times. The benchmark execution of the criu containers is therefore not done via the Maven Docker Plugin. It is done via the [start_benchmark_docker.sh](/org.fipro.osgi.benchmark.app/start_benchmark_docker.sh) script which is triggered in the Maven build via the [exec-maven-plugin](https://www.mojohaus.org/exec-maven-plugin/).  
To use Podman instead of Docker, adjust the value of the property `benchmark.container.engine` in the [pom.xml](/org.fipro.osgi.benchmark.app/pom.xml) of the `org.fipro.osgi.benchmark.app` project.

To start the build for creating the container images and starting the benchmark, execute the following command:

```
mvn -Ddocker.keepRunning=true -Dbenchmark.iteration_count=10 clean verify -Pcriu
```

| Deployment      | Base Image Size<br>(ibm-semeru-runtimes:open-17-jre-ubi9) | App Image Size<br>w/o checkpoint data  | App Image Size<br>w/ checkpoint data | Startup Time |
| :---            |                 :---:|          ---:|          ---:| ---:|
| folder-criu     |            \~ 431 MB |    \~ 433 MB |    \~ 470 MB | \~ 169 ms|
| executable-criu |            \~ 431 MB |    \~ 436 MB |    \~ 477 MB | \~ 150 ms|

__Note:__  
The `folder-criu` example contains cache data, while the `executable-criu` by default starts clean, which explains the size difference.

I received very helpful and friendly support via [GitHub Issue](https://github.com/eclipse-openj9/openj9/issues/18229) to get this example working with OpenJ9 CRIU support. The comments contain a lot of interesing detail information.

Current limitations of this example:
- The restore process can only be triggered once and not in a loop inside the container. The reason seems to be that temporary files get generated and are not available on consecutive calls.
- It is not possible to change environment variables and pass new parameters to be effective in the restored application.
- The handling of the console to get a connection via telnet is not trivial and causes sometimes issues, e.g. if a restored process writes to the console, a consecutive restore operation fails because the output file has changed.

Current state/limitations of OpenJ9 CRIU January 2024:
- Only Linux, no Alpine as IBM Semeru containers are not available for Alpine
- Not clear if building a custom JRE with jlink is possible
- Checkpoint creation is only possible via API, not via shell command
- Special capabilities and disabling the default security profile is needed in order to create a checkpoint and restore from it
- The creation of the image is mainly a three step process:
  - Create an image with the application
  - Start the container to create the checkpoint
  - Create a new image from the base one with checkpoint data and a changed CMD to start the application via `criu restore` 

Further information:
- [GitHub Issue](https://github.com/eclipse-openj9/openj9/issues/18229)
- [OpenJ9 CRIU support](https://eclipse.dev/openj9/docs/criusupport/)
- [Fast JVM startup with OpenJ9 CRIU Support](https://blog.openj9.org/2022/09/26/fast-jvm-startup-with-openj9-criu-support/)
- [Getting started with OpenJ9 CRIU Support](https://blog.openj9.org/2022/09/26/getting-started-with-openj9-criu-support/)
- [Unprivileged OpenJ9 CRIU Support](https://blog.openj9.org/2022/09/29/unprivileged-openj9-criu-support/)
- [OpenJ9 CRIU Support: A look under the hood](https://blog.openj9.org/2022/10/14/openj9-criu-support-a-look-under-the-hood/)
- [OpenJ9 CRIU Support: A look under the hood (part II)](https://blog.openj9.org/2022/10/14/openj9-criu-support-a-look-under-the-hood-part-ii/)
- [How We Developed the Eclipse OpenJ9 CRIU Support for Fast Java Startup](https://foojay.io/today/how-we-developed-the-eclipse-openj9-criu-support-for-fast-java-startup/)
- [Liberty InstantOn startup for cloud native Java applications](https://openliberty.io/blog/2022/09/29/instant-on-beta.html)
- [How to package your cloud-native Java application for rapid startup](https://openliberty.io/blog/2023/06/29/rapid-startup-instanton.html)
- [How to containerize your Spring Boot application for rapid startup](https://openliberty.io/blog/2023/09/26/spring-boot-3-instant-on.html)
- [Faster startup for containerized applications with Open Liberty InstantOn](https://openliberty.io/docs/latest/instanton.html)
- [Instant On Java Cloud Applications with Checkpoint and Restore](https://www.youtube.com/watch?v=E_5MgOYnEpY)

