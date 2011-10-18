import ca.on.oicr.capsid.*

class BootStrap {

    def springSecurityService

    def init = { servletContext ->
		
		def xenoRole = Role.findByAuthority('ROLE_CAPSID') ?: new Role(authority: 'ROLE_CAPSID').save(failOnError: true)
		def adminRole = Role.findByAuthority('ROLE_CAPSID_ADMIN') ?: new Role(authority: 'ROLE_CAPSID_ADMIN').save(failOnError: true)
		
		def adminUser = User.findByUsername("admin") ?: new User(
			username: "admin",
			userRealName: "CaPSID Administrator",
			email: "admin@company.com",
			password: springSecurityService.encodePassword('admin'),
			enabled: true).save(failOnError: true)

		if (!adminUser.authorities.id.contains(xenoRole.id)) {
			UserRole.create adminUser, xenoRole
		}
		if (!adminUser.authorities.id.contains(adminRole.id)) {
			UserRole.create adminUser, adminRole
		}
    }

    def destroy = {
    }
}
