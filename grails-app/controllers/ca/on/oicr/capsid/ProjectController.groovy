package ca.on.oicr.capsid
import grails.plugins.springsecurity.Secured

@Secured(['ROLE_CAPSID'])
class ProjectController {

	static scaffold = true
	static navigation = [
		group:'project', 
		order:10, 
		title:'Project', 
		action:'list'
	]
}
