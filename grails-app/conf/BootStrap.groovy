import ca.on.oicr.capsid.*

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
            password: springSecurityService.encodePassword('admin'),
            enabled: true).save(failOnError: true)

        if (!adminUser.authorities.id.contains(capsidRole.id)) {
            UserRole.create adminUser, capsidRole, ['read', 'write', 'admin'] as Set
        }
    }

    def destroy = {
    }
}
