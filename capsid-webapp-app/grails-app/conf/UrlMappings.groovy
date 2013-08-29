class UrlMappings {

	static mappings = {

		// Add a project label to the id for identifying a sample
		"/sample/$action?/$projectLabel?/$id?"(controller: "sample")

		"/genome/$action?/$projectLabel?/$id?"(controller: "genome")

		"/$controller/$action?/$id?"{
			constraints {
				// apply constraints here
			}
		}

		"/"(controller:"project")
		"500"(view:'/error')
	}
}
