package ca.on.oicr.capsid
import grails.plugins.springsecurity.Secured

@Secured(['ROLE_CAPSID'])
class SampleController {

	static scaffold = true
	static navigation = [
		group:'project', 
		order:20, 
		title:'Samples', 
		action:'list'
	]
}
