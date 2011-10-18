/*
 *  Copyright 2011(c) The Ontario Institute for Cancer Reserach. All rights reserved.
 *
 *	This program and the accompanying materials are made available under the
 *	terms of the GNU Public License v3.0.
 *
 *	You should have received a copy of the GNU General Public License along with
 *	this program.  If not, see <http://www.gnu.org/licenses/>.
 */

dojo.provide("capsid.form.Base");

(function(){
dojo.declare("capsid.form.Base", null, {
	form: '',
	constructor : function(form) {
		this.form = form;
	},
	wireButtonDialog: function(button, dialog) {
		dojo.connect(dijit.byId(button), "onClick", function() {
	    	dijit.byId(dialog).show();
		});
	},
	ajaxSubmit: function() {
		dojo.connect(dojo.byId(this.form), "onSubmit", function(e) {
			if (this.validate()) {
				dojo.xhrPost({
				      form: dojo.byId(this.form),
				      handle: 'html',
				      load: function(error) {
				    	  if (error === '') {
				    	  	window.location.reload();
				    	  }
				          dojo.byId("formError").innerHTML = error;
				      }
				    }) // xhrPost()
			}
			e.preventDefault();
		}); // connect()	
	}
});
})();
