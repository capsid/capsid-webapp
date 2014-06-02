class UrlMappings {

	static mappings = {

		// Add a project label to the id for identifying a sample
		"/sample/$action?/$projectLabel?/$id?"(controller: "sample")

		"/genome/$action/$id"(controller: "genome")
		"/genome/$action"(controller: "genome")

		"/feature/$action/$id"(controller: "feature")
		"/feature/$action"(controller: "feature")

		"/browse/$action/$id/$projectLabel?/$sampleName?"(controller: "browse")

		"/alignment/$action?/$projectLabel?/$sampleName?/$id?"(controller: "alignment")

		"/$controller/$action?/$id?"{
			constraints {
				// apply constraints here
			}
		}

		"/"(controller:"project")
		"500"(view:'/error')
	}
}
