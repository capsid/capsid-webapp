package twitter.bootstrap.scaffolding

import org.springframework.validation.Errors
import org.springframework.validation.FieldError

/**
 * Bootstrap forms tags.
 */
class FormsTagLib {

    /** Set the namespace. */
	static namespace = "bootstrap"
	
	/**
	 * Generates a form field error. 
	 */
	def fieldError = { attrs ->
		def bean = attrs.bean
		def field = attrs.field
		Errors errors = bean.errors
		FieldError error = errors.getFieldError(field)
		out << g.hasErrors(bean: bean, field: field) {
			out << '<span class="help-inline">'
			out << g.message(error: error)
			out << '</span>'
		}
		
	}
	
}
