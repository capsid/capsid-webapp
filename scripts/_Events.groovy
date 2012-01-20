unJarTask = {jarName,includePattern ->

    ant.mkdir(dir:"$stagingDir/tmp/")
    ant.unjar(src:"$stagingDir/WEB-INF/lib/$jarName", dest:"$stagingDir/tmp")
    ant.move(todir:"$stagingDir"){
        fileset(dir:"$stagingDir/tmp"){
            include (name: "$includePattern/**")
            exclude (name: "META-INF/**")
        }
    }
    ant.delete(dir:"$stagingDir/tmp")
}
eventCreateWarStart = {warName, stagingDir ->
    ant.mkdir(dir:"$stagingDir/ca/on/oicr/ferv/")
    ant.move(file:"$stagingDir/WEB-INF/classes/ca/on/oicr/ferv/Start.class",todir:"$stagingDir/ca/on/oicr/ferv/")
    unJarTask("jetty-6.1.14.jar","org")
    unJarTask("jetty-util-6.1.14.jar","org")
    unJarTask("servlet-api-2.5-6.1.14.jar","javax")
}


eventCreateWarEnd = {warName, stagingDir ->
    def libPath =""
    File f = new File("$stagingDir/WEB-INF/lib")
    if(f.exists()){
        f.eachFile{ libPath += "WEB-INF/lib/${it.name} " }
    }
    ant.jar(destfile:warName, update:true) {
        manifest { attribute(name: "Main-Class", value: "ca.on.oicr.ferv.Start")}
        manifest { attribute(name: "Class-Path", value: "$libPath") }
    }
}
