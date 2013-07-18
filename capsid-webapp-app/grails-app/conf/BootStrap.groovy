import ca.on.oicr.capsid.*

// Note: to debug Mongo, use the following command to start the app:
// grails -DDB.TRACE=true -DDEBUG.MONGO=true run-app

class BootStrap {

    def springSecurityService

    def init = { servletContext ->
        createUser()
    }

    private void createUser() {
        def capsidRole = Role.findByAuthority('ROLE_CAPSID') ?: new Role(authority: 'ROLE_CAPSID').save(failOnError: true)

        def adminUser = User.findByUsername("admin") ?: new User(
            username: "admin",
            userRealName: "CaPSID Administrator",
            email: "admin@company.com",
            institute: '',
            location: '',
            password: springSecurityService.encodePassword('admin'),
            enabled: true).save(failOnError: true)

        if (!adminUser.authorities.id.contains(capsidRole.id)) {
            UserRole.create adminUser, capsidRole, 'owner'
        }
    }

    def destroy = {
    }
}