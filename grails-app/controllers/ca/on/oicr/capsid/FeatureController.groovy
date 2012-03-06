package ca.on.oicr.capsid
import grails.plugins.springsecurity.Secured

@Secured(['ROLE_CAPSID'])
class FeatureController {

	static scaffold = true
	static navigation = [
		group:'genome', 
		order:20, 
		title:'Genes', 
		action:'list'
	]

	def create() { redirect action: 'list', params: params }
	def edit() { redirect action: 'list', params: params }
	def delete() { redirect action: 'list', params: params }
}
