package twitter.bootstrap.scaffolding

/**
 * Bootstrap alerts tags.
 */
class AlertsTagLib {

    /** Set the namespace. */
	static namespace = "bootstrap"

	/**
	 * Generates an alert wrapper. 
	 */
	def alert = { attrs, body ->
		out << '<div class="alert alert-block fade in ' << attrs.class.tokenize().join(" ") << '">'
		out << '<a class="close" data-dismiss="alert">&times;</a>'
		out << '<p>' << body() << '</p>'
		out << '</div>'
	}

}
