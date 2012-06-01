import java.security.ProtectionDomain;
import java.net.URL;
import java.io.File;

grails.project.groupId = appName // change this to alter the default package name and Maven publishing destination
grails.mime.file.extensions = true // enables the parsing of file extensions from URLs into the request format
grails.mime.use.accept.header = false
grails.mime.types = [ html: ['text/html','application/xhtml+xml'],
                      xml: ['text/xml', 'application/xml'],
                      text: 'text/plain',
                      js: 'text/javascript',
                      rss: 'application/rss+xml',
                      atom: 'application/atom+xml',
                      css: 'text/css',
                      csv: 'text/csv',
                      all: '*/*',
                      json: ['application/json','text/json'],
                      form: 'application/x-www-form-urlencoded',
                      multipartForm: 'multipart/form-data'
                    ]

// URL Mapping Cache Max Size, defaults to 5000
//grails.urlmapping.cache.maxsize = 1000

// What URL patterns should be processed by the resources plugin
grails.resources.adhoc.patterns = ['/images/*', '/css/*', '/js/*', '/plugins/*']


// The default codec used to encode data with ${}
grails.views.default.codec = "none" // none, html, base64
grails.views.gsp.encoding = "UTF-8"
grails.converters.encoding = "UTF-8"
// enable Sitemesh preprocessing of GSP pages
grails.views.gsp.sitemesh.preprocess = true
// scaffolding templates configuration
grails.scaffolding.templates.domainSuffix = 'Instance'

// Set to false to use the new Grails 1.2 JSONBuilder in the render method
grails.json.legacy.builder = false
// enabled native2ascii conversion of i18n properties files
grails.enable.native2ascii = true
// packages to include in Spring bean scanning
grails.spring.bean.packages = []
// whether to disable processing of multi part requests
grails.web.disable.multipart=false

// request parameters to mask when logging exceptions
grails.exceptionresolver.params.exclude = ['password']

// enable query caching by default
grails.hibernate.cache.queries = true

// set per-environment serverURL stem for creating absolute links
environments {
    development {
        grails.logging.jul.usebridge = true
    }
    production {
        grails.logging.jul.usebridge = false
        // TODO: grails.serverURL = "http://www.changeme.com"
    }
}

// log4j configuration
log4j = {
    // Example of changing the log pattern for the default console
    // appender:
    //
    //appenders {
    //    console name:'stdout', layout:pattern(conversionPattern: '%c{2} %m%n')
    //}

    error  'org.codehaus.groovy.grails.web.servlet',  //  controllers
           'org.codehaus.groovy.grails.web.pages', //  GSP
           'org.codehaus.groovy.grails.web.sitemesh', //  layouts
           'org.codehaus.groovy.grails.web.mapping.filter', // URL mapping
           'org.codehaus.groovy.grails.web.mapping', // URL mapping
           'org.codehaus.groovy.grails.commons', // core / classloading
           'org.codehaus.groovy.grails.plugins', // plugins
           'org.codehaus.groovy.grails.orm.hibernate', // hibernate integration
           'org.springframework',
           'org.hibernate',
           'net.sf.ehcache.hibernate'
    warn   'grails.plugins.twitterbootstrap'
}

// Added by the Spring Security Core plugin:
grails.plugins.springsecurity.userLookup.userDomainClassName = 'ca.on.oicr.capsid.User'
grails.plugins.springsecurity.userLookup.authorityJoinClassName = 'ca.on.oicr.capsid.UserRole'
grails.plugins.springsecurity.authority.className = 'ca.on.oicr.capsid.Role'

// Added by the Spring Security LDAP plugin:
grails.plugins.springsecurity.ldap.context.anonymousReadOnly = true
grails.plugins.springsecurity.ldap.authorities.groupSearchFilter = 'memberUid={1}'
grails.plugins.springsecurity.ldap.authorities.retrieveDatabaseRoles = true
grails.plugins.springsecurity.ldap.authorities.retrieveGroupRoles = true

// Twitter Bootstrap
grails.plugins.twitterbootstrap.customDir = 'less'

/**
 * Running externalized configuration
 * Assuming the following configuration files
 * - config location set path by system variable '<APP_NAME>_CONFIG_PATH'
 */

grails.config.locations = ["classpath:${appName}-config.groovy"]
def defaultConfigFiles = ["${appName}-config.groovy"]

// Find the absolute path of of the war
try {
  Class startClass = Class.forName("ca.on.oicr.capsid.Start");
  ProtectionDomain protectionDomain = startClass.getProtectionDomain();
  URL location = protectionDomain.getCodeSource().getLocation();
  File file = new File(location.toURI().getPath());
  String war_location = file.getParentFile().toString()

  defaultConfigFiles << war_location + "/${appName}-config.groovy"
} catch(ClassNotFoundException e) {
  // embedded
}
defaultConfigFiles.each { filePath ->
  def f = new File(filePath)
  if (f.exists()) {
    grails.config.locations << "file:${filePath}"
  }
}

def externalConfig = System.getenv(appName.toUpperCase() + "_CONFIG_PATH")
if (externalConfig) {
  grails.config.locations << "file:" + externalConfig
}

externalConfig = System.getProperty(appName.toUpperCase() + "_CONFIG_PATH")
if (externalConfig) {
  grails.config.locations << "file:" + externalConfig
}

grails.config.locations.each {
  println "[INFO] Including configuration file [${it}] in configuration building."
}
