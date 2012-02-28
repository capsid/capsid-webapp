/*
 *  Copyright 2011(c) The Ontario Institute for Cancer Research. All rights reserved.
 *
 *	This program and the accompanying materials are made available under the
 *	terms of the GNU Public License v3.0.
 *
 *	You should have received a copy of the GNU General Public License along with
 *	this program.  If not, see <http://www.gnu.org/licenses/>.
 */

dojo.provide("capsid.form.Ajax");
dojo.require("capsid.form.Base");

(function(){
dojo.declare("capsid.form.Ajax", null, {
    constructor: function() {},
    project: function() {
      if (dojo.byId('addProjectButton')) {
        dojo.connect(dijit.byId('addProjectButton'), "onClick", addProjectDialog, "show");
        dojo.query('#addProjectDialog').delegate('form', "onsubmit", function(e) {
            e.preventDefault();
            dojo.xhrPost({
                form: dojo.byId('addProjectForm'),
                handle: 'html',
                load: function(msg) {
                  if (!msg === 'created') {
                      addProjectDialog.setContent(msg);
                  } else {
                    addProjectDialog.hide();
                    store.close();
                    grid._refresh();
                  }
                },
                error: function(error) {
                  var emsg = dojo.query('#addProjectDialog .error')[0];
                  emsg.innerHTML = 'Project Label already taken.';
                }
            });
        });
      }
    },
    sample: function() {
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
    },
    alignment: function() {
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
    },
    user: function() {
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
    }
});
})();
