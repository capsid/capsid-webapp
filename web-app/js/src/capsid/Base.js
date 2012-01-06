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
       constructor : function() {},
       onFeatureClick : function() {
         alert('a');
       }
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

function accessPanel() {
    del();
    dojo.query('#access-panel').delegate('form', "onsubmit", function(e) {
                dojo.xhrPost({
                    form: this,
                    handle: 'text',
                    load:function(data) {
                        var userlist = dojo.query('#' + this.form.id + '-panel .user-box-wrap')[0],
                            userbox = dojo.create("span", {
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
                });
                e.preventDefault();
            });
}

dojo.ready(function() {
    capsid.form.Ajax.prototype.project();
    capsid.form.Ajax.prototype.sample();
    capsid.form.Ajax.prototype.alignment();
    capsid.form.Ajax.prototype.user();

    /* Add User to access group  */
    if (dojo.byId('access-panel')) { accessPanel(); }

    /* Delete Stuff */
    if (dojo.byId('deleteButton')) {
        dojo.connect(deleteButton, "onClick", deleteDialog, "show");
        dojo.connect(deleteCancel, "onClick", deleteDialog, "hide");
    }

    /* User Edit Change Password Form */
    if (dojo.byId('changepassButton')) {
      dojo.connect(changepassForm, "onSubmit", function(e) {
        if (password.get('value') != confirm.get('value')) {
            confirm.set( "state", "Error" );
            // used to change the style of the control to represent a error
            confirm._setStateClass();
            e.preventDefault();
        }
      });
    }
});
