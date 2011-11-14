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
// These can probably be refactored */
    /* Create Project */
    if (dojo.byId('createButton')) {
        dojo.connect(dijit.byId('createButton'), "onClick", createDialog, "show");
        dojo.query('#createDialog').delegate('form', "onsubmit", function(e) {
            e.preventDefault();
            dojo.xhrPost({
                form: dojo.byId('createForm'),
                handle: 'html',
                load: function(msg) {
                  if (!msg === 'created') {
                      createDialog.setContent(msg);
                  } else {
                    createDialog.hide();
                    store.close();
                    grid._refresh();
                  }
                },
                error: function(error) {
                  var emsg = dojo.query('#createDialog .error')[0];
                  emsg.innerHTML = 'Project Label already taken.';
                }
            });
        });
    }

    /* Create User */
    if (dojo.byId('addUserButton')) {
        dojo.connect(dijit.byId('addUserButton'), "onClick", addUserDialog, "show");
        dojo.query('#addUserDialog').delegate('form', "onsubmit", function(e) {
            e.preventDefault();
            dojo.xhrPost({
                form: dojo.byId('addUserForm'),
                handle: 'html',
                load: function(msg) {
                  if (!msg === 'created') {
                      addUserDialog.setContent(msg);
                  } else {
                      addUserDialog.hide();
                      store.close();
                      grid._refresh();
                  }
                },
                error: function(error) {
                  var emsg = dojo.query('#addUserDialog .error')[0];
                  emsg.innerHTML = 'Username already taken.';
                }
            });
        });
    }

   /* Add Sample */
   if (dojo.byId('addSampleButton')) {
     dojo.connect(dijit.byId('addSampleButton'), "onClick", function(){
         addSampleDialog.show();
         tabs.selectChild(sampleTab);
     });
     dojo.query('#addSampleDialog').delegate('form', "onsubmit", function(e) {
         e.preventDefault();
            dojo.xhrPost({
                form: dojo.byId('addSampleForm'),
                handle: 'html',
                load: function(msg) {
                  if (!msg === 'created') {
                      addSampleDialog.setContent(msg);
                  } else {
                    dojo.query('#alignhide').style('display','inline');
                    addSampleDialog.hide();
                    sampleStore.close();
                    sampleGrid._refresh();
                  }
                },
                error: function(error) {
                  var emsg = dojo.query('#addSampleDialog .error')[0];
                  emsg.innerHTML = 'Sample name already used.';
                }
            });
        });
   }

   /* Add Alignment */
   if (dojo.byId('addAlignButton')) {
     dojo.connect(dijit.byId('addAlignButton'), "onClick", function() {
         addAlignDialog.show();
         tabs.selectChild(alignTab);
     });
     dojo.query('#addAlignDialog').delegate('form', "onsubmit", function(e) {
         e.preventDefault();
            dojo.xhrPost({
                form: dojo.byId('addAlignForm'),
                handle: 'html',
                load: function(msg) {
                  if (!msg === 'created') {
                      addAlignDialog.setContent(msg);
                  } else {
                    addAlignDialog.hide();
                    alignStore.close();
                    alignGrid._refresh();
                  }
                },
                error: function(error) {
                  var emsg = dojo.query('#addAlignDialog .error')[0];
                  emsg.innerHTML = 'Alignment name already used.';
                }
            });
        });
   }

    /* Add User to access group  */
    if (dojo.byId('access-panel')) {
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

    if (dojo.byId('deleteButton')) {
        dojo.connect(deleteButton, "onClick", deleteDialog, "show");
        dojo.connect(deleteCancel, "onClick", deleteDialog, "hide");
    }

    del();
});
