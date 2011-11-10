/*
 *  Copyright 2011(c) The Ontario Institute for Cancer Reserach. All rights reserved.
 *
 *	This program and the accompanying materials are made available under the
 *	terms of the GNU Public License v3.0.
 *
 *	You should have received a copy of the GNU General Public License along with
 *	this program.  If not, see <http://www.gnu.org/licenses/>.
 */

dojo.provide("capsid.grid.Formatter");
dojo.require("capsid.grid.Base");

(function(){
dojo.declare("capsid.grid.Formatter", null, {
    constructor: function() {},
    links: {
        project: function(value) {
            return '<a href="' + baseUrl + '/project/show/' + value[0] + '">' + value[1].replace(/_/g, " ") +'</a>';
        },
        genome: function(value) {
            return '<a href="' + baseUrl + '/genome/show/' + value + '">' + value.replace(/_/g, " ")  + '</a>';
        },
        genomeDetails: function(value) {
            return '<a href="' + baseUrl + '/genome/project/' + value + '/' + dojo.byId("label").value + '">Genome details</a>';
        },
        sample: function(value) {
            return '<a href="' + baseUrl + '/sample/show/' + value + '">' + value.replace(/_/g, " ") +'</a>';
        },
        jbrowse: function(value) {
            return '<a href="' + baseUrl + '/jbrowse/show/' + value[0] + '?track=' + value[1] + '">Map with JBrowse</a>';
        },
        user: function(value) {
            return '<a href="' + baseUrl + '/user/edit/' + value + '">' + value.replace(/_/g, " ")  + '</a>';
        }
    },
    math: {
        percent: function(value) {
            return (value*100).toFixed(2) + '%';
        }
    },
    text: {
        human: function(value) {
            return value.replace(/[_-]/g, " ");
        }
    }
});
})();
