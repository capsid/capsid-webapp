package ca.on.oicr.capsid
import grails.plugins.springsecurity.Secured

@Secured(['ROLE_CAPSID'])
class AlignmentController {

	static scaffold = true
	static navigation = [
		group:'project', 
		order:30, 
		title:'Alignments', 
		action:'list'
	]
}