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

        "403"(controller: "errors", action: "error403")
        "500"(controller: "errors", action: "error500")
    }

}
