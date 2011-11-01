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

function del() {
  /* Remove User from access group */
  dojo.query('.user-box').delegate('a.delete', 'onclick', function(e) {
    var a = this;
    dojo.anim(a.parentNode,{
      backgroundColor: '#fb6c6c'
    },300);
    dojo.stopEvent(e);
    dojo.xhr('post',{
      content: {
        ajax: 1
      },
      url: dojo.attr(a,'href'),
      load: function() {
        dojo.anim(a.parentNode,{
          opacity: 0
        },300,null,function() {
          dojo.query(a.parentNode).orphan();
        });
      }
    });
    userStore.close();
  });
}

dojo.ready(function() {
	/* Create Form */
	var ajaxForm = new capsid.form.Base('createForm');
	ajaxForm.wireButtonDialog('createButton', 'createDialog');
	ajaxForm.ajaxSubmit();

    /* Add User to access group  */
    var form = dojo.query('.addform');
    if (form) {
        dojo.query('#access-panel').delegate('form', "onsubmit", function(e) {
            dojo.xhrPost({
                form: this,
                handleAs: 'text',
                load:function(data) {
                    var userlist = dojo.query('#' + this.form.id + '-panel .user-box-wrap')[0];
                    var userbox = dojo.create("span", {
                        innerHTML: data,
                        style: "opacity:0"
                    }, userlist);
                    dojo.anim(userbox, {opacity:1}, 300);
                    del();
                    userStore.close();
                },
                error: function(error) {
                    console.log('error');
                }
            })
            e.preventDefault();
        });
    }

    del();
});
