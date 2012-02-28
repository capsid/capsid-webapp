import ca.on.oicr.capsid.*

import org.springframework.security.web.util.AntUrlPathMatcher
import org.springframework.security.web.access.intercept.DefaultFilterInvocationSecurityMetadataSource
import org.springframework.security.web.access.channel.SecureChannelProcessor
import org.springframework.security.web.access.channel.InsecureChannelProcessor
import org.springframework.security.web.access.channel.ChannelProcessingFilter
import org.springframework.security.web.access.channel.ChannelDecisionManagerImpl

beans = {
	userDetailsService(MongoUserDetailsService)

	// -------------------------------------------------------------------------
	// -------------------------------------------------------------------------
	// SPRING SECURITY (CHANNEL SECURITY)
	channelDecisionManager(ChannelDecisionManagerImpl) {
		channelProcessors = [new SecureChannelProcessor(),
							new InsecureChannelProcessor()]
	}
	securityMetadataSource(DefaultFilterInvocationSecurityMetadataSource,
							new AntUrlPathMatcher(),
							ChannelConfig.getChannelConfig()) {
		stripQueryStringFromUrls = true
	}
	channelProcessingFilter(ChannelProcessingFilter) {
		channelDecisionManager = ref("channelDecisionManager")
		securityMetadataSource = ref("securityMetadataSource")
	}
}
