//any item with chromosome start end
CapsidFeatureRenderer.prototype = new Renderer({});

function CapsidFeatureRenderer(args) {
    Renderer.call(this, args);
    // Using Underscore 'extend' function to extend and add Backbone Events
    _.extend(this, Backbone.Events);

    this.blockClass = 'capsid-feature';
    this.toolTipfontClass = 'ocb-font-default';

    //set default args
    if (_.isString(args)) {
        var config = this.getDefaultConfig(args);
        _.extend(this, config);
    }
    //set instantiation args
    else if (_.isObject(args)) {
        _.extend(this, args);
    }

    this.on(this.handlers);
};

function makePoints(list) {
    return list.map(function(point) {
        return point[0] + "," + point[1];
    }).join(" ");
};

CapsidFeatureRenderer.prototype.render = function (features, args) {
    var _this = this;

    _this.on("feature:click", function(a) {

        var pathname = location.pathname;
        var index = pathname.indexOf("/browse");
        if (index == -1) throw new Error("Internal error: an't locate URL root");
        pathname = pathname.substr(0, index);

        window.location.pathname = pathname + "/mapped/show/" + encodeURIComponent(a.feature.id);
    })

    var draw = function (feature) {
        //get feature render configuration
        var color = _.isFunction(_this.color) ? _this.color(feature) : _this.color;
        var label = _.isFunction(_this.label) ? _this.label(feature, args.zoom) : _this.label;
        var height = _.isFunction(_this.height) ? _this.height(feature) : _this.height;
        var tooltipTitle = _.isFunction(_this.tooltipTitle) ? _this.tooltipTitle(feature) : _this.tooltipTitle;
        var tooltipText = _.isFunction(_this.tooltipText) ? _this.tooltipText(feature) : _this.tooltipText;
        var infoWidgetId = _.isFunction(_this.infoWidgetId) ? _this.infoWidgetId(feature) : _this.infoWidgetId;

        //get feature genomic information
        var start = feature.start;
        var end = feature.end;
        var length = (end - start) + 1;

        //check genomic length
        length = (length < 0) ? Math.abs(length) : length;
        length = (length == 0) ? 1 : length;

        //transform to pixel position
        var width = length * args.pixelBase;

        //calculate x to draw svg rect
        var x = _this.getFeatureX(feature, args);

        var maxWidth = Math.max(width, 2);

        var rowY = 0;
        var rowHeight = height + 2;

        var arrowWidthX = height / 2;
        var arrowMidY = height / 2;

        while (true) {
            if (!(rowY in args.renderedArea)) {
                args.renderedArea[rowY] = new FeatureBinarySearchTree();
            }
            var foundArea = args.renderedArea[rowY].add({start: x, end: x + maxWidth - 1});

            if (foundArea) {
                var featureGroup = SVG.addChild(args.svgCanvasFeatures, "g", {'feature_id': feature.id});

                var genePath =
                    feature.strand == 1
                        ? ["M", x, rowY, "l", width, 0, "l", arrowWidthX, arrowMidY, "l", -arrowWidthX, arrowMidY, "l", -width, 0, "z"].join(" ")
                        : ["M", x, rowY, "l", -arrowWidthX, arrowMidY, "l", arrowWidthX, arrowMidY, "l", width, 0, "l", 0, -height, "l", -width, 0, "z"].join(" ")

                var path = SVG.addChild(featureGroup, "path", {
                    'class':_this.blockClass + ' ' + (feature.isRef ? "read_ref" : "read_noref"),
                    'd': genePath
                });

                if ('tooltipText' in _this) {
                    $(featureGroup).qtip({
                        content: {text: tooltipText, title: tooltipTitle},
//                        position: {target: "mouse", adjust: {x: 15, y: 0}, effect: false},
                        position: {target: "mouse", adjust: {x: 25, y: 15}},
                        style: { width: true, classes: _this.toolTipfontClass+' ui-tooltip ui-tooltip-shadow'}
                    });
                }

                $(featureGroup).mouseover(function (event) {
                    _this.trigger('feature:mouseover', {query: feature[infoWidgetId], feature: feature, featureType: feature.featureType, mouseoverEvent: event})
                });

                $(featureGroup).click(function (event) {
                    _this.trigger('feature:click', {query: feature[infoWidgetId], feature: feature, featureType: feature.featureType, clickEvent: event})
                });

                break;
            }
            rowY += rowHeight;
        }
    };

    //process features
    for (var i = 0, leni = features.length; i < leni; i++) {
        draw(features[i]);
    }
};

