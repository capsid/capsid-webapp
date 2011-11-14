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
	          form: null,
                  dialog: null,
	          constructor : function(form) {
		    base.form = form;
	          },
	          wireButtonDialog: function(button, dialog) {
                    base.dialog = dialog;
		    dojo.connect(button, "onClick", function() {
	                           dialog.show();
		                 });
	          },
	          ajaxSubmit: function() {
		    dojo.connect(this.form, "onSubmit", function(e) {
			           if (this.validate()) {
				     dojo.xhrPost({
				                    form: this.form,
				                    handle: 'html',
				                    load: function(error) {
				    	              /*
                                                       if (error === '') {
				    	  	       window.location.reload();
				    	               }
				                       dojo.byId("formError").innerHTML = error;
                                                       */
				                      base.dialog.hide();
                                                      store.close();
                                                    }
				                  }); // xhrPost()
			           }
			           e.preventDefault();
		                 }); // connect()
	          }
                });
 })();
