package ca.on.oicr.capsid

import grails.plugins.springsecurity.Secured

@Secured(['ROLE_CAPSID'])
class StatisticsController {

	static scaffold = true
	static navigation = [
		group:'statistics', 
		order:10, 
		title:'Statistics', 
		action:'list'
	]

	def list() {
        params.max = Math.min(params.max ? params.int('max') : 10, 100)
        [statisticsInstanceList: Statistics.list(params), statisticsInstanceTotal: Statistics.count()]
    }

}
