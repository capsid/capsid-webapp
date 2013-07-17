/*
 *  Copyright 2011(c) The Ontario Institute for Cancer Research. All rights reserved.
 *
 *  This program and the accompanying materials are made available under the
 *  terms of the GNU Public License v3.0.
 *
 *  You should have received a copy of the GNU General Public License along with
 *  this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import org.codehaus.groovy.grails.resolve.IvyDependencyManager;

unJarTask = {jarFile,includePattern ->

    ant.mkdir(dir:"$stagingDir/tmp/")
    ant.unjar(src:jarFile, dest:"$stagingDir/tmp")
    ant.move(todir:"$stagingDir"){
        fileset(dir:"$stagingDir/tmp"){
            include (name: "$includePattern/**")
            exclude (name: "META-INF/**")
        }
    }
    ant.delete(dir:"$stagingDir/tmp")
}

eventCreateWarStart = {warName, stagingDir ->

    ant.mkdir(dir:"$stagingDir/ca/on/oicr/capsid/")
    ant.move(file:"$stagingDir/WEB-INF/classes/ca/on/oicr/capsid/Start.class",todir:"$stagingDir/ca/on/oicr/capsid/")

    IvyDependencyManager idm = grailsSettings.dependencyManager
    report = idm.resolveDependencies(IvyDependencyManager.PROVIDED_CONFIGURATION)
    for(a in report.allArtifactsReports) {
      if(a.artifact.moduleRevisionId.organisation == "org.mortbay.jetty") {
        unJarTask(a.localFile,"*")
      }
    }
}

eventCreateWarEnd = {warName, stagingDir ->
    ant.jar(destfile:warName, update:true) {
        manifest { attribute(name: "Main-Class", value: "ca.on.oicr.capsid.Start")}
    }
}
