/*
 * Copyright (c) 2012 Francisco Salavert (ICM-CIPF)
 * Copyright (c) 2012 Ruben Sanchez (ICM-CIPF)
 * Copyright (c) 2012 Ignacio Medina (ICM-CIPF)
 *
 * This file is part of JS Common Libs.
 *
 * JS Common Libs is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * JS Common Libs is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with JS Common Libs. If not, see <http://www.gnu.org/licenses/>.
 */

'use strict';

function CapsidNavigationBar(args) {

  // Using Underscore 'extend' function to extend and add Backbone Events
  _.extend(this, Backbone.Events);

  this.id = Utils.genId('CapsidNavigationBar');

  this.species = 'Homo sapiens';
  this.increment = 3;

  //set instantiation args, must be last
  _.extend(this, args);

  //set new region object
  this.region = new Region(this.region);

  this.currentChromosomeList = [];

  this.on(this.handlers);

  this.rendered = false;
  if (this.autoRender) {
    this.render();
  }
}

CapsidNavigationBar.prototype = {

  render: function(targetId) {
    var _this, target;

    _this = this;
    this.targetId = targetId || this.targetId;
    target = jQuery('#' + this.targetId);

    if (target.length < 1) {
      console.log('targetId not found in DOM');
      return;
    }

    var navgationHtml =
//        '<button id="restoreDefaultRegionButton" class="t_button"><i class="icon-repeat"></i></button> ' +
        '<div class="btn-toolbar">' +
        '<div class="btn-group">' +
        '<button id="regionHistorybutton" class="btn dropdown-toggle" data-toggle="dropdown">' +
        '<i class="icon-time"></i> <span class="caret"></span></button>' +
        '<ul id="regionHistoryMenu" class="dropdown-menu"></ul>' +
        '<button id="zoomOutButton" class="btn"><i class="icon-zoom-out"></i></button>' +
        '</div>' +
        '<div id="slider" style="width:160px"></div>' +
        '<div class="btn-group">' +        
        '<button id="zoomInButton" class="btn"><i class="icon-zoom-in"></i></button> ' +
        '</div>' +
        '</div>';

//        icon-repeat
    this.targetDiv = target[0];
    this.div = jQuery('<div id="navigation-bar">' + navgationHtml + '</div>')[0];
    // @Capsid - need Nav functions but not the bar
    jQuery(this.targetDiv).append(this.div);

    this.restoreDefaultRegionButton = jQuery(this.div).find('#restoreDefaultRegionButton');
    this._handleRestoreDefaultRegion = function(e) {
      _this.trigger('restoreDefaultRegion:click', {clickEvent: e, sender: {}});
    };
    jQuery(this.restoreDefaultRegionButton).click(function(e) {
      _this._handleRestoreDefaultRegion(e);
    });

    this.regionHistoryMenu = this.regionHistoryMenu = jQuery(this.div).find('#regionHistoryMenu');
//        this.regionHistorybutton = this.regionHistoryMenu = jQuery(this.div).find('#regionHistoryButton');
    this._addRegionHistoryMenuItem(this.region);

    this.zoomSlider = jQuery(this.div).find('#slider');
    jQuery(this.zoomSlider).slider({
      min: 0,
      max: 100,
      value: this.zoom,
      step: 0.000001,
      tooltip: 'hide'
    }).on('slideStop', function(ev) {
        _this._handleZoomSlider(ev.value);
      });

//        {
//            range: "min",
//            value: this.zoom,
//            min: 0,
//            max: 100,
//            step: Number.MIN_VALUE,
//            stop: function (event, ui) {
//                _this._handleZoomSlider(ui.value);
//            }
//        });

//        jQuery('#foo').slider().on();

    this.zoomInButton = jQuery(this.div).find('#zoomInButton');
    this.zoomOutButton = jQuery(this.div).find('#zoomOutButton');
    jQuery(this.zoomOutButton).click(function() {
      _this._handleZoomOutButton();
    });
    jQuery(this.zoomInButton).click(function() {
      _this._handleZoomInButton();
    });

    this.rendered = true;
  },
  draw: function() {
    if (!this.rendered) {
      console.info(this.id + ' is not rendered yet');
    }
  },

  _addRegionHistoryMenuItem: function(region) {
    var _this = this;
    var menuEntry = jQuery('<li><a tabindex="-1">' + region.toString() + '</a></li>')[0];
    jQuery(this.regionHistoryMenu).append(menuEntry);
    jQuery(menuEntry).click(function() {
      _this.region.parse(jQuery(this).text());
      _this._recalculateZoom();
      _this.trigger('region:change', {region: _this.region, sender: _this});
      console.log(jQuery(this).text());
    });
  },

  _handleZoomOutButton: function() {
    this._handleZoomSlider(Math.max(0, this.zoom - 1));
    jQuery(this.zoomSlider).slider('setValue', this.zoom);
  },
  _handleZoomSlider: function(value) {
    this.zoom = value;
    this.region.load(this._calculateRegionByZoom());
    jQuery(this.regionField).val(this.region.toString());
    this._addRegionHistoryMenuItem(this.region);
    console.log("Zoom slider", this.region);
    this.trigger('region:change', {region: this.region, sender: this});
  },
  _handleZoomInButton: function() {
    this._handleZoomSlider(Math.min(100, this.zoom + 1));
    jQuery(this.zoomSlider).slider('setValue', this.zoom);
  },
  setRegion: function(region) {
    this.region.load(region);
    jQuery(this.chromosomeText).text(this.region.chromosome);
    jQuery(this.regionField).val(this.region.toString());
    this._recalculateZoom();
    this._addRegionHistoryMenuItem(region);

  },
  moveRegion: function(region) {
    this.region.load(region);
    jQuery(this.chromosomeText).text(this.region.chromosome);
    jQuery(this.regionField).val(this.region.toString());
    this._recalculateZoom();
  },
  setWidth: function(width) {
    this.width = width;
    this._recalculateZoom();
  },

  _recalculateZoom: function() {
//        console.log(this.zoom)
    this.zoom = this._calculateZoomByRegion();
//        console.log(this.zoom)
    jQuery(this.zoomSlider).slider('setValue', this.zoom);
  },

  _calculateRegionByZoom: function() {
    var zoomBaseLength = (this.width - this.svgCanvasWidthOffset) / Utils.getPixelBaseByZoom(this.zoom);
    var centerPosition = this.region.center();
    var aux = Math.ceil((zoomBaseLength / 2) - 1);
    var start = Math.floor(centerPosition - aux);
    var end = Math.floor(centerPosition + aux);
    return {start: start, end: end};
  },
  _calculateZoomByRegion: function() {
    return Utils.getZoomByPixelBase((this.width - this.svgCanvasWidthOffset) / this.region.length());
  },
  setVisible: function(obj) {
    for (var key in obj) {
      if (obj.hasOwnProperty(key)) {
        var query = jQuery(this.div).find('#' + key);
        if (obj[key]) {
          query.show();
        } else {
          query.hide();
        }
      }
    }
  },
  setFullScreenButtonVisible: function(bool) {
    this.fullscreenButton.setVisible(bool);
  }
};

