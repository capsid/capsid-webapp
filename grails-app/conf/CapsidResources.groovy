modules = {
    style {
    	dependsOn 'bootstrap'
    	//resource url:'less/variables.less',attrs:[rel: "stylesheet/less", type:'css'], bundle:'bundle_style'
    	//resource url:'less/mixins.less',attrs:[rel: "stylesheet/less", type:'css'], bundle:'bundle_style'
    	resource url:'less/responsive.less',attrs:[rel: "stylesheet/less", type:'css'], bundle:'bundle_style'
    	resource url:'less/style.less',attrs:[rel: "stylesheet/less", type:'css'], bundle:'bundle_style'

    }
    coffee {
        resource url:'cs/capsid.coffee'
    }
}