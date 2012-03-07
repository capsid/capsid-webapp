modules = {
    style {
    	dependsOn 'bootstrap'
    	resource url:'less/style.less',attrs:[rel: "stylesheet/less", type:'css'], bundle:'bundle_style'
    }
    coffee {
        resource url:'cs/capsid.coffee'
    }
}