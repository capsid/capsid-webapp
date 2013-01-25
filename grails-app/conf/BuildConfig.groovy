grails.servlet.version = "2.5" // Change depending on target container compliance (2.5 or 3.0)
grails.project.class.dir = "target/classes"
grails.project.test.class.dir = "target/test-classes"
grails.project.test.reports.dir = "target/test-reports"
grails.project.target.level = 1.6
grails.project.source.level = 1.6
//grails.project.war.file = "target/${appName}-${appVersion}.war"

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
    }
    dependencies {
        // specify dependencies here under either 'build', 'compile', 'runtime', 'test' or 'provided' scopes eg.

        // runtime 'mysql:mysql-connector-java:5.1.16'
        provided 'org.mortbay.jetty:jetty:6.1.26'
    }

    plugins {
        
        compile ":resources:latest.integration"
        
        compile ":jquery:latest.integration"
        
        compile ':fields:latest.integration'
        
        compile ':navigation:latest.integration'
        compile ':mail:latest.integration'
        compile ':spring-security-core:latest.integration'
        compile ":spring-security-ldap:latest.integration"

        runtime ":mongodb:latest.integration"
        
        runtime ":zipped-resources:latest.integration"
        runtime ":cached-resources:latest.integration"
        runtime ":cache-headers:latest.integration"
        runtime ":yui-minify-resources:latest.integration"
        
        build ":tomcat:$grailsVersion"
        
    }
}
