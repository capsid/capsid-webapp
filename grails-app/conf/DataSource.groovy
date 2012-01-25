//check external configuration as described in Config.groovy
datasource {
	grails.mongo.host = "localhost"
	grails.mongo.databaseName = "capsid"
	grails.mongo.port = 27017
	grails.gridfs = grails.mongo.databaseName
}

