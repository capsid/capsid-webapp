/*
 *  Copyright 2011(c) The Ontario Institute for Cancer Reserach. All rights reserved.
 *
 *	This program and the accompanying materials are made available under the
 *	terms of the GNU Public License v3.0.
 *
 *	You should have received a copy of the GNU General Public License along with
 *	this program.  If not, see <http://www.gnu.org/licenses/>.
 */

dojo.provide("capsid.Base");

(function(){
dojo.declare("capsid.Base", null, {
	constructor : function() {}
});
})();

dojo.ready(function() {
	/* Create Form */
	var ajaxForm = new capsid.form.Base('createForm');
	ajaxForm.wireButtonDialog('createButton', 'createDialog');
	ajaxForm.ajaxSubmit();
});
