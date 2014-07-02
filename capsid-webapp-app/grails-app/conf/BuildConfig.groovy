grails.servlet.version = "2.5" // Change depending on target container compliance (2.5 or 3.0)
grails.project.class.dir = "target/classes"
grails.project.test.class.dir = "target/test-classes"
grails.project.test.reports.dir = "target/test-reports"
grails.project.target.level = 1.7
grails.project.source.level = 1.7
//grails.project.war.file = "target/${appName}-${appVersion}.war"

grails.project.dependency.resolver = "maven"

grails.project.dependency.resolution = {
    // inherit Grails' default dependencies
    inherits("global") {
        // uncomment to disable ehcache
        // excludes 'ehcache'
    }
    log "error" // log level of Ivy resolver, either 'error', 'warn', 'info', 'debug' or 'verbose'
    checksums true // Whether to verify checksums on resolve

    repositories {
        inherits true // Whether to inherit repository definitions from plugins
        grailsPlugins()
        grailsHome()
        grailsCentral()
        mavenCentral()

        // uncomment these to enable remote dependency resolution from public Maven repositories
        //mavenCentral()
        //mavenLocal()
        //mavenRepo "http://snapshots.repository.codehaus.org"
        //mavenRepo "http://repository.codehaus.org"
        //mavenRepo "http://download.java.net/maven/2/"
        //mavenRepo "http://repository.jboss.com/maven2/"

        mavenRepo "https://oss.sonatype.org/content/repositories/snapshots"
        mavenRepo 'http://repo.spring.io/milestone'
    }
    dependencies {
        // specify dependencies here under either 'build', 'compile', 'runtime', 'test' or 'provided' scopes eg.

        // runtime 'mysql:mysql-connector-java:5.1.16'
        // provided 'org.mortbay.jetty:jetty:6.1.26'
        runtime 'org.mongodb:mongo-java-driver:2.12.2'
        compile "net.sf.ehcache:ehcache-core:2.4.8"
    }

    plugins {
        
        compile ':asset-pipeline:1.9.0'        
        
        compile ':fields:1.3'
        
        compile ':mail:1.0.6'
        compile ':spring-security-core:2.0-RC3'
        compile ":spring-security-ldap:2.0-RC2"
        compile ":scaffolding:2.1.2" 

        runtime ":mongodb:3.0.1"
        
        //runtime ":zipped-resources:latest.integration"
        //runtime ":cached-resources:latest.integration"
        runtime ":cache-headers:1.1.7"
        runtime ":webxml:1.4.1"
        
        build ":tomcat:7.0.54"
        
    }
}
