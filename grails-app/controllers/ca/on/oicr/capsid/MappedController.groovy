package ca.on.oicr.capsid
import grails.plugins.springsecurity.Secured

@Secured(['ROLE_CAPSID'])
class MappedController {

	static scaffold = true
	static navigation = [
		group:'project', 
		order:40, 
		title:'Reads', 
		action:'list'
	]
}