import org.springframework.security.access.ConfigAttribute
import org.springframework.security.access.SecurityConfig
import org.springframework.security.web.access.intercept.RequestKey

class ChannelConfig {

	private ChannelConfig() {} // prevent instantiation

	static def getChannelConfig() {
		LinkedHashMap<RequestKey,java.util.Collection<ConfigAttribute>> requestMap = new LinkedHashMap<RequestKey, Collection<ConfigAttribute>>()

		// resources that can be served over http or https (typically whatever the containing page is served as)
		requestMap.put new RequestKey("/images/**"), [new SecurityConfig("ANY_CHANNEL")]
		requestMap.put new RequestKey("/css/**"), [new SecurityConfig("ANY_CHANNEL")]
		requestMap.put new RequestKey("/js/**"), [new SecurityConfig("ANY_CHANNEL")]
		requestMap.put new RequestKey("/favicon.ico"), [new SecurityConfig("ANY_CHANNEL")]

		// resources that must be served over https
		requestMap.put new RequestKey("/**"), [new SecurityConfig("REQUIRES_SECURE_CHANNEL")]
		
		// resources that must be served over http (basically everything else not already listed above)
		//requestMap.put new RequestKey("/**"), [new SecurityConfig("REQUIRES_INSECURE_CHANNEL")] // all other pages should be served over http

		requestMap
	}
}
