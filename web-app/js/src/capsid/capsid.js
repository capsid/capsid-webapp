/*
 *  Copyright 2011(c) The Ontario Institute for Cancer Reserach. All rights reserved.
 *
 *	This program and the accompanying materials are made available under the
 *	terms of the GNU Public License v3.0.
 *
 *	You should have received a copy of the GNU General Public License along with
 *	this program.  If not, see <http://www.gnu.org/licenses/>.
 */

dojo.provide('capsid.capsid')

//Form
dojo.require("dijit.form.Form");
dojo.require("dijit.form.Textarea");
dojo.require('dijit.form.ValidationTextBox');
dojo.require('dijit.form.FilteringSelect');
dojo.require('dijit.InlineEditBox');
dojo.require("dojox.validate.regexp");
dojo.require("dojox.form.PasswordValidator");
dojo.require("dojox.form.MultiComboBox")

// Tabs
dojo.require('dijit.layout.TabContainer');
dojo.require('dijit.layout.ContentPane');

// DataGrid
dojo.require("dojox.grid.EnhancedGrid");
dojo.require("dojox.grid.enhanced.plugins.Pagination");
dojo.require("dojox.grid.enhanced.plugins.Filter");
dojo.require("dojox.grid.enhanced.plugins.Cookie");
dojo.require("dojox.grid.cells");

// Data Stores
dojo.require("dojox.data.AndOrReadStore");

// capsid
dojo.require("capsid.Base");
dojo.require("capsid.form.Base");
dojo.require("capsid.form.Inline");
dojo.require("capsid.grid.Formatter");
