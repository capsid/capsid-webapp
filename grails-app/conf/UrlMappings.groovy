class UrlMappings {

	static mappings = {
		"/$controller/$action?/$id?"{
			constraints {
				// apply constraints here
			}
		}
		
		"/genome/project/$gid/$pid" (
			controller:"genome",
			action: "project"
		)
		
		"/"(controller:"project")
		"500"(view:'/error')
	}
}
