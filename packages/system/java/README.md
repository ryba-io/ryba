# Java

* Install openjdk
* Install multiple versions of Oracle JDK
* Install JCE extension for each Oracle JDK
* Set JAVA_HOME in the system profile

## Configuration

### Options

* `java_home` (string)   
* `jre_home` (string)   
* `openjdk` (string)   
* `jdk` (object)   
* `jdk.version` (object)   
   Default JDK to use.
* `jdk.versions` (object)   
   Define all the JDKs to install
* `jdk.versions.{version}` (object)   
   Define a JDK to install
* `jdk.versions.{version}.jdk_location` (object)   
   URL or local path to the JDK package (tar.gz, zip shall work as well)
* `jdk.versions.{version}.jce_location` (object)   
   URL or local path to the JCE libraries (zip)

### Default configuration

```yaml
java_home: /usr/java/default
jre_home: /usr/java/default/jre
openjdk: false
jdk:
  root_dir: /usr/java
  version: 1.8.0_152
  versions:
    1.8.0_152:
      jdk
        source: https://download.oracle.com/otn-pub/java/jdk/8u202-b08/1961070e4c9b4e26a04e7f5a083f551e/jdk-8u202-linux-x64.tar.gz
        md5: 0029351f7a946f6c05b582100c7d45b7
      jce
        source: http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip
        md5: md5
```

### Example with OpenJDK and Oracle JDK:

```yaml
openjdk: true
jdk:
  version: 1.7.0_79
  versions:
    1.7.0_79:
      jdk:
        source: http://download.oracle.com/otn-pub/java/jdk/7u79-b15/jdk-7u79-linux-x64.tar.gz
        sha256: 29d75d0022bfa211867b876ddd31a271b551fa10727401398295e6e666a11d90
      jce:
        source: http://download.oracle.com/otn-pub/java/jce/7/UnlimitedJCEPolicyJDK7.zip
        sha256: 7a8d790e7bd9c2f82a83baddfae765797a4a56ea603c9150c87b7cdb7800194d
    }
    1.8.0_121:
      jdk:
        source: http://download.oracle.com/otn-pub/java/jdk/8u121-b14/jdk-8u121-linux-x64.tar.gz
        sha256: 467f323ba38df2b87311a7818bcbf60fe0feb2139c455dfa0e08ba7ed8581328
      jce:
        source: http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip
        sha256: f3020a3922efd6626c2fff45695d527f34a8020e938a49292561f18ad1320b59
```

## Java Install

Install the Oracle Java JRE and JDK. The Java Runtime Environment is the code
execution component of the Java platform. The Java Development Kit (JDK) is
an implementation of either one of the Java SE, Java EE or Java ME platforms[1]
released by Oracle Corporation in the form of a binary product aimed at Java
developers on Solaris, Linux, Mac OS X or Windows.

TODO: leverage /etc/alternative to switch between multiple JDKs.

### Oracle JDK && Java Cryptography Extension

At this time, it is recommanded to run Hadoop against the Oracle Java JDK. Since RHEL and CentOS
come with the OpenJDK installed and to avoid any ambiguity, we simply remove the OpenJDK.

For licensing reason, the Oracle Java JDK is not available from a Yum repository. It is the
integrator responsibility to download the jdk manually and reference it
inside the configuration. The properties "jce\_local\_policy" and
"jce\_us\_export_policy" must be modified accordingly with an appropriate location.

The Java Cryptography Extension (JCE) provides a framework and implementation for encryption,
key generation and key agreement, and Message Authentication Code (MAC) algorithms. JCE
supplements the Java platform, which already includes interfaces and implementations of
message digests and digital signatures.

Like for the Oracle Java JDK, for licensing reason, the JCE is not available from a Yum
repository. It is the phyla integrator responsibility to download the jdk manually and
reference it inside the configuration. The properties "jce\_local\_policy" and
"jce\_us\_export_policy" must be modified accordingly with an appropriate location.

Modified status is only needed on the last two copy commands, which means the jars
have been copied or not (in case they already exist).

## Notes

Open JDK require the "java-1.8.0-openjdk-devel" package or Java will default to gij.

Java home are:

*  Open JDK or gij: "/usr/lib/jvm/java"
*  Oracle JDK: "/usr/java/default"

We do not attempt to remve GCJ because it is a requirement of the "mysql-connector-java"
and removing the GCJ package also remove the MySQL connector package.

## Resources

*   [Oracle JDK 6](http://www.oracle.com/technetwork/java/javasebusiness/downloads/java-archive-downloads-javase6-419409.html#jdk-6u45-oth-JPR)
*   [Oracle JDK 7](http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html)
*   [Instructions to install Oracle JDK with alternative](http://www.if-not-true-then-false.com/2010/install-sun-oracle-java-jdk-jre-6-on-fedora-centos-red-hat-rhel/)
*   [metalcated script](https://github.com/metalcated/Scripts/blob/master/install_java.sh)
