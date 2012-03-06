package ca.on.oicr.capsid
import grails.plugins.springsecurity.Secured

@Secured(['ROLE_CAPSID'])
class GenomeController {

	static scaffold = true
	static navigation = [
		group:'genome', 
		order:10, 
		title:'Genomes', 
		action:'list'
	]

	def create() { redirect action: 'list', params: params }
	def edit() { redirect action: 'list', params: params }
	def delete() { redirect action: 'list', params: params }
}
