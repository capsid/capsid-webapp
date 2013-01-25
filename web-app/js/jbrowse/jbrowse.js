/**
 * Construct a new Browser object.
 * @class This class is the main interface between JBrowse and embedders
 * @constructor
 * @param params a dictionary with the following keys:<br>
 * <ul>
 * <li><code>containerID</code> - ID of the HTML element that contains the browser</li>
 * <li><code>refSeqs</code> - list of reference sequence information items (usually from refSeqs.js)</li>
 * <li><code>trackData</code> - list of track data items (usually from trackInfo.js)</li>
 * <li><code>dataRoot</code> - (optional) URL prefix for the data directory</li>
 * <li><code>browserRoot</code> - (optional) URL prefix for the browser code</li>
 * <li><code>tracks</code> - (optional) comma-delimited string containing initial list of tracks to view</li>
 * <li><code>location</code> - (optional) string describing the initial location</li>
 * <li><code>defaultTracks</code> - (optional) comma-delimited string containing initial list of tracks to view if there are no cookies and no "tracks" parameter</li>
 * <li><code>defaultLocation</code> - (optional) string describing the initial location if there are no cookies and no "location" parameter</li>
 * </ul>
 */

var faceted_on = true;
var track_customization_hidden = false;
var track_customization_on = true;
var elastic_zoom_high_on = true;
var elastic_zoom_on = true;

var Browser = function(params) {
    dojo.require("dojo.dnd.Source");
    dojo.require("dojo.dnd.Moveable");
    dojo.require("dojo.dnd.Mover");
    dojo.require("dojo.dnd.move");
    dojo.require("dijit.layout.ContentPane");
    dojo.require("dijit.layout.BorderContainer");

    this.disabledColor = '#9E9E9E';
    this.trackClass = {};

    var flags = params.conf['flags'];
    this.popUpUrl = params.conf['popUpUrl'];

    if(flags) {
        if(flags['facetedOff']) faceted_on = false;
        if(flags['trackCustomizationOff']) track_customization_on = false;
        if(flags['trackCustomizationHidden']) track_customization_hidden = true;
        if(flags['elasticZoomsOff']) {
            elastic_zoom_high_on = false; 
            elastic_zoom_on = false;
        }
        if(flags['elasticZoomTopOff']) elastic_zoom_high_on = false;
        if(flags['elasticZoomMainOff']) elastic_zoom_on = false;
        if(!track_customization_on) track_customization_hidden = true;
    }

    var refSeqs = params.refSeqs;
    var trackData = params.trackData;
    this.deferredFunctions = [];
    this.dataRoot = params.dataRoot;
    var dataRoot;
    if ("dataRoot" in params)
        dataRoot = params.dataRoot;
    else
        dataRoot = "";

    this.names = null; //new LazyTrie(dataRoot + "/names/lazy-",
			      //dataRoot + "/names/root.json");
    this.tracks = [] ;
    var brwsr = this;
    brwsr.isInitialized = false;
    dojo.addOnLoad(
        function() {
            //set up top nav/overview pane and main GenomeView pane
            dojo.addClass(document.body, "tundra");
            brwsr.container = dojo.byId(params.containerID);
            brwsr.container.genomeBrowser = brwsr;
            var topPane = document.createElement("div");
            brwsr.container.appendChild(topPane);

            var overview = document.createElement("div");
            overview.className = "overview";
            overview.id = "overview";
            topPane.appendChild(overview);
            //try to come up with a good estimate of how big the location box
            //actually has to be
            var maxBase = refSeqs.reduce(function(a,b) {return a.end > b.end ? a : b;}).end;
            var navbox = brwsr.createNavBox(topPane, (2 * (String(maxBase).length + (((String(maxBase).length / 3) | 0) / 2))) + 2, params);

            var viewElem = document.createElement("div");
            brwsr.container.appendChild(viewElem);
            viewElem.className = "dragWindow";

            var containerWidget = new dijit.layout.BorderContainer({
                liveSplitters: true,
                design: "sidebar",
                gutters: false
            }, brwsr.container);
            var contentWidget = new dijit.layout.ContentPane({region: "top"}, topPane);
            var browserWidget = new dijit.layout.ContentPane({region: "center"}, viewElem);

            //create location trapezoid
            brwsr.locationTrap = document.createElement("div");
            brwsr.locationTrap.className = "locationTrap";
            topPane.appendChild(brwsr.locationTrap);
            topPane.style.overflow="hidden";

            //set up ref seqs
            brwsr.allRefs = {};
            for (var i = 0; i < refSeqs.length; i++) {
                brwsr.allRefs[refSeqs[i].name] = refSeqs[i];
            }

            var refCookie = dojo.cookie(params.containerID + "-refseq");
            brwsr.refSeq = refSeqs[0];
            for (var i = 0; i < refSeqs.length; i++) {
                brwsr.chromList.options[i] = new Option(refSeqs[i].name,
                                                        refSeqs[i].name);
                if (refSeqs[i].name.toUpperCase() == String(refCookie).toUpperCase()) {
                    brwsr.refSeq = brwsr.allRefs[refSeqs[i].name];
                    brwsr.chromList.selectedIndex = i;
                }
            }

            dojo.connect(brwsr.chromList, "onchange", function(event) {
                    var oldLocMap = dojo.fromJson(dojo.cookie(brwsr.container.id + "-location")) || {};
                    var newRef = brwsr.allRefs[brwsr.chromList.options[brwsr.chromList.selectedIndex].value];

                    if (oldLocMap[newRef.name])
                        brwsr.navigateTo(newRef.name + ":"
                                         + oldLocMap[newRef.name]);
                    else
                        brwsr.navigateTo(newRef.name + ":"
                                         + (((newRef.start + newRef.end) * 0) | 0)
                                         + " .. "
                                         + (((newRef.start + newRef.end) * 1) | 0));
                        });

            //hook up GenomeView
            var gv = new GenomeView(viewElem, 250, brwsr.refSeq, 1/200, params.overviewTrackData);
            brwsr.view = gv;
            brwsr.viewElem = viewElem;
            //gv.setY(0);
            viewElem.view = gv;

            dojo.connect(browserWidget, "resize", function() { //viewResizeTest();});
                    gv.sizeInit();

                    brwsr.view.locationTrapHeight = dojo.marginBox(navbox).h;
                    gv.showVisibleBlocks();
                    gv.showFine();
                    gv.showCoarse();
                    gv.resetChromBands();
                });

            brwsr.view.locationTrapHeight = dojo.marginBox(navbox).h;

            dojo.connect(gv, "onFineMove", brwsr, "onFineMove");
            dojo.connect(gv, "onCoarseMove", brwsr, "onCoarseMove");

            //set up track list
            brwsr.createTrackList(brwsr.container, params);
            containerWidget.startup();

	    brwsr.isInitialized = true;

            //set initial location
            var oldLocMap = dojo.fromJson(dojo.cookie(brwsr.container.id + "-location")) || {};
/* #TODO Removed so it stays zoomed out
            if (params.location) {
                brwsr.navigateTo(params.location);
            } else if (oldLocMap[brwsr.refSeq.name]) {
                brwsr.navigateTo(brwsr.refSeq.name
                                 + ":"
                                 + oldLocMap[brwsr.refSeq.name]);
            } else if (params.defaultLocation){
                brwsr.navigateTo(params.defaultLocation);
            } else {*/
                brwsr.navigateTo(brwsr.refSeq.name
                                 + ":"
                                 + (((brwsr.refSeq.start + brwsr.refSeq.end) * 0.0) | 0)
                                 + " .. "
                                 + (((brwsr.refSeq.start + brwsr.refSeq.end) * 1.0) | 0));
           //}

            if(elastic_zoom_on) brwsr.createRubberBandZoom(topPane, gv);
            if(elastic_zoom_high_on) brwsr.createHighLevelRubberBandZoom(brwsr.refSeq);

	    //if someone calls methods on this browser object
	    //before it's fully initialized, then we defer
	    //those functions until now
	    for (var i = 0; i < brwsr.deferredFunctions.length; i++)
		brwsr.deferredFunctions[i]();
	    brwsr.deferredFunctions = [];

        });
};

/*
 * Creates the rubber band zoom over for the track display area. 
 * Initiated by clicking on the grey distance bar at the top of the display area.
 */
Browser.prototype.createRubberBandZoom = function(topPane, gv) {
    brwsr = this;

    // creates the transparent track area that covers that displayed tracks when zooming
    var bandZoom = document.createElement("div");
    bandZoom.id = 'bandZoom';
    bandZoom.style.cssText = "height: "+screen.height+"px; display: none; cursor: default;"; 
    topPane.appendChild(bandZoom);

    // creates the line representing the end of the zoom that doesn't move
    var dynamicZoomStart = document.createElement("div");
    dynamicZoomStart.id = 'dynamicZoomStart';
    dynamicZoomStart.style.height = screen.height+"px";
    dynamicZoomStart.className = "dynamicZoomLine";
    bandZoom.appendChild(dynamicZoomStart);

    // creates the line representing the end of the zoom that moves
    this.dynamicZoom = document.createElement("div");
    this.dynamicZoom.id = 'dynamicZoom';
    this.dynamicZoom.style.height = screen.height+"px";
    this.dynamicZoom.className = "dynamicZoomLine";
    bandZoom.appendChild(this.dynamicZoom);
    this.zoomMover = new dojo.dnd.move.parentConstrainedMoveable(this.dynamicZoom, {area: "margin", within: true});
    this.view.zoomMover = this.zoomMover;

    // creates the transparent red box that covers the area the will be zoomed to
    var selectedArea = document.createElement("div");
    selectedArea.id = 'selectedArea';
    selectedArea.style.cssText = "height: "+screen.height+"px";
    selectedArea.className = "dynamicZoomArea";
    bandZoom.appendChild(selectedArea);

    // expand the area selected when the end of the zoom is moved
    dojo.connect(this.zoomMover, "onMove", function(mover, leftTop) {
        var leftSide = parseInt(dojo.byId('dynamicZoomStart').style.left);
        var rightSide = leftTop.l;
        if(rightSide < leftSide) {
            var temp = rightSide;
            rightSide = leftSide;
            leftSide = temp;
        } 
        dojo.byId('selectedArea').style.width = rightSide - leftSide + "px";
        dojo.byId('selectedArea').style.left = leftSide + "px";
    });

    // zoom to the selected area when mouse released
    dojo.connect(this.zoomMover, "onMoveStop", function() { 
        dojo.byId('bandZoom').style.display = "none";
        dojo.byId('selectedArea').style.width = "0px";
        var start = Math.round(gv.minVisible()+ parseInt(dojo.byId('dynamicZoomStart').style.left) / parseInt(dojo.byId('dijit_layout_ContentPane_1').style.width) * (gv.maxVisible()-gv.minVisible()));
        var end = Math.round(gv.minVisible()+ parseInt(dojo.byId('dynamicZoom').style.left) / parseInt(dojo.byId('dijit_layout_ContentPane_1').style.width) * (gv.maxVisible()-gv.minVisible()));
        if(end < start) {
            var temp = end;
            end = start;
            start = temp;
        }
        if(start != end) brwsr.navigateTo(start+".."+end);
    });
};

/*
 * creates the rubber band zoom over the overview tracks at the top of the page
 */
Browser.prototype.createHighLevelRubberBandZoom = function(refseq) {
    brwsr = this;
    var overview = dojo.byId('overview');
    var height = parseInt(overview.style.height) + 10; //brwsr.view.overviewBox.h;

    // creates the line representing the end of the zoom that doesn't move
    var dynamicZoomHighStart = document.createElement("div");
    dynamicZoomHighStart.id = 'dynamicZoomHighStart';
    dynamicZoomHighStart.style.cssText = "top: 0px; height: "+height+"px";
    dynamicZoomHighStart.className = "dynamicZoomLine";
    dynamicZoomHighStart.style.display = "none";
    overview.appendChild(dynamicZoomHighStart);

    // creates the line representing the end of the zoom that moves
    this.dynamicZoomHigh = document.createElement("div");
    this.dynamicZoomHigh.id = 'dynamicZoomHigh';
    this.dynamicZoomHigh.style.cssText = "top: 0px; height: "+height+"px";
    this.dynamicZoomHigh.className = "dynamicZoomLine";
    this.dynamicZoomHigh.style.display = "none";
    overview.appendChild(this.dynamicZoomHigh);
    this.zoomMoverHigh = new dojo.dnd.move.parentConstrainedMoveable(this.dynamicZoomHigh, {area: "margin", within: true});
    brwsr.zoomMoverHigh = this.zoomMoverHigh;

    // creates the transparent red box that covers the area the will be zoomed to
    var selectedAreaHigh = document.createElement("div");
    selectedAreaHigh.id = 'selectedAreaHigh';
    selectedAreaHigh.style.cssText = "top: 0px; height: "+height+"px";
    selectedAreaHigh.className = "dynamicZoomArea";
    overview.appendChild(selectedAreaHigh);

    // start the zoom and make the zoom elements visible
    dojo.connect(overview, "mousedown", function(event) {
        var startingPt = event.clientX -parseInt(dojo.byId('dijit_layout_ContentPane_0').style.left);
        var locationThumb = dojo.byId('overview').firstChild;
        if(startingPt > parseInt(locationThumb.style.left) 
            && startingPt < (parseInt(locationThumb.style.left) + parseInt(locationThumb.style.width))) 
                return;
        dojo.byId('dynamicZoomHighStart').style.display = "block";
        dojo.byId('dynamicZoomHigh').style.display = "block";
        dojo.byId('selectedAreaHigh').style.display = "block";
        dojo.byId('dynamicZoomHigh').style.left = startingPt + "px";
        dojo.byId('dynamicZoomHighStart').style.left = startingPt + "px";
        brwsr.zoomMoverHigh.onMoveStart( new dojo.dnd.Mover(brwsr.zoomMoverHigh.node, event, brwsr.zoomMoverHigh));
    });

    // expand the area selected when the end of the zoom is moved
    dojo.connect(this.zoomMoverHigh, "onMove", function(mover, leftTop) { 
        var leftSide = parseInt(dojo.byId('dynamicZoomHighStart').style.left);
        var rightSide = leftTop.l;
        if(rightSide < leftSide) {
            var temp = rightSide;
            rightSide = leftSide;
            leftSide = temp;
        }
        dojo.byId('selectedAreaHigh').style.width = rightSide - leftSide + "px";
        dojo.byId('selectedAreaHigh').style.left = leftSide + "px";
    });

    // zoom to the selected area when mouse released
    dojo.connect(this.zoomMoverHigh, "onMoveStop", function() {
        var start = Math.round(parseInt(dojo.byId('dynamicZoomHighStart').style.left) / parseInt(dojo.byId('dijit_layout_ContentPane_0').style.width) * refseq.length);
        var end = Math.round(parseInt(dojo.byId('dynamicZoomHigh').style.left) / parseInt(dojo.byId('dijit_layout_ContentPane_0').style.width) * refseq.length);
        dojo.byId('dynamicZoomHighStart').style.display = "none";
        dojo.byId('dynamicZoomHigh').style.display = "none";
        dojo.byId('selectedAreaHigh').style.display = "none";
        dojo.byId('selectedAreaHigh').style.width = "0px";
        if(end < start) {
            var temp = end;
            end = start;
            start = temp;
        }
        if(start != end) brwsr.navigateTo(start+".."+end);
    });

};


/**
 * @private
 */
Browser.prototype.onFineMove = function(startbp, endbp) {

    if(endbp > this.view.ref.end) {
        // stops the location trap from going off the end of the page
        endbp = this.view.ref.end;
    }

    var length = this.view.ref.end - this.view.ref.start;
    var trapLeft = Math.round((((startbp - this.view.ref.start) / length)
                               * this.view.overviewBox.w) + this.view.overviewBox.l);
    var trapRight = Math.round((((endbp - this.view.ref.start) / length)
                                * this.view.overviewBox.w) + this.view.overviewBox.l);
    var locationTrapStyle;
    if (dojo.isIE) {
        //IE apparently doesn't like borders thicker than 1024px
        locationTrapStyle =
            "top: " + this.view.overviewBox.t + "px;"
            + "height: " + this.view.overviewBox.h + "px;"
            + "left: " + trapLeft + "px;"
            + "width: " + (trapRight - trapLeft) + "px;"
            + "border-width: 0px";
    } else {
        locationTrapStyle =
            "top: " + (this.view.overviewBox.t)+ "px;"
            + "height: " + this.view.overviewBox.h + "px;"
            + "left: " + this.view.overviewBox.l + "px;"
            + "width: " + (trapRight - trapLeft) + "px;"
            + "border-width: " + "0px "
            + (this.view.overviewBox.w - trapRight) + "px "
            + this.view.locationTrapHeight + "px " + trapLeft + "px;";
    }

    this.locationTrap.style.cssText = locationTrapStyle;
};

Browser.prototype.fillCustomizeTrackTab = function(track, trackClass) {
    var customTrack = this.customTrack;
    customTrack.innerHTML = "";

    if(track) {
        this.openCustomizeTrackTab(false);
        var tabHeader = document.createElement("div");
        tabHeader.innerHTML = "Customizing "+track+" track";
        tabHeader.style.cssText = "margin: 10px;";
        customTrack.appendChild(tabHeader);

        var previewTrack = document.createElement("div");
        var plus = "";
        if(trackClass) {
            previewTrack.className = trackClass;
            previewTrack.style.cssText = "margin-top: 10px; "+
                                         "margin-bottom: 10px; "+
                                         "position: relative; "+
                                         "left: 10%; "+
                                         "width: 80%;";
            plus = (trackClass.substring(0,5) == "plus-");
        }
        else {
            previewTrack.style.cssText = "margin-top: 10px; "+
                                         "margin-bottom: 10px; "+
                                         "height: 8px; "+
                                         "position: relative; "+
                                         "left: 10%; "+
                                         "width: 80%; "+
                                         "border: 1px solid black;";
        }
        customTrack.appendChild(previewTrack);

        var applyChangesBtn = new dijit.form.Button({ label: "apply changes"});
        customTrack.appendChild(applyChangesBtn.domNode);
        applyChangesBtn.domNode.style.cssText = "margin: 10px;";

        if(track_customization_hidden) {
            var cancelBtn = new dijit.form.Button({ label: "cancel"});
            customTrack.appendChild(cancelBtn.domNode);
            cancelBtn.domNode.style.cssText = "display: inline-block; margin: 10px 2px;";
            dojo.connect(cancelBtn, "onClick", function() {
                window.brwsr.fillCustomizeTrackTab();
            });
        }

        // retrieving css values to fill the drop downs with

        // get the possible class names for css already in use
        var trackName = String(track);
        trackName = trackName.replace(/ /g, "-");
        var oldHeight;
        var oldBackgroundColor;
        var oldBackgroundImage;
        var oldBorderColor;
        var oldBorderWidth;
        var plusMinusClassText;
        var minusPlusClassText;
        var trackClassName;
        var plus = (trackClass.substring(0,5) == "plus-");
        if(plus) {
            plusMinusClassText = "."+trackClass+", .minus-"+trackClass.substring(5);
            minusPlusClassText = ".minus-"+trackClass.substring(5)+", ."+trackClass;
            trackClassName = trackClass.substring(5);
        }
        else {
            plusMinusClassText = ".plus-"+trackClass.substring(6)+", ."+trackClass;
            minusPlusClassText = "."+trackClass+", .plus-"+trackClass.substring(6);
            trackClassName = trackClass.substring(6);
        }

        // get the prevous css values from the style sheet

        if(!document.styleSheets[2]['cssRules']) document.styleSheets[2]['cssRules'] = document.styleSheets[2]['rules'];
        for( var i = 0; i < document.styleSheets[2]['cssRules'].length; i++) {

            // getting css info about the track in IE
            if(((document.styleSheets[2]['cssRules'][i].selectorText == ".minus-"+trackClassName) 
                    || (document.styleSheets[2]['cssRules'][i].selectorText == ".plus-"+trackClassName)) 
                    && (document.styleSheets[2]['cssRules'][i].style.height)){
                oldHeight = document.styleSheets[2]['cssRules'][i].style.height;
                if(document.styleSheets[2]['cssRules'][i].style.border) {
                    oldBorderWidth = document.styleSheets[2]['cssRules'][i].style.borderWidth;
                    oldBorderColor = document.styleSheets[2]['cssRules'][i].style.borderColor;
                }
                if(document.styleSheets[2]['cssRules'][i].style.backgroundColor) {
                    oldBackgroundColor  = document.styleSheets[2]['cssRules'][i].style.backgroundColor;
                }
            }

            // getting the background Image info if there is on
            if((document.styleSheets[2]['cssRules'][i].selectorText == ".plus-"+trackClassName)) {
                oldBackgroundImage = document.styleSheets[2]['cssRules'][i].style.backgroundImage;
            }
            if((document.styleSheets[2]['cssRules'][i].selectorText == ".minus-"+trackClassName)) {
                oldBackgroundImage = document.styleSheets[2]['cssRules'][i].style.backgroundImage;
            }

            // getting css info for track in browsers not IE
            if((document.styleSheets[2]['cssRules'][i].selectorText == minusPlusClassText) 
              || (document.styleSheets[2]['cssRules'][i].selectorText == plusMinusClassText)) {
                oldHeight = document.styleSheets[2]['cssRules'][i].style.height;
                if(document.styleSheets[2]['cssRules'][i].style.border) {
                    oldBorderWidth = document.styleSheets[2]['cssRules'][i].style.borderWidth;
                    oldBorderColor = document.styleSheets[2]['cssRules'][i].style.borderColor;
                }
                oldBackgroundColor = document.styleSheets[2]['cssRules'][i].style.backgroundColor;
            }
        }

        if(oldBackgroundImage) {
            if(oldBackgroundImage.substring(4,5) == '"') {
                oldBackgroundImage = oldBackgroundImage.substring(5, oldBackgroundImage.length - 2);
            }
            else {
                oldBackgroundImage = oldBackgroundImage.substring(4, oldBackgroundImage.length - 1);
            }
        }

        // height drop down
        var changeHeight = document.createElement("div");
        changeHeight.style.cssText = "margin: 10px;";
        changeHeight.innerHTML = "height: ";
        customTrack.appendChild(changeHeight);
        var heightSelect = document.createElement("select");
        changeHeight.appendChild(heightSelect);
        var defaultHeightOption = document.createElement("option");
        defaultHeightOption.value = "";
        defaultHeightOption.innerHTML = oldHeight + " (default)";
        if(!oldHeight) defaultHeightOption.innerHTML = "select height";
        heightSelect.appendChild(defaultHeightOption);
        for(var i = 1; i <= 40; i++) {
            var heightOption = document.createElement("option");
            heightOption.value = i+"px";
            heightOption.innerHTML = i+"px";
            heightSelect.appendChild(heightOption);
        }   
        dojo.connect(heightSelect, "onchange", function(event) {
            previewTrack.style.height = heightSelect.options[heightSelect.selectedIndex].value;
        });

        // rectangle fill color drop down
        var changeFillColor = document.createElement("div");
        changeFillColor.style.cssText = "margin: 10px;";
        changeFillColor.innerHTML = "rectangle fill color: ";
        customTrack.appendChild(changeFillColor);
        var colorSelect = document.createElement("select");
        changeFillColor.appendChild(colorSelect);
        var defaultColorOption = document.createElement("option");
        defaultColorOption.value = "";
        defaultColorOption.innerHTML = oldBackgroundColor + " (default)";
        if(!oldBackgroundColor) defaultColorOption.innerHTML = "none (default)";
        if(!oldBackgroundColor && oldBackgroundImage) defaultColorOption.innerHTML = "(not being used)";
        colorSelect.appendChild(defaultColorOption);
        var colorOptions = ["aliceblue","antiquewhite","aqua","aquamarine","azure","beige","bisque","black","blanchedalmond","blue","blueviolet","brown","burlywood","cadetblue","chartreuse","chocolate","coral","cornflowerblue","cornsilk","crimson","cyan","darkblue","darkcyan","darkgoldenrod","darkgray","darkgreen","darkgrey","darkkhaki","darkmagenta","darkolivegreen","darkorange","darkorchid","darkred","darksalmon","darkseagreen","darkslateblue","darkslategray","darkslategrey","darkturquoise","darkviolet","deeppink","deepskyblue","dimgray","dimgrey","dodgerblue","firebrick","floralwhite","forestgreen","fuchsia","gainsboro","ghostwhite","gold","goldenrod","gray","green","greenyellow","grey","honeydew","hotpink","indianred","indigo","ivory","khaki","lavender","lavenderblush","lawngreen","lemonchiffon","lightblue","lightcoral","lightcyan","lightgoldenrodyellow","lightgray","lightgreen","lightgrey","lightpink","lightsalmon","lightseagreen","lightskyblue","lightslategray","lightslategrey","lightsteelblue","lightyellow","lime","limegreen","linen","magenta","maroon","mediumaquamarine","mediumblue","mediumorchid","mediumpurple","mediumseagreen","mediumslateblue","mediumspringgreen","mediumturquoise","mediumvioletred","midnightblue","mintcream","mistyrose","moccasin","navajowhite","navy","oldlace","olive","olivedrab","orange","orangered","orchid","palegoldenrod","palegreen","paleturquoise","palevioletred","papayawhip","peachpuff","peru","pink","plum","powderblue","purple","red","rosybrown","royalblue","saddlebrown","salmon","sandybrown","seagreen","seashell","sienna","silver","skyblue","slateblue","slategray","slategrey","snow","springgreen","steelblue","tan","teal","thistle","tomato","turquoise","violet","wheat","white","whitesmoke","yellow","yellowgreen"];
        for(var i = 0; i < colorOptions.length; i++) {
            var colorOption = document.createElement("option");
            colorOption.value = colorOptions[i];
            colorOption.innerHTML = colorOptions[i];
            colorOption.style.cssText = "background: "+colorOptions[i]+";";
            colorSelect.appendChild(colorOption);
        }
        dojo.connect(colorSelect, "onchange", function(event) {
            //colorSelect.style.cssText = "background: "+colorSelect.options[colorSelect.selectedIndex].value+";";
            previewTrack.style.background = colorSelect.options[colorSelect.selectedIndex].value;
            imageSelect.selectedIndex = 0;
            imageSelect.options[0].innerHTML = "(not being used)";
            colorSelect.options[0].innerHTML = oldBackgroundColor + " (default)";
        });

        // track image drop down
        var changeTrackImage = document.createElement("div");
        changeTrackImage.style.cssText = "margin: 10px;";
        changeTrackImage.innerHTML = "OR <br/><br/>track image: ";
        customTrack.appendChild(changeTrackImage);
        var imageSelect = document.createElement("select");
        changeTrackImage.appendChild(imageSelect);
        var defaultImageOption = document.createElement("option");
        defaultImageOption.value = "";
        defaultImageOption.innerHTML = oldBackgroundImage + " (default)";
        if(!oldBackgroundImage) defaultImageOption.innerHTML = "none (default)";
        if(!oldBackgroundImage && oldBackgroundColor) defaultImageOption.innerHTML = "(not being used)";
        imageSelect.appendChild(defaultImageOption);
        if(trackClass) {
            var directionalImageOptions = ["chevron","chevron3","herringbone13","herringbone14","chevron2","herringbone10","herringbone16","herringbone11","herringbone12","pacman","cds0","cds1","cds2"];
            var direct = plus ? "plus-": "minus-";
            for(var i = 0; i < directionalImageOptions.length; i++) {
                var imageOption = document.createElement("option");
                imageOption.value = 'url("img/'+direct+directionalImageOptions[i]+'.png")';
                //imageOption.style.cssText = "background-image: url(\"img/"+direct+directionalImageOptions[i]+".png\"); background-repeat: repeat-x;";
                imageOption.innerHTML = directionalImageOptions[i];
                imageSelect.appendChild(imageOption);
            }
        }
        var imageOptions = ["dblhelix-red","helix3-green","helix-green","path11828","path2160","path3415","loops","utr"];
        for(var i = 0; i < imageOptions.length; i++) {
            var imageOption = document.createElement("option");
            imageOption.value = 'url("img/'+imageOptions[i]+'.png")';
            var imageDiv = document.createElement("div");
            imageDiv.style.cssText = "display: inline-block; width: 10px; background-image: url(\"img/"+imageOptions[i]+".png\"); background-repeat: repeat-x";
            imageOption.innerHTML = imageOptions[i];
            imageOption.appendChild(imageDiv);
            imageSelect.appendChild(imageOption);
        } 
        dojo.connect(imageSelect, "onchange", function(event) {
            previewTrack.style.background = imageSelect.options[imageSelect.selectedIndex].value;
            previewTrack.style.backgroundRepeat = "repeat-x";
            colorSelect.selectedIndex = 0;
            colorSelect.options[0].innerHTML = "(not being used)";
            imageSelect.options[0].innerHTML = oldBackgroundImage + " (default)";
        });

        // border color drop down
        var changeBorderColor = document.createElement("div");
        changeBorderColor.style.cssText = "margin: 10px;";
        changeBorderColor.innerHTML = "border color: ";
        customTrack.appendChild(changeBorderColor);
        var colorBorderSelect = document.createElement("select");
        changeBorderColor.appendChild(colorBorderSelect);
        var defaultColorBorderOption = document.createElement("option");
        defaultColorBorderOption.value = ""; 
        defaultColorBorderOption.innerHTML = oldBorderColor + " (default)";
        if(!oldBorderColor) defaultColorBorderOption.innerHTML = "none (default)";
        colorBorderSelect.appendChild(defaultColorBorderOption);
        var colorBorderOptions = ["aliceblue","antiquewhite","aqua","aquamarine","azure","beige","bisque","black","blanchedalmond","blue","blueviolet","brown","burlywood","cadetblue","chartreuse","chocolate","coral","cornflowerblue","cornsilk","crimson","cyan","darkblue","darkcyan","darkgoldenrod","darkgray","darkgreen","darkgrey","darkkhaki","darkmagenta","darkolivegreen","darkorange","darkorchid","darkred","darksalmon","darkseagreen","darkslateblue","darkslategray","darkslategrey","darkturquoise","darkviolet","deeppink","deepskyblue","dimgray","dimgrey","dodgerblue","firebrick","floralwhite","forestgreen","fuchsia","gainsboro","ghostwhite","gold","goldenrod","gray","green","greenyellow","grey","honeydew","hotpink","indianred","indigo","ivory","khaki","lavender","lavenderblush","lawngreen","lemonchiffon","lightblue","lightcoral","lightcyan","lightgoldenrodyellow","lightgray","lightgreen","lightgrey","lightpink","lightsalmon","lightseagreen","lightskyblue","lightslategray","lightslategrey","lightsteelblue","lightyellow","lime","limegreen","linen","magenta","maroon","mediumaquamarine","mediumblue","mediumorchid","mediumpurple","mediumseagreen","mediumslateblue","mediumspringgreen","mediumturquoise","mediumvioletred","midnightblue","mintcream","mistyrose","moccasin","navajowhite","navy","oldlace","olive","olivedrab","orange","orangered","orchid","palegoldenrod","palegreen","paleturquoise","palevioletred","papayawhip","peachpuff","peru","pink","plum","powderblue","purple","red","rosybrown","royalblue","saddlebrown","salmon","sandybrown","seagreen","seashell","sienna","silver","skyblue","slateblue","slategray","slategrey","snow","springgreen","steelblue","tan","teal","thistle","tomato","turquoise","violet","wheat","white","whitesmoke","yellow","yellowgreen"];
        for(var i = 0; i < colorBorderOptions.length; i++) {
            var colorBorderOption = document.createElement("option");
            colorBorderOption.value = colorBorderOptions[i];
            colorBorderOption.innerHTML = colorBorderOptions[i];
            colorBorderOption.style.cssText = "background: "+colorBorderOptions[i]+";";
            colorBorderSelect.appendChild(colorBorderOption);
        }
        dojo.connect(colorBorderSelect, "onchange", function(event) {
            var weight = previewTrack.style.borderWidth;
            if(!weight) weight = "0px";
            previewTrack.style.border = weight+" solid "+ colorBorderSelect.options[colorBorderSelect.selectedIndex].value;
            previewTrack.style.borderWidth  = weight;
        });

        // border width drop down
        var changeBorderWidth = document.createElement("div");
        changeBorderWidth.style.cssText = "margin: 10px;";
        changeBorderWidth.innerHTML = "border width: ";
        customTrack.appendChild(changeBorderWidth);
        var borderWidthSelect = document.createElement("select");
        changeBorderWidth.appendChild(borderWidthSelect);
        var defaultBorderWidthOption = document.createElement("option");
        defaultBorderWidthOption.value = "";
        defaultBorderWidthOption.innerHTML = oldBorderWidth + " (default)";
        if(!oldBorderWidth) defaultBorderWidthOption.innerHTML = "none (default)";
        borderWidthSelect.appendChild(defaultBorderWidthOption);
        for(var i = 0; i <= 6; i++) {
            var borderWidthOption = document.createElement("option");
            borderWidthOption.value = i+"px";
            borderWidthOption.innerHTML = i+"px";
            borderWidthSelect.appendChild(borderWidthOption);
        }
        dojo.connect(borderWidthSelect, "onchange", function(event) {
            var color = previewTrack.style.borderColor;
            if(!color) color = "transparent";
            previewTrack.style.border = borderWidthSelect.options[borderWidthSelect.selectedIndex].value+" solid "+ color;
        });

        // setting track to the new css 

        dojo.connect(applyChangesBtn, "onClick", function() {
                var newCssText = "position: absolute; cursor: pointer; min-width: 1px; z-index: 10;";
                var background;
                var height;
                var border;
                var newCssTextMinus;
                var newCssTextPlus;

                // get the new css values from the preview
                if(previewTrack.style.height) {
                    height = "height: "+previewTrack.style.height+";";
                }
                if(previewTrack.style.backgroundImage && previewTrack.style.backgroundImage != 'none' && previewTrack.style.backgroundImage != "initial") {
                    var backImage = previewTrack.style.backgroundImage;
                    var patternPlus = new RegExp('plus-[^\\.]*\\..*$');
                    var patternMinus = new RegExp('minus-[^\\.]*\\..*$');
                    if(patternPlus.test(backImage)) {
                        var patternBegin = new RegExp('^.*plus');
                        var endUrl = String(patternPlus.exec(backImage)).substring(5);
                        var startUrl = String(patternBegin.exec(backImage));
                        startUrl = startUrl.substring(0, startUrl.length - 4);
                        newCssTextMinus = "background: "+ startUrl +"minus-"+endUrl+" repeat-x scroll 0 0 transparent;";
                        newCssTextPlus = "background: "+ startUrl +"plus-"+endUrl+" repeat-x scroll 0 0 transparent;";
                    }
                    else if(patternMinus.test(backImage)) {
                        var patternBegin = new RegExp('^.*minus');
                        var endUrl = String(patternMinus.exec(backImage)).substring(6);
                        var startUrl = String(patternBegin.exec(backImage));
                        startUrl = startUrl.substring(0, startUrl.length - 5);
                        newCssTextMinus = "background: "+ startUrl +"minus-"+endUrl+" repeat-x scroll 0 0 transparent;";
                        newCssTextPlus = "background: "+ startUrl +"plus-"+endUrl+" repeat-x scroll 0 0 transparent;";
                    }
                    else {
                        background = "background: "+backImage+" repeat-x scroll 0 0 transparent;";
                    }
                }
                else if(previewTrack.style.background) {
                    background = "background: "+previewTrack.style.background+";";
                }
                if(previewTrack.style.border) {
                    border = "border: "+previewTrack.style.border+";";
                }

                // get the possible class names for css already in use
                var trackName = String(track);
                trackName = trackName.replace(/ /g, "-");
                trackName = trackName.replace(/'/g, "");
                trackName = trackName.replace(/\./g, "");
                var cssText = "";
                var cssTextMinus = "";
                var cssTextPlus = "";
                var plusMinusClassText;
                var minusPlusClassText;
                var trackClassName;
                var plus = (trackClass.substring(0,5) == "plus-");
                if(plus) {
                    plusMinusClassText = "."+trackClass+", .minus-"+trackClass.substring(5);
                    minusPlusClassText = ".minus-"+trackClass.substring(5)+", ."+trackClass;
                    trackClassName = trackClass.substring(5);
                }
                else {
                    plusMinusClassText = ".plus-"+trackClass.substring(6)+", ."+trackClass;
                    minusPlusClassText = "."+trackClass+", .plus-"+trackClass.substring(6);
                    trackClassName = trackClass.substring(6);
                }
                var num = window.brwsr.trackClass[track]? (parseInt(window.brwsr.trackClass[track])+1): 0;

                // get the prevous css values from the style sheet

                if(!document.styleSheets[2]['cssRules']) document.styleSheets[2]['cssRules'] = document.styleSheets[2]['rules'];
                for( var i = 0; i < document.styleSheets[2]['cssRules'].length; i++) {

                    // getting css info about the track in IE
                    if(((document.styleSheets[2]['cssRules'][i].selectorText == ".minus-"+trackClassName) 
                            || (document.styleSheets[2]['cssRules'][i].selectorText == ".plus-"+trackClassName)) 
                            && (document.styleSheets[2]['cssRules'][i].style.height)){
                        if(!height) height = "height: "+ document.styleSheets[2]['cssRules'][i].style.height+";";
                        if(document.styleSheets[2]['cssRules'][i].style.border && !border) border = "border: "+ document.styleSheets[2]['cssRules'][i].style.border+";";
                        if(document.styleSheets[2]['cssRules'][i].style.backgroundColor && (!background) && (!newCssTextPlus)) {
                            cssText = "background: "+ document.styleSheets[2]['cssRules'][i].style.background+";";
                            if(!document.styleSheets[2]['cssRules'][i].style.background) cssText = "background: "+ document.styleSheets[2]['cssRules'][i].style.backgroundColor+";";
                        }
                    }

                    // getting the background Image info if there is on
                    if((!newCssTextPlus) && (!background) && (document.styleSheets[2]['cssRules'][i].selectorText == ".plus-"+trackClassName)) {
                        if (document.styleSheets[2]['cssRules'][i].style.backgroundImage && (document.styleSheets[2]['cssRules'][i].style.backgroundImage != 'none')) {
                            newCssTextPlus = "background: "+document.styleSheets[2]['cssRules'][i].style.backgroundImage+" repeat-x scroll 0 0 transparent;";
                        }
                    }
                    if(!newCssTextMinus && !background && (document.styleSheets[2]['cssRules'][i].selectorText == ".minus-"+trackClassName)) {
                        if (document.styleSheets[2]['cssRules'][i].style.backgroundImage && (document.styleSheets[2]['cssRules'][i].style.backgroundImage != 'none')) {
                            newCssTextMinus = "background: "+document.styleSheets[2]['cssRules'][i].style.backgroundImage+" repeat-x scroll 0 0 transparent;";
                        }
                    }

                    // getting css info for track in browsers not IE
                    if(document.styleSheets[2]['cssRules'][i].selectorText == minusPlusClassText) {
                        if(!height) height = "height: "+ document.styleSheets[2]['cssRules'][i].style.height+";";
                        if(!border) border = "border: "+ document.styleSheets[2]['cssRules'][i].style.border+";";
                        if((!background) && (!newCssTextPlus)) {
                            cssText = "background: "+ document.styleSheets[2]['cssRules'][i].style.background+";";
                            if(!document.styleSheets[2]['cssRules'][i].style.background) cssText = "background: "+ document.styleSheets[2]['cssRules'][i].style.backgroundColor+";";
                        }
                    }
                    if(document.styleSheets[2]['cssRules'][i].selectorText == plusMinusClassText) {
                        if(!height) height = "height: "+ document.styleSheets[2]['cssRules'][i].style.height+";";
                        if(!border) border = "border: "+ document.styleSheets[2]['cssRules'][i].style.border+";";
                        if((!background) && (!newCssTextPlus)) {
                            cssText = "background: "+ document.styleSheets[2]['cssRules'][i].style.background+";";
                            if(!document.styleSheets[2]['cssRules'][i].style.background) cssText = "background: "+ document.styleSheets[2]['cssRules'][i].style.backgroundColor+";";
                        }
                    }
                }

                //Update the track look by adding new css rules

                var prefix = plus? ".plus-": ".minus-";
                if(newCssTextPlus) {
                    if (document.styleSheets[2].insertRule) {
                        document.styleSheets[2].insertRule(".plus-"+num+trackName+' { '+newCssTextPlus+'}', document.styleSheets[2]['cssRules'].length);
                        document.styleSheets[2].insertRule(".minus-"+num+trackName+' { '+newCssTextMinus+'}', document.styleSheets[2]['cssRules'].length);
                    }
                    if (document.styleSheets[2].addRule) {
                        //Adding the CSS Rules in IE
                        document.styleSheets[2].addRule(".plus-"+num+trackName, newCssTextPlus);
                        document.styleSheets[2].addRule(".minus-"+num+trackName, newCssTextMinus);
                    }
                }
                else if(!background) {
                    background = cssText;
                }

                if (document.styleSheets[2].insertRule)  document.styleSheets[2].insertRule('.plus-'+num+trackName+', .minus-'+num+trackName+' { '+newCssText+' '+height+' '+border+' '+background+'}', document.styleSheets[2]['cssRules'].length);

                // Adding the rule in IE
                if(!border) border = '';
                if(!background) background = '';
                if (document.styleSheets[2].addRule)  document.styleSheets[2].addRule('.plus-'+num+trackName+', .minus-'+num+trackName, newCssText+height+border+background);

                // reload the track to update the css
                window.brwsr.trackClass[track] = num+trackName;
                var insertAfterNode = dojo.byId("track_"+track).previousSibling;
                dijit.getEnclosingWidget(dojo.byId("label_"+track).firstChild).onClick();
                window.brwsr.displayTrack(track, false, insertAfterNode);
        });
        this.trackCurrentlyCustomized = track;
    }
    else {
        this.openCustomizeTrackTab(true);
        var message = document.createElement("div");
        message.style.cssText = "margin: 10px; text-align: center; width: 80%;";
        message.innerHTML = 'Select a track to customize by right clicking on its image and selecting "Customize Track".';
        customTrack.appendChild(message);
    }
}


/**
 * @private
 */
Browser.prototype.createTrackList = function(parent, params) {
    dojo.require("dojo.data.ItemFileWriteStore");
    dojo.require("dijit.tree.ForestStoreModel");
    dojo.require("dijit.tree.dndSource");
    dojo.require("dojo.cache");
    dojo.require("dijit.Tree");
    dojo.require("dijit.form.TextBox");
    dojo.require("dijit.form.Button");

    // tab section creation

    var parentLeftPane = document.createElement("div");
    parentLeftPane.style.cssText="width: 22px; height: 100%; overflow: visible;";
    parent.appendChild(parentLeftPane);

    var leftWidget = new dijit.layout.ContentPane({region: "left", splitter: true}, parentLeftPane);

    // the container for the main panel of the tabs
    var tabCon = document.createElement("div");
    tabCon.id = "browseTab";
    tabCon.style.cssText = "height: 100%; padding-left: 22px;";

    // the main panel for the track dragging tab
    var leftPane = document.createElement("div");
    leftPane.style.cssText = "display: none; overflow: auto; height: 100%;";
    leftPane.id = "DragTracks";

    // the element to mark the position of the tab   
    var leftPaneTabPos = document.createElement("div");
    leftPaneTabPos.id = "leftPaneTab";
    leftPaneTabPos.className = "tabContainer";
    leftPaneTabPos.style.left = "0%";
    leftPaneTabPos.style.top = "2px";
    parentLeftPane.appendChild(leftPaneTabPos);

    // the track drag tab, first one down
    var leftPaneTab = document.createElement("div");
    leftPaneTab.className = "browsingTab";
    leftPaneTab.innerHTML = "Select Tracks";
    leftPaneTabPos.appendChild(leftPaneTab);

    var faceted;
    var facetedIframe;
    var facetedTabPos;
    var facetedTab;
    if(faceted_on) {
        // the main panel for the faceted browsing tab
        faceted = document.createElement("div");
        faceted.style.cssText = "display:none; height: 100%;";
        faceted.id = "FacetedBrowsing";

        // faceted browisng page runs from an iframe
        facetedIframe = document.createElement("iframe");
        facetedIframe.src = "faceted_browsing.html"; 
        facetedIframe.setAttribute("name","browsing_window");
        facetedIframe.setAttribute("frameborder","0");
        facetedIframe.height = "100%";
        facetedIframe.width = "100%";
        faceted.appendChild(facetedIframe); 
    
        // the element to mark the position of the tab   
        facetedTabPos = document.createElement("div");
        facetedTabPos.id = "facetedTab";
        facetedTabPos.className = "tabContainer";
        facetedTabPos.style.left = "0%";
        facetedTabPos.style.top = "138px";
        parentLeftPane.appendChild(facetedTabPos);
        if(!faceted_on) facetedTabPos.style.display = "none";

        // the faceted browsing tab, second one down
        facetedTab = document.createElement("div");
        facetedTab.className = "browsingTab";
        facetedTab.innerHTML = "Find Tracks";
        facetedTabPos.appendChild(facetedTab);
    }

    var customTrack = document.createElement("div");
    var message = document.createElement("div");
    if(track_customization_on) {
        // the main panel for the custom Tracks tab
        customTrack.style.cssText = "display: none; overflow: auto; height: 100%;";
        customTrack.id = "CustomizeTrack";
        message.style.cssText = "margin: 10px; text-align: center; width: 80%;";
        message.innerHTML = 'Select a track to customize by right clicking on its image and selecting "Customize Track".';
        customTrack.appendChild(message);
    }
    this.customTrack = customTrack;

    var customTrackTabPos;
    var customTrackTab;
    if(!track_customization_hidden) {
        // the element to mark the position of the tab   
        customTrackTabPos = document.createElement("div");
        customTrackTabPos.id = "customTrackTab";
        customTrackTabPos.className = "tabContainer";
        customTrackTabPos.style.left = "0%";
        customTrackTabPos.style.top = "274px";
        if(!faceted_on) customTrackTabPos.style.top = "138px";
        parentLeftPane.appendChild(customTrackTabPos);
        if(track_customization_hidden) customTrackTabPos.style.display = "none";

        // the cutsomize track tab, first one down
        customTrackTab = document.createElement("div");
        customTrackTab.className = "browsingTab";
        customTrackTab.innerHTML = "Customize Track";
        customTrackTabPos.appendChild(customTrackTab);
    }

    // line representing the folder edge of the hidden tab
    var line = document.createElement("div");
    line.style.cssText = "background: #BBBBBB; width: 3px; top: 2px; height: 100%; position: absolute;";
    parentLeftPane.appendChild(line);

    parentLeftPane.appendChild(tabCon);
    tabCon.appendChild(leftPane);
    if(faceted_on) tabCon.appendChild(faceted);
    tabCon.appendChild(customTrack);

    // both tabs start out closed
    var open1 = false;
    var open2 = false;
    var open3 = false;

    // open/ close the tabs on click
    dojo.connect(leftPaneTab, "onclick", function() {
        resizeTab(0);
        if(faceted_on) faceted.style.display = "none";
        if(track_customization_on) customTrack.style.display = "none";
        if(open1) {
            leftPaneTabPos.style.left = "0%";
            leftPane.style.display = "none";
            open1 = false;
        }
        else {
            if(faceted_on) facetedTabPos.style.left = "0%";
            if(!track_customization_hidden) customTrackTabPos.style.left = "0%";
            leftPaneTabPos.style.left = "100%";
            resizeTab(240);
            leftPane.style.display = "";
            open1 = true;
            open2 = false;
            open3 = false;
        }
        dojo.byId("dijit_layout_ContentPane_1").style.top = dojo.marginBox(dojo.byId("navbox")).h + parseInt(dojo.byId("overview").style.height) + 10 + "px";
    }); 
    if(faceted_on) {
        dojo.connect(facetedTab, "onclick", function() {
            resizeTab(0); 
            leftPane.style.display = "none";
            if(track_customization_on) customTrack.style.display = "none";
            if(open2) {
                facetedTabPos.style.left = "0%";
                faceted.style.display = "none";
                open2 = false;
            }
            else {
                if(window.frames["browsing_window"].start_faceted_browsing) window.frames["browsing_window"].start_faceted_browsing(dojo.cookie(brwsr.container.id + "-tracks"));
                leftPaneTabPos.style.left = "0%";
                if(!track_customization_hidden) customTrackTabPos.style.left = "0%";
                facetedTabPos.style.left = "100%";
                resizeTab(530);
                faceted.style.display = "";
                open2 = true;
                open1 = false;
                open3 = false;
            }
            dojo.byId("dijit_layout_ContentPane_1").style.top = dojo.marginBox(dojo.byId("navbox")).h + parseInt(dojo.byId("overview").style.height) + 10 + "px";
        }); 
    }

    var openCustomizeTrackTab = function(tabOpen) {
        resizeTab(0);
        if(faceted_on) faceted.style.display = "none";
        leftPane.style.display = "none";
        if(tabOpen) {
            if(!track_customization_hidden) customTrackTabPos.style.left = "0%";
            customTrack.style.display = "none";
            open3 = false;
        }
        else {
            if(faceted_on) facetedTabPos.style.left = "0%";
            leftPaneTabPos.style.left = "0%";
            if(!track_customization_hidden) customTrackTabPos.style.left = "100%";
            resizeTab(300);
            customTrack.style.display = "";
            open1 = false;
            open2 = false;
            open3 = true;
        }
        dojo.byId("dijit_layout_ContentPane_1").style.top = dojo.marginBox(dojo.byId("navbox")).h + parseInt(dojo.byId("overview").style.height) + 10 + "px";
    };
    if(!track_customization_hidden) dojo.connect(customTrackTab, "onclick", function() { openCustomizeTrackTab(open3); });
    this.openCustomizeTrackTab = openCustomizeTrackTab;

    // resize the elements of the page when a tab is opened/closed
    // newSize is the size of the tab
    var resizeTab = function(newSize) {
        dojo.byId("dijit_layout_ContentPane_2_splitter").style.cssText = "margin-right: 22px; background: #BBBBBB; width: 2px; "+dojo.byId("dijit_layout_ContentPane_2_splitter").style.cssText;
        dojo.byId("dijit_layout_ContentPane_2_splitter").style.display = "none";
        dojo.byId("dijit_layout_ContentPane_2").style.width = newSize + "px";
        dijit.getEnclosingWidget(dojo.byId("dijit_layout_ContentPane_2")).resize();
        if(!document.width) document.width = document.body.clientWidth;
        var rightSize = (document.width - newSize -5 - 22);
        var overLeft = (newSize + 5 + 22);
        dojo.animateProperty({
            node: dojo.byId("dijit_layout_ContentPane_2"),
            properties: { width:{ end: newSize, start: 20 }}
        }).play();
        dojo.animateProperty({
            node: dojo.byId("dijit_layout_ContentPane_2_splitter"),
            properties: { left: newSize}
        }).play();
        dojo.animateProperty({
            node: dojo.byId("dijit_layout_ContentPane_0"),
            properties: { left: overLeft,
                          width: rightSize}
        }).play();
        dojo.byId("dijit_layout_ContentPane_0").style.width = rightSize + "px";
        dijit.getEnclosingWidget(dojo.byId("dijit_layout_ContentPane_0")).resize();
        dojo.animateProperty({
            node: dojo.byId("dijit_layout_ContentPane_1"),
            properties: { left: overLeft,
                          width: rightSize}
        }).play();
        dojo.byId("dijit_layout_ContentPane_1").style.width = rightSize + "px";
        dijit.getEnclosingWidget(dojo.byId("dijit_layout_ContentPane_1")).resize();
        setTimeout('dojo.byId("dijit_layout_ContentPane_2_splitter").style.display = ""',500);
    }

    // set up the  Select Tracks tab

    var searchMessage = document.createElement("div");
    searchMessage.innerHTML = "Enter text to search track list:";
    searchMessage.style.cssText = "margin: 5px 0px;";
    leftPane.appendChild(searchMessage);

    var searchBox = document.createElement("input");
    searchBox.style.cssText = "margin: 5px 0px;";
    searchBox.id = "search";
    leftPane.appendChild(searchBox);

    var searchClearBtn = new dijit.form.Button({ label: "clear search"});
    searchClearBtn.domNode.style.cssText = 'margin: 5px 0px;';
    leftPane.appendChild(searchClearBtn.domNode);

    var treeResetBtn = new dijit.form.Button({ label: "reset list order"});
    treeResetBtn.domNode.style.cssText = "margin: 5px 0px;";

    var dragMessage = document.createElement("div");
    dragMessage.innerHTML =
        "<br/>Available Tracks:<br/>(Drag <img src=\""
        + (params.browserRoot ? params.browserRoot : "")
        + "img/right_arrow.png\"/> to view)<br/><br/>";
    leftPane.appendChild(dragMessage);
    leftPane.appendChild(treeResetBtn.domNode);

    var treeSection = document.createElement("div");
    treeSection.id = "treeList";
    treeSection.style.cssText =
        "width: 100%; height: 100%; overflow: visible;";

    leftPane.appendChild(treeSection);

    var brwsr = this;

    var changeCallback = function() {
        brwsr.view.showVisibleBlocks(true);
    };

    var trackListCreate = function(track, hint) {
        if(track != '[object Object]') {
            track = {'url' : String(store.getValue(track.item, 'url')),
                     'label' : track.label,
                     'key' : track.key,
                     'args_chunkSize': String(store.getValue(track.item, 'args_chunkSize')),
                     'type' : String(store.getValue(track.item, 'type'))};
        }
        var node = document.createElement("div");
        node.className = "tracklist-label";
        node.innerHTML = track.label;
        //in the list, wrap the list item in a container for
        //border drag-insertion-point monkeying
        if ("avatar" != hint) {
            var container = document.createElement("div");
            container.className = "tracklist-container";
            container.appendChild(node);
            node = container;
        }
        node.id = dojo.dnd.getUniqueId();
        return {node: node, data: track, type: ["track"]};
    };

    var DropFromOutside = function(source, nodes, copy) {
        function getChildrenRecursive(node){
            if(source.getItem(node.id).data.item.type[0] == 'TrackGroup') {
                var result = [];
                var i = 0;
                tree._expandNode(source.getItem(node.id).data);
                var children = source.getItem(node.id).data.getChildren();
                for(var n = 0; n < children.length; n++) {
                    var child = children[n];
                    var selectedNodes = source.getSelectedTreeNodes();
                    selectedNodes.push(child);
                    source.setSelection(selectedNodes);
                    if((child.domNode.style.display != "none")&&(child.item.type[0] != 'TrackGroup')
                        &&((!child.domNode.firstChild.childNodes[2].childNodes[1].style.color)
                            ||(child.domNode.firstChild.childNodes[2].childNodes[1].style.color == ""))) {
                        result[i] = child.domNode;
                        i++;
                    }
                    else if(child.item.type[0] == 'TrackGroup') {
                        var nodesChildren = getChildrenRecursive(child.domNode);
                        result = result.concat(nodesChildren);
                        i += nodesChildren.length;
                    }
                }
                return result;
            }
            else if((node.style.display != "none")
                    &&((!node.firstChild.childNodes[2].childNodes[1].style.color)
                       ||(node.firstChild.childNodes[2].childNodes[1].style.color == ""))) {
                return [node];
            }
            return [];
        }
        var reviewed_nodes = [];
        var j = 0;
        for(var i = 0; i < nodes.length; i++) {
            reviewed_nodes = reviewed_nodes.concat(getChildrenRecursive(nodes[i]));
        }
        nodes = reviewed_nodes;

        var oldCreator = this._normalizedCreator;
        // transferring nodes from the source to the target
        if(this.creator){
            // use defined creator
            this._normalizedCreator = function(node, hint){
                return oldCreator.call(this, source.getItem(node.id).data, hint);
            };
        }else{
            // we have no creator defined => move/clone nodes
            if(copy){
                // clone nodes
                this._normalizedCreator = function(node, hint){
                    var t = source.getItem(node.id);
                    var n = node.cloneNode(true);
                    n.id = dojo.dnd.getUniqueId();
                    return {node: n, data: t.data, type: t.type};
                };
            }else{
                // move nodes
                this._normalizedCreator = function(node, hint){
                    var t = source.getItem(node.id);
                    source.delItem(node.id);
                    return {node: node, data: t.data, type: t.type};
                };
            }
        }
        this.selectNone();
        if(!copy && !this.creator){
            source.selectNone();
        }
        this.insertNodes(true, nodes, this.before, this.current);
        if(!copy && this.creator && (source instanceof dojo.dnd.Source)){
            source.deleteSelectedNodes();
        }
        if(this.creator && source instanceof dijit.tree.dndSource) {
            for(var i = 0; i < nodes.length; i++) {
                nodes[i].firstChild.childNodes[2].childNodes[1].style.cssText = "color: "+ brwsr.disabledColor;
            }
            this.selectNone();
        }
        this._normalizedCreator = oldCreator;
    };

    var trackCreate = function(track, hint) {
        var node;
        if ("avatar" == hint) {
            return trackListCreate(track, hint);
        } else {
            if(track != '[object Object]') {
                track = {'url' : String(store.getValue(track.item, 'url')),
                         'label' : track.label,
                         'key' : track.label,
                         'args_chunkSize': String(store.getValue(track.item, 'args_chunkSize')),
                         'type' : String(store.getValue(track.item, 'type'))};
            }
            var replaceData = {refseq: brwsr.refSeq.name};
            var url = track.url.replace(/\{([^}]+)\}/g, function(match, group) {return replaceData[group];});
            var klass = eval(track.type);
            var newTrack = new klass(track, url, brwsr.refSeq,
                                     {
                                         changeCallback: changeCallback,
                                         trackPadding: brwsr.view.trackPadding,
                                         baseUrl: brwsr.dataRoot,
                                         charWidth: brwsr.view.charWidth,
                                         seqHeight: brwsr.view.seqHeight
                                     });
            node = brwsr.view.addTrack(newTrack);
            var btn = new dijit.form.Button(
                            { label: "close" , 
                              showLabel: false,
                              iconClass: "dijitTabCloseButton",
                              onClick: function() {
                                  brwsr.viewDndWidget.delItem(node.id);
                                  node.parentNode.removeChild(node);
                                  brwsr.onVisibleTracksChanged();
                                  var map = brwsr.mapLabelToNode(tree._itemNodesMap.ROOT[0].getChildren(), {});
                                  map[track.label].firstChild.childNodes[2].childNodes[1].style.color = "";
                                  if(window.frames["browsing_window"] && window.frames["browsing_window"].start_faceted_browsing) window.frames["browsing_window"].start_faceted_browsing(dojo.cookie(brwsr.container.id + "-tracks"));
                                  if(track_customization_on && (brwsr.trackCurrentlyCustomized == track.label)) {
                                      window.brwsr.fillCustomizeTrackTab();
                                  }
                            }});
            btn.domNode.firstChild.style.cssText = 'background: none; border-style: none; border-width: 0px; padding: 0em;';
            newTrack.label.insertBefore(btn.domNode, newTrack.deleteButtonContainer);
        }
        return {node: node, data: track, type: ["track"]};
    };

    this.viewDndWidget = new dojo.dnd.Source(this.view.zoomContainer,
                                       {
                                           creator: trackCreate,
                                           onDropExternal: DropFromOutside,
                                           accept: ["treeNode"],
                                           withHandles: true
                                       });

    var externalSourceCreator = function(nodes, target, source) {
        return dojo.map(nodes, function(node){
            var dataObj = brwsr.viewDndWidget.getItem(node.id);
            brwsr.viewDndWidget.delItem(node.id);
            node.parentNode.removeChild(node);
            brwsr.onVisibleTracksChanged();
            return {
                'key' : node.id,
                'label' : dataObj.data.label, 
                'type' : dataObj.data.type,
                'url' : dataObj.data.url,
                'args_chunkSize': dataObj.data.args_chunkSize
            };
        });
    };

    var dropOnTrackList = function(source, nodes, copy) {
        if((source instanceof dojo.dnd.Source)&& this.targetAnchor) {
            for(var i = 0; i < nodes.length; i++) {
                var node = nodes[i];
                var dataObj = brwsr.viewDndWidget.getItem(node.id);
                brwsr.viewDndWidget.delItem(node.id);
                node.parentNode.removeChild(node);
                brwsr.onVisibleTracksChanged();

                if(track_customization_on && (brwsr.trackCurrentlyCustomized == dataObj.data.label)) {
                    window.brwsr.fillCustomizeTrackTab();
                }

                var mapHTMLNode = brwsr.mapLabelToNode(brwsr.tree._itemNodesMap.ROOT[0].getChildren(), {});
                mapHTMLNode[dataObj.data.label].firstChild.childNodes[2].childNodes[1].style.color = "";

                var mapWidget = brwsr.mapLabelToWidget(brwsr.tree._itemNodesMap.ROOT[0].getChildren(), {});
                var sourceItem = mapWidget[dataObj.data.label];
                var childItem = sourceItem.item;
                var oldParentItem = sourceItem.getParent().item;
                var target = this.targetAnchor;
                var model = this.tree.model;
                var newParentItem = (target && target.item) || this.tree.item;
                var insertIndex;
                if(this.dropPosition == "Before" || this.dropPosition == "After"){
                    newParentItem = (target.getParent() && target.getParent().item) || this.tree.item;
                    // Compute the insert index for reordering
                    insertIndex = target.getIndexInParent();
                    if(this.dropPosition == "After") {
                        insertIndex = target.getIndexInParent() + 1;
                    }
                }else{
                    newParentItem = (target && target.item) || this.tree.item;
                }
                if(typeof insertIndex == "number"){
                    if(newParentItem == oldParentItem && sourceItem.getIndexInParent() < insertIndex){
                        insertIndex -= 1;
                    }
                }
                brwsr.treeModel.pasteItem(childItem, oldParentItem, newParentItem, false, insertIndex); 
            }
        }
        if((source instanceof dijit.tree.dndSource) && (this.containerState == "Over")){
            var tree = this.tree,
            model = tree.model,
            target = this.targetAnchor,
            requeryRoot = false;    // set to true iff top level items change

            this.isDragging = false;

            // Computif(this.containerState == "Over"){
            var newParentItem;
            var insertIndex;
            newParentItem = (target && target.item) || tree.item;
            if(this.dropPosition == "Before" || this.dropPosition == "After"){
                newParentItem = (target.getParent() && target.getParent().item) || tree.item;
                // Compute the insert index for reordering
                insertIndex = target.getIndexInParent();
                if(this.dropPosition == "After"){
                    insertIndex = target.getIndexInParent() + 1;
                }
            }else{
                newParentItem = (target && target.item) || tree.item;
            }

            // If necessary, use this variable to hold array of hashes to pass to model.newItem()
            // (one entry in the array for each dragged node).
            var newItemsParams;

            dojo.forEach(nodes, function(node, idx){
                // dojo.dnd.Item representing the thing being dropped.
                // Don't confuse the use of item here (meaning a DnD item) with the
                // uses below where item means dojo.data item.
                var sourceItem = source.getItem(node.id);

                // Information that's available if the source is another Tree
                // (possibly but not necessarily this tree, possibly but not
                // necessarily the same model as this Tree)
                if(dojo.indexOf(sourceItem.type, "treeNode") != -1){
                    var childTreeNode = sourceItem.data,
                    childItem = childTreeNode.item,
                    oldParentItem = childTreeNode.getParent().item;
                }

                if(source == this){
                    // This is a node from my own tree, and we are moving it, not copying.
                    // Remove item from old parent's children attribute.

                    if(typeof insertIndex == "number"){
                        if(newParentItem == oldParentItem && childTreeNode.getIndexInParent() < insertIndex){
                            insertIndex -= 1;
                        }
                    }
                    model.pasteItem(childItem, oldParentItem, newParentItem, copy, insertIndex);
                }else if(model.isItem(childItem)){
                    // Item from same model
                    // (maybe we should only do this branch if the source is a tree?)
                    model.pasteItem(childItem, oldParentItem, newParentItem, copy, insertIndex);
                }else{
                    // Get the hash to pass to model.newItem().  A single call to
                    // itemCreator() returns an array of hashes, one for each drag source node.
                    if(!newItemsParams){
                        newItemsParams = this.itemCreator(nodes, target.rowNode, source);
                    }

                    // Create new item in the tree, based on the drag source.
                    model.newItem(newItemsParams[idx], newParentItem, insertIndex);
                }
            }, this);

            // Expand the target node (if it's currently collapsed) so the user can see
            // where their node was dropped.   In particular since that node is still selected.
            this.tree._expandNode(target);
        }
        this.onDndCancel();
    };

    var nodePlacementAcceptance = function(target, source, position) {
        var item = dijit.getEnclosingWidget(target).item;
        if((item.type[0] == "TrackGroup") && (position == 'over')) {
            return true;
        }
        if((position == 'before') || (position == 'after')) {
            return true;
        }
        return false;
    };

    function deepCopy(trackData){
        if(typeof trackData == 'object') {
            if(trackData instanceof Array) {
                var newArray = [];
                for(var i = 0; i < trackData.length; i++) {
                    newArray[i] = deepCopy(trackData[i]);
                }
                return newArray;
            }
            else {
                var newObj = {}
                for(var propertyName in trackData) {
                    newObj[propertyName] = deepCopy(trackData[propertyName]);
                }
                return newObj;
            }
        }
        else {
            return trackData;
        }
    }

    // create the track list tree structure

    var originalTrackData = deepCopy(params.trackData);

    var store = new dojo.data.ItemFileWriteStore({
        clearOnClose: true,
        data: {
                identifier: 'key',
                label: 'label',
                items: params.trackData
              }
    });

    this.store = store;
    store.save();

    var treeModel = new dijit.tree.TreeStoreModel({
        store: store,
        query: {
            "label": "ROOT"
        },
        childrenAttrs: ["children"]
    });

    this.treeModel = treeModel;

    var tree = new dijit.Tree({
        dragThreshold: 0,
        model: treeModel,
        dndController: "dijit.tree.dndSource",
        showRoot: false,
        itemCreator: externalSourceCreator,
        onDndDrop: dropOnTrackList,
        betweenThreshold: 5,
        openOnDblClick: true,
        checkItemAcceptance: nodePlacementAcceptance
    },
    "treeList");

    this.tree = tree;

    dojo.subscribe("/dnd/drop", function(source,nodes,iscopy){
    //whenever a track is moved reset cookie values
                       brwsr.onVisibleTracksChanged();
                       brwsr.onTrackListOrderingChanged();
                   });

    // display given tracks and disable in the track list
    var oldTrackList = dojo.cookie(this.container.id + "-tracks");
    if (params.tracks) {
        this.showTracks(params.tracks);
    } else if (oldTrackList || oldTrackList == "") {
        this.showTracks(oldTrackList);
    } else if (params.defaultTracks) {
        this.showTracks(params.defaultTracks);
    }

    // reorder track list
    var oldTrackListOrder = dojo.cookie(this.container.id + "-ordering");
    if(oldTrackListOrder) {
        this.reorderTracks(oldTrackListOrder);
    }

    var treeSearch = new dijit.form.TextBox({
        name: "search",
        value: ""
    },
    "search");

    function searchTrackList(searchTerm) {
        var map = brwsr.mapLabelToNode(tree._itemNodesMap.ROOT[0].getChildren(), {});

        function fetchFailed(error, request) {
            alert("lookup failed");
            alert(error);
        };

        function gotItems(items, request) {

            // returns the number of visible children of a node
            function numVisibleChildrenNodes(item){
                if(item.type[0] == 'TrackGroup') {
                    var result = 0;
                    var i = 0;
                    var children = item.children;
                    if(!children) return 0;
                    for(var n = 0; n < children.length; n++) {
                        var child = map[children[n].label];
                        if((child.style.display != "none")&&(children[n].type[0] != 'TrackGroup')) {
                            result += 1;
                        }
                        else if(children[n].type[0] == 'TrackGroup') {
                            result = result + numVisibleChildrenNodes(children[n]);
                        }
                    }
                    return result;
                }
                return 0;
            }

            var i;
            var pattern = new RegExp("");
            pattern = new RegExp(searchTerm.toLowerCase());
            for(i = 0; i < items.length; i++) {
                if(map[items[i].label]) {
                    var node = map[items[i].label];
                    if(String(items[i].type) == 'TrackGroup') {
                        node.style.cssText = "display: block";
                    }
                    if((!pattern.test(String(items[i].label).toLowerCase()) && String(items[i].type) != 'TrackGroup')) {
                        // hide the none if it doesn't match
                        node.style.cssText = "display: none";
                    }
                    else {
                        // show the node if it matches
                        node.style.cssText = "display: block";
                        if(pattern.test(String(items[i].label).toLowerCase()) && (searchTerm != "")) {
                            // highlight the matching part of the track name

                            var beginningPat = new RegExp( ".*"+searchTerm.toLowerCase());
                            var beginningText = String(beginningPat.exec(String(items[i].label).toLowerCase()));
                            beginningText = String(items[i].label).substring(0, beginningText.length - searchTerm.length);
                            var beginning = document.createElement("span");
                            beginning.innerHTML = beginningText;

                            var endingText = String(items[i].label).substring(searchTerm.length+beginningText.length);
                            var end = document.createElement("span");
                            end.innerHTML = endingText;

                            var highlight = document.createElement("b");
                            highlight.innerHTML= String(items[i].label).substring(beginningText.length, beginningText.length+searchTerm.length);

                            node.firstChild.childNodes[2].childNodes[1].innerHTML = "";
                            node.firstChild.childNodes[2].childNodes[1].appendChild(beginning);
                            node.firstChild.childNodes[2].childNodes[1].appendChild(highlight);
                            node.firstChild.childNodes[2].childNodes[1].appendChild(end);
                        }
                        else {
                            // if the search term is the empty string return the track name to not being highlighted
                            node.firstChild.childNodes[2].childNodes[1].innerHTML = items[i].label;
                        }
                    }
                }
            }
            for(i = 0; i < items.length; i++) {
                // hide the TrackGroup if it contains no matching tracks and it doesn't match
                if(map[items[i].label] && String(items[i].type) == 'TrackGroup' && !pattern.test(String(items[i].label).toLowerCase())) {
                    if(numVisibleChildrenNodes(items[i]) == 0) {
                        map[items[i].label].style.cssText = "display: none";
                    }
                }
            }
        };

        store.fetch({
            onComplete: gotItems,
            onError: fetchFailed
        });
    }
    dojo.connect(treeSearch, "onKeyUp", function() {
        var searchTerm = treeSearch.attr("value");
        searchTrackList(searchTerm);
    });
    dojo.connect(searchClearBtn, "onClick", function() {
        searchTrackList("");
        treeSearch.attr("value", "");
    });
    dojo.connect(treeResetBtn, "onClick", function() {
        // clear any search value
        treeSearch.attr("value", "");

        //detroy current tree, model and store data
        tree.destroyRecursive();
        treeModel.destroy();
        store.revert();
        store.close();

        // create new tree, model, and store data
        var data = deepCopy(originalTrackData);

        store.data = {
                identifier: 'key',
                label: 'label',
                items: data
              };

        treeModel = new dijit.tree.TreeStoreModel({
            store: store,
            query: {
                "label": "ROOT"
            },
            childrenAttrs: ["children"]
        });

        treeSection = document.createElement("div");
        treeSection.id = "treeList";
        treeSection.style.cssText =
            "width: 100%; height: 100%; overflow-x: visible; overflow-y: auto;";

        leftPane.appendChild(treeSection);

        tree = new dijit.Tree({
            dragThreshold: 0,
            model: treeModel,
            dndController: "dijit.tree.dndSource",
            showRoot: false,
            itemCreator: externalSourceCreator,
            onDndDrop: dropOnTrackList,
            betweenThreshold: 5,
            openOnDblClick: true,
            checkItemAcceptance: nodePlacementAcceptance
        },
        "treeList");

        store.save();
        brwsr.tree = tree;
        brwsr.treeModel = brwsr.treeModel;

        // load tracks to the display and disable the track in the track list
        var trackNames;
        var oldTrackList = dojo.cookie(brwsr.container.id + "-tracks");
        if (params.tracks) {
            trackNames = params.tracks;
        } else if (oldTrackList || oldTrackList == "") {
            trackNames = oldTrackList;
        } else if (params.defaultTracks) {
            trackNames = params.defaultTracks;
        }

        var map = brwsr.mapLabelToNode(tree._itemNodesMap.ROOT[0].getChildren(), {});

        trackNames = trackNames.split(",");
        for (var n = 0; n < trackNames.length; n++) {
            if(map[trackNames[n]]) {
                map[trackNames[n]].firstChild.childNodes[2].childNodes[1].style.cssText = "color: " + brwsr.disabledColor;
            }
        }

        // record new track list ordering
        brwsr.onTrackListOrderingChanged();
    });
};

/**
 * hides the track in the track list
 * @param label corresponds to the "label" element of the track information dictionaries
 */
Browser.prototype.hideTrackListNode = function(label) {
    var map = this.mapLabelToNode(this.tree._itemNodesMap.ROOT[0].getChildren(), {});
    map[label].style.cssText = "display: none";
}

/**
 * shows the track in the track list
 * @param label corresponds to the "label" element of the track information dictionaries
 */
Browser.prototype.showTrackListNode = function(label) {
    var map = this.mapLabelToNode(this.tree._itemNodesMap.ROOT[0].getChildren(), {});
    map[label].style.cssText = "display: block";
}

/**
 * removes all the tracks from the display area
 */
Browser.prototype.removeAllTracks = function() {
    this.viewDndWidget.selectAll();
    this.viewDndWidget.deleteSelectedNodes();
    this.blackAll(this.tree._itemNodesMap.ROOT[0].getChildren());
    this.onVisibleTracksChanged();
}

/**
 * makes the text for all children of treeRoot to the default text color, black (which means it is not in the track display)
 */
Browser.prototype.blackAll = function(treeRoot) {
    for( var i = 0; i < treeRoot.length; i++) {
        var node = treeRoot[i];
        // expand the node so the children are available
        var open = node.isExpanded;
        if(node.isExpandable) {
            this.tree._expandNode(node);
        }

        //recurse if needed and make the node's text the enabled color
        if(node.getChildren()[0] != undefined) {
            this.blackAll(node.getChildren());
        }
        else {
            node.domNode.firstChild.childNodes[2].childNodes[1].style.color = "";
        }
        // close the node up if originally closed
        if(!open) {
            this.tree._collapseNode(node);
        }
    }
}

/**
 * hides the track in the track list
 * @param label corresponds to the "label" element of the track information dictionaries
 */
Browser.prototype.hideAllTrackList = function() {
    this.changeDisplayAll(this.tree._itemNodesMap.ROOT[0].getChildren(), "display: none");
}

/**
 * shows the track in the track list
 * @param label corresponds to the "label" element of the track information dictionaries
 */
Browser.prototype.showAllTrackList = function() {
    this.changeDisplayAll(this.tree._itemNodesMap.ROOT[0].getChildren(), "display: block");
    
}

/**
 * makes the text css for all children of treeRoot to display
 */
Browser.prototype.changeDisplayAll = function(treeRoot, display) {
    for( var i = 0; i < treeRoot.length; i++) {
        var node = treeRoot[i];
        // expand the node so the children are available
        var open = node.isExpanded;
        if(node.isExpandable) {
            this.tree._expandNode(node);
        }
    
        //recurse if needed and show the node
        if(node.getChildren()[0] != undefined) {
            this.changeDisplayAll(node.getChildren(), display);
        }
        else {
            node.domNode.style.cssText = display;
        }
        // close the node up if originally closed
        if(!open) {
            this.tree._collapseNode(node);
        }
    }
}

/**
 * @private
 */
Browser.prototype.onVisibleTracksChanged = function() {
    this.view.updateTrackList();
    var trackLabels = dojo.map(this.view.tracks,
                               function(track) { return track.name; });
    dojo.cookie(this.container.id + "-tracks",
                trackLabels.join(","),
                {expires: 60});
    this.view.showVisibleBlocks();
};

/**
 * @private
 */
Browser.prototype.onTrackListOrderingChanged = function() {
    dojo.cookie(this.container.id+ "-ordering",
                dojo.toJson(this.makeTrackListOrdering(this.tree._itemNodesMap.ROOT[0].getChildren())),
                {expires: 60});
}

/**
 * @private
 */
Browser.prototype.makeTrackListOrdering = function(nodes) {
    var ordering = [];

    var j = 0;
    for(var i = 0; i < nodes.length; i++) {
        ordering[j] = nodes[i].label;
        j++;
        if(nodes[i].isExpandable) {
            ordering[j] = this.makeTrackListOrdering(nodes[i].getChildren());
            j++;
        }
    }
    return ordering;
}

/**
 * @private
 * add new tracks to the track list
 * @param trackList list of track information items
 * @param replace true if this list of tracks should replace any existing
 * tracks, false to merge with the existing list of tracks
 */
Browser.prototype.addTracks = function(trackList, replace) {
    if (!this.isInitialized) {
        var brwsr = this;
        this.deferredFunctions.push(
            function() {brwsr.addTracks(trackList, show); }
        );
	return;
    }

    this.tracks.concat(trackList);
    if (show || (show === undefined)) {
        this.showTracks(dojo.map(trackList,
                                 function(t) {return t.label;}).join(","));
    }
};

/**
 * navigate to a given location
 * @example
 * gb=dojo.byId("GenomeBrowser").genomeBrowser
 * gb.navigateTo("ctgA:100..200")
 * gb.navigateTo("f14")
 * @param loc can be either:<br>
 * &lt;chromosome&gt;:&lt;start&gt; .. &lt;end&gt;<br>
 * &lt;start&gt; .. &lt;end&gt;<br>
 * &lt;center base&gt;<br>
 * &lt;feature name/ID&gt;
 */
Browser.prototype.navigateTo = function(loc) {
    if (!this.isInitialized) {
        var brwsr = this;
        this.deferredFunctions.push(function() { brwsr.navigateTo(loc); });
	return;
    }

    loc = dojo.trim(loc);
    //                                (chromosome)    (    start      )   (  sep     )     (    end   )
    var matches = String(loc).match(/^(((\S*)\s*:)?\s*(-?[0-9,.]*[0-9])\s*(\.\.|-|\s+))?\s*(-?[0-9,.]+)$/i);
    //matches potentially contains location components:
    //matches[3] = chromosome (optional)
    //matches[4] = start base (optional)
    //matches[6] = end base (or center base, if it's the only one)
    if (matches) {
	if (matches[3]) {
	    var refName;
	    for (ref in this.allRefs) {
		if ((matches[3].toUpperCase() == ref.toUpperCase())
                    ||
                    ("CHR" + matches[3].toUpperCase() == ref.toUpperCase())
                    ||
                    (matches[3].toUpperCase() == "CHR" + ref.toUpperCase())) {

		    refName = ref;
                }
            }
	    if (refName) {
		dojo.cookie(this.container.id + "-refseq", refName, {expires: 60});
		if (refName == this.refSeq.name) {
		    //go to given start, end on current refSeq
		    this.view.setLocation(this.refSeq,
					  parseInt(matches[4].replace(/[,.]/g, "")),
					  parseInt(matches[6].replace(/[,.]/g, "")));
		} else {
                    /*dojo.byId("overview").removeChild(dojo.byId('dynamicZoomHighStart'));
                    dojo.byId("overview").removeChild(dojo.byId('dynamicZoomHigh'));
                    dojo.byId("overview").removeChild(dojo.byId('selectedAreaHigh'));*/
		    //new refseq, record open tracks and re-open on new refseq
                    var curTracks = [];
                    this.viewDndWidget.forInItems(function(obj, id, map) {
                            curTracks.push(obj.data);
                        });

		    for (var i = 0; i < this.chromList.options.length; i++)
			if (this.chromList.options[i].text == refName)
			    this.chromList.selectedIndex = i;
		    this.refSeq = this.allRefs[refName];
		    //go to given refseq, start, end
		    this.view.setLocation(this.refSeq,
					  parseInt(matches[4].replace(/[,.]/g, "")),
					  parseInt(matches[6].replace(/[,.]/g, "")));
                    this.viewDndWidget.insertNodes(false, curTracks);
                    this.onVisibleTracksChanged();

                    dijit.getEnclosingWidget(dojo.byId("GenomeBrowser")).resize();
                    
                    //this.createHighLevelRubberBandZoom(this.refSeq);

                    if(elastic_zoom_high_on) {
                        dojo.byId('dynamicZoomHighStart').style.height = parseInt(dojo.byId('overview').style.height) + 10 + "px";
                        dojo.byId('dynamicZoomHigh').style.height = parseInt(dojo.byId('overview').style.height) + 10 + "px";
                        dojo.byId('selectedAreaHigh').style.height = parseInt(dojo.byId('overview').style.height) + 10 + "px";
                    }
                    dojo.byId('overviewtrack_overview_loc_track').style.height = '10px';
		}
		return;
	    }
	} else if (matches[4]) {
	    //go to start, end on this refseq
	    this.view.setLocation(this.refSeq,
				  parseInt(matches[4].replace(/[,.]/g, "")),
				  parseInt(matches[6].replace(/[,.]/g, "")));
	    return;
	} else if (matches[6]) {
	    //center at given base
	    this.view.centerAtBase(parseInt(matches[6].replace(/[,.]/g, "")));
	    return;
	}
    }
    //if we get here, we didn't match any expected location format

    var brwsr = this;
    this.names.exactMatch(loc, function(nameMatches) {
	    var goingTo;
	    //first check for exact case match
	    for (var i = 0; i < nameMatches.length; i++) {
		if (nameMatches[i][1] == loc)
		    goingTo = nameMatches[i];
	    }
	    //if no exact case match, try a case-insentitive match
            if (!goingTo) {
                for (var i = 0; i < nameMatches.length; i++) {
                    if (nameMatches[i][1].toLowerCase() == loc.toLowerCase())
                        goingTo = nameMatches[i];
                }
            }
            //else just pick a match
	    if (!goingTo) goingTo = nameMatches[0];
	    var startbp = goingTo[3];
	    var endbp = goingTo[4];
	    var flank = Math.round((endbp - startbp) * .2);
	    //go to location, with some flanking region
	    brwsr.navigateTo(goingTo[2]
			     + ":" + (startbp - flank)
			     + ".." + (endbp + flank));
	    brwsr.showTracks(brwsr.names.extra[nameMatches[0][0]]);
	});
};

/**
 * @private
 */
Browser.prototype.mapLabelToNode = function(treeRoot, map) {
    for( var i = 0; i < treeRoot.length; i++) {
        var node = treeRoot[i];
        // expand the node so the children are available
        var open = node.isExpanded;
        if(node.isExpandable) {
            this.tree._expandNode(node);
        }
        // map the html node to the label and recurse if needed
        map[node.label] = node.domNode;
        if(node.getChildren()[0] != undefined) {
            this.mapLabelToNode(node.getChildren(), map);
        }
        // close the node up if originally closed
        if(!open) {
            this.tree._collapseNode(node);
        }
    } 
    return map;
}

/**
 * @private
 */
Browser.prototype.mapLabelToWidget = function(treeRoot, map) {
    for( var i = 0; i < treeRoot.length; i++) {
        var node = treeRoot[i];
        // expand the node so the children are available
        var open = node.isExpanded;
        if(node.isExpandable) {
            this.tree._expandNode(node);
        }
        // map the node's widget to the label and recurse if needed
        map[node.label] = node;
        if(node.getChildren()[0] != undefined) {
            this.mapLabelToWidget(node.getChildren(), map);
        }
        // close the node up if originally closed
        if(!open) {
            this.tree._collapseNode(node);
        }
    }
    return map;
}

/**
 * reorder the given tracks in the specified json format
 * gb=dojo.byId("GenomeBrowser").genomeBrowser
 * gb.showTracks("[grouping1,[DNA,gene],grouping2,[mRNA, noncodingRNA]]")
 * @param trackOrderList {String} json array string containing track names,
 * each of which should correspond to the "label" element of the track
 * information dictionaries, if a element is a folder the following element is a 
 * json array of the same format as trackOrderList
 */
Browser.prototype.reorderTracks = function(trackOrderList) {
    var oldTrackListOrder = dojo.fromJson(trackOrderList);
    if(oldTrackListOrder) {
        //start reorder on the root of the tree
        this.reorderSection(oldTrackListOrder, dijit.getEnclosingWidget(dojo.byId("dijit__TreeNode_0")).item);
    }
}

/**
 * @private
 */
Browser.prototype.reorderSection = function(trackOrder, newParent) {
    if (!this.isInitialized) {
        var brwsr = this;
        this.deferredFunctions.push(
            function() { brwsr.reorderSection(trackOrder, newParent); }
        );
        return;
    }

    var map = this.mapLabelToWidget(dijit.getEnclosingWidget(dojo.byId("dijit__TreeNode_0")).getChildren(), {});

    for(var i = 0; i < trackOrder.length; i++) {
        // get arguments and move the node to the specified order
        var sourceItem = map[trackOrder[i]];
        var childItem = sourceItem.item;
        var insertIdx = i;
        if(typeof trackOrder[i+1] == "object") {
            // TrackGroup/array of label next so recurse on group
            this.reorderSection(trackOrder[i+1], childItem);
            i++;
        }
        var oldParentItem = sourceItem.getParent().item;
        var newParentItem = newParent;
        this.treeModel.pasteItem(childItem, oldParentItem, newParentItem, false, insertIdx);
    }
}

/**
 * load and display the given tracks
 * @example
 * gb=dojo.byId("GenomeBrowser").genomeBrowser
 * gb.showTracks("DNA,gene,mRNA,noncodingRNA")
 * @param trackNameList {String} comma-delimited string containing track names,
 * each of which should correspond to the "label" element of the track
 * information dictionaries
 */
Browser.prototype.showTracks = function(trackNameList) {
    if (!this.isInitialized) {
        var brwsr = this;
        this.deferredFunctions.push(
            function() { brwsr.showTracks(trackNameList); }
        );
	return;
    }

    var trackNames = trackNameList.split(",");
    //var trackInput = [];
    var brwsr = this;
    var store = this.store;
    var tree = this.tree;

    var map = brwsr.mapLabelToNode(dijit.getEnclosingWidget(dojo.byId("dijit__TreeNode_0")).getChildren(), {});

    for (var n = 0; n < trackNames.length; n++) {
        if(map[trackNames[n]]) {
            map[trackNames[n]].firstChild.childNodes[2].childNodes[1].style.cssText = "color: " + brwsr.disabledColor;
        }
        function fetchFailed(error, request) {
            alert("lookup failed");
            alert(error);
        }
    
        function gotItems(items, request) {
            var i;
            for(i = 0; i < items.length; i++) {
                var dataObj = {'url' : items[i].url[0],
                               'label' : items[i].label[0],
                               'type' : items[i].type[0],
                               'key' : items[i].label[0],
                               'args_chunkSize': (items[i].args_chunkSize? items[i].args_chunkSize[0] :  2000)};
                brwsr.viewDndWidget.insertNodes(false, [dataObj]);
            }
            brwsr.onVisibleTracksChanged();
        }

        store.fetch({
            query: { "label" : trackNames[n]},
            queryOptions : { "ignoreCase" : true },
            onComplete: gotItems,
            onError: fetchFailed
        });
    }
};

Browser.prototype.displayTrack = function(trackName, loc, anchor) {
    if (!this.isInitialized) {
        var brwsr = this;
        this.deferredFunctions.push(
            function() { brwsr.showTracks(trackName); }
        );
	return;
    }

    var brwsr = this;
    var store = this.store;
    var tree = this.tree;

    var map = brwsr.mapLabelToNode(dijit.getEnclosingWidget(dojo.byId("dijit__TreeNode_0")).getChildren(), {});

    if(map[trackName]) {
        map[trackName].firstChild.childNodes[2].childNodes[1].style.cssText = "color: " + brwsr.disabledColor;
    }
    function fetchFailed(error, request) {
        alert("lookup failed");
        alert(error);
    }
   
    function gotItems(items, request) {
        var i;
        for(i = 0; i < items.length; i++) {
            var dataObj = {'url' : items[i].url[0],
                           'label' : items[i].label[0],
                           'type' : items[i].type[0],
                           'key' : items[i].label[0],
                           'args_chunkSize': (items[i].args_chunkSize? items[i].args_chunkSize[0] :  2000)};
            brwsr.viewDndWidget.insertNodes(false, [dataObj], loc, anchor);
        }
        brwsr.onVisibleTracksChanged();
    }

    store.fetch({
        query: { "label" : trackName},
        queryOptions : { "ignoreCase" : true },
        onComplete: gotItems,
        onError: fetchFailed
    });
};


/**
 * @returns {String} string representation of the current location<br>
 * (suitable for passing to navigateTo)
 */
Browser.prototype.visibleRegion = function() {
    return this.view.ref.name + ":" + Math.round(this.view.minVisible()) + ".." + Math.round(this.view.maxVisible());
};

/**
 * @returns {String} containing comma-separated list of currently-viewed tracks<br>
 * (suitable for passing to showTracks)
 */
Browser.prototype.visibleTracks = function() {
    var trackLabels = dojo.map(this.view.tracks,
                               function(track) { return track.name; });
    return trackLabels.join(",");
};

/**
 * @private
 */
Browser.prototype.onCoarseMove = function(startbp, endbp) {
    var length = this.view.ref.end - this.view.ref.start;
    var trapLeft = Math.round((((startbp - this.view.ref.start) / length)
                               * this.view.overviewBox.w) + this.view.overviewBox.l);
    var trapRight = Math.round((((endbp - this.view.ref.start) / length)
                                * this.view.overviewBox.w) + this.view.overviewBox.l);

    this.view.locationThumb.style.cssText =
    "height: " + (this.view.overviewBox.h - 4) + "px; "
    + "left: " + trapLeft + "px; "
    + "width: " + (trapRight - trapLeft) + "px;"
    + "z-index: 20;";

    //since this method gets triggered by the initial GenomeView.sizeInit,
    //we don't want to save whatever location we happen to start at
    if (! this.isInitialized) return;
    var locString = Util.addCommas(Math.round(startbp)) + " .. " + Util.addCommas(Math.round(endbp));
    this.locationBox.value = locString;
    this.goButton.disabled = true;
    this.locationBox.blur();
    var oldLocMap = dojo.fromJson(dojo.cookie(this.container.id + "-location"));
    if ((typeof oldLocMap) != "object") oldLocMap = {};
    oldLocMap[this.refSeq.name] = locString;
    dojo.cookie(this.container.id + "-location",
                dojo.toJson(oldLocMap),
                {expires: 60});

    document.title = this.refSeq.name + ":" + locString;
};

/**
 * @private
 */
Browser.prototype.createNavBox = function(parent, locLength, params) {
    var brwsr = this;
    var navbox = document.createElement("div");
    var browserRoot = params.browserRoot ? params.browserRoot : "";
    navbox.id = "navbox";
    parent.appendChild(navbox);
    navbox.style.cssText = "text-align: center; padding: 2px; z-index: 10;";

    if (params.bookmark) {
        this.link = document.createElement("a");
        this.link.appendChild(document.createTextNode("Link"));
        this.link.href = window.location.href;
        dojo.connect(this, "onCoarseMove", function() {
                         brwsr.link.href = params.bookmark(brwsr);
                     });
        dojo.connect(this, "onVisibleTracksChanged", function() {
                         brwsr.link.href = params.bookmark(brwsr);
                     });
        this.link.style.cssText = "float: right; clear";
        navbox.appendChild(this.link);
    }

    var moveLeft = document.createElement("input");
    moveLeft.type = "image";
    moveLeft.src = browserRoot + "img/slide-left.png";
    moveLeft.id = "moveLeft";
    moveLeft.className = "icon nav";
    moveLeft.style.height = "40px";
    dojo.connect(moveLeft, "click",
                 function(event) {
                     dojo.stopEvent(event);
                     brwsr.view.slide(0.9);
                 });
    navbox.appendChild(moveLeft);

    var moveRight = document.createElement("input");
    moveRight.type = "image";
    moveRight.src = browserRoot + "img/slide-right.png";
    moveRight.id="moveRight";
    moveRight.className = "icon nav";
    moveRight.style.height = "40px";
    dojo.connect(moveRight, "click",
                 function(event) {
                     dojo.stopEvent(event);
                     brwsr.view.slide(-0.9);
                 });
    navbox.appendChild(moveRight);

    navbox.appendChild(document.createTextNode("\u00a0\u00a0\u00a0\u00a0"));

    var bigZoomOut = document.createElement("input");
    bigZoomOut.type = "image";
    bigZoomOut.src = browserRoot + "img/zoom-out-2.png";
    bigZoomOut.id = "bigZoomOut";
    bigZoomOut.className = "icon nav";
    bigZoomOut.style.height = "40px";
    navbox.appendChild(bigZoomOut);
    dojo.connect(bigZoomOut, "click",
                 function(event) {
                     dojo.stopEvent(event);
                     brwsr.view.zoomOut(undefined, undefined, 2);
                 });

    var zoomOut = document.createElement("input");
    zoomOut.type = "image";
    zoomOut.src = browserRoot + "img/zoom-out-1.png";
    zoomOut.id = "zoomOut";
    zoomOut.className = "icon nav";
    zoomOut.style.height = "40px";
    dojo.connect(zoomOut, "click",
                 function(event) {
                     dojo.stopEvent(event);
                     brwsr.view.zoomOut();
                 });
    navbox.appendChild(zoomOut);

    var zoomIn = document.createElement("input");
    zoomIn.type = "image";
    zoomIn.src = browserRoot + "img/zoom-in-1.png";
    zoomIn.id = "zoomIn";
    zoomIn.className = "icon nav";
    zoomIn.style.height = "40px";
    dojo.connect(zoomIn, "click",
                 function(event) {
                     dojo.stopEvent(event);
                     brwsr.view.zoomIn();
                 });
    navbox.appendChild(zoomIn);

    var bigZoomIn = document.createElement("input");
    bigZoomIn.type = "image";
    bigZoomIn.src = browserRoot + "img/zoom-in-2.png";
    bigZoomIn.id = "bigZoomIn";
    bigZoomIn.className = "icon nav";
    bigZoomIn.style.height = "40px";
    dojo.connect(bigZoomIn, "click",
                 function(event) {
                     dojo.stopEvent(event);
                     brwsr.view.zoomIn(undefined, undefined, 2);
                 });
    navbox.appendChild(bigZoomIn);

    navbox.appendChild(document.createTextNode("\u00a0\u00a0\u00a0\u00a0"));
    this.chromList = document.createElement("select");
    this.chromList.id="chrom";
    navbox.appendChild(this.chromList);
    this.locationBox = document.createElement("input");
    this.locationBox.size=locLength;
    this.locationBox.type="text";
    this.locationBox.id="location";
    dojo.connect(this.locationBox, "keydown", function(event) {
            if (event.keyCode == dojo.keys.ENTER) {
                brwsr.navigateTo(brwsr.locationBox.value);
                //brwsr.locationBox.blur();
                brwsr.goButton.disabled = true;
                dojo.stopEvent(event);
            } else {
                brwsr.goButton.disabled = false;
            }
        });
    navbox.appendChild(this.locationBox);

    this.goButton = document.createElement("button");
    this.goButton.appendChild(document.createTextNode("Go"));
    this.goButton.disabled = true;
    dojo.connect(this.goButton, "click", function(event) {
            brwsr.navigateTo(brwsr.locationBox.value);
            //brwsr.locationBox.blur();
            brwsr.goButton.disabled = true;
            dojo.stopEvent(event);
        });
    navbox.appendChild(this.goButton);

    return navbox;
};

/*

Copyright (c) 2007-2009 The Evolutionary Software Foundation

Created by Mitchell Skinner <mitch_skinner@berkeley.edu>

This package and its accompanying libraries are free software; you can
redistribute it and/or modify it under the terms of the LGPL (either
version 2.1, or at your option, any later version) or the Artistic
License 2.0.  Refer to LICENSE for the full license text.

*/
ChromIdeogram.height = 40;
/**
 * for creating a chromosome representation in the track location overview bar 
 */
function ChromIdeogram(refSeq, url) {
    this.baseUrl = window.b.dataRoot ? window.b.dataRoot : "";
    this.url = url;
    this.trackBaseUrl = (this.baseUrl + url).match(/^.+\//);

    var overview = dojo.byId('overview');
    this.clear();

    var elem = document.createElement('div');
    overview.appendChild(elem);
    elem.id = 'chromosome_representation';
    elem.style.width = "100%";
    elem.track = this;
    elem.innerHTML = '';
    this.div = elem;
    var trackData = refSeq.chromBands;
    var onLoad = this.drawChromosome;
    var chrom = this;
    dojo.xhrGet({ url: "data/" + url,
                  handleAs: "json",
                  load: function(data) { 
                            chrom.drawChromosome(elem, refSeq, data);
                            dijit.getEnclosingWidget(dojo.byId("GenomeBrowser")).resize();
                            dojo.byId("dijit_layout_ContentPane_1").style.top = dojo.marginBox(dojo.byId("navbox")).h + parseInt(dojo.byId("overview").style.height) + 10 + "px";

                            if(elastic_zoom_high_on) {
                                dojo.byId('dynamicZoomHighStart').style.height = parseInt(dojo.byId('overview').style.height) + 10 + "px";
                                dojo.byId('dynamicZoomHigh').style.height = parseInt(dojo.byId('overview').style.height) + 10 + "px";
                                dojo.byId('selectedAreaHigh').style.height = parseInt(dojo.byId('overview').style.height) + 10 + "px";
                            }
                            dojo.byId('overviewtrack_overview_loc_track').style.height = '10px'; 
                  }
                });
}

ChromIdeogram.prototype.drawChromosome = function(elem, refSeq, trackData) {
    this.height = 40;

    this.Bands = {};
    this.bandCount = 0;

    // put in the label for the chromosome
    var chrName = document.createElement("div");
    this.chrNameHeight = 20;
    chrName.style.cssText = "color: black; text-align: left; height: "+this.chrNameHeight+"px; width: 75px;";
    chrName.innerHTML = refSeq.name;
    elem.appendChild(chrName);
    
    // create the part of the chromosome before the centromere
    var chr1 = document.createElement("div");
    var chr2;
    chr1.className = "chr";
    elem.appendChild(chr1);

    // create the part of the chromsome after the centromere
    // if the centromere is between 0 and the end of the chromsome
    var length = refSeq.length;
    this.length = length;
    this.centromere = trackData.centromere;
    if(this.centromere > 0 && this.centromere < this.length) {
        chr1.style.width = this.centromere/length * 100 + "%";
        chr2 = document.createElement("div");
        chr2.className = "chr";
        elem.appendChild(chr2);
        chr2.style.width = (length - this.centromere)/length * 100+ "%";
    }
    else {
        chr1.style.width = "100%";
        this.centromere = this.length;
    }

    // create the chromsome bands
    trackData = trackData.chromBands;
    for(var i = 0; i < trackData.length; i++) {
        var start = trackData[i]['loc'];
        var bandLength = trackData[i]['length'];
        if(start <= 0) start = 1;

        if(start < this.centromere) {
            if( start + bandLength > this.centromere) {
                this.createBand(chr2, this.centromere, bandLength - (this.centromere - start));
                bandLength = this.centromere-start;
            }
            this.createBand(chr1, start, bandLength);
        }
        else {
            if(start + bandLength > this.length) bandLength = this.length-start;
            this.createBand(chr2, start, bandLength);
        }
    }

    // add the border of the chromsome
    var chr1_topper = document.createElement("div");
    chr1_topper.className = "chrBorder";
    chr1.appendChild(chr1_topper);
    if(this.centromere < this.length) {
        var chr2_topper = document.createElement("div");
        chr2_topper.className = "chrBorder";
        chr2.appendChild(chr2_topper);
    }
}

/**
 * create the band and save the length and location information
 */
ChromIdeogram.prototype.createBand = function(chr, pos, size, background) {
    var band = document.createElement("div");
    this.setBandCss(band, pos, size, background);
    band.id = "band_"+this.bandCount;
    this.bandCount += 1;
    this.Bands[band.id] = {"pos": pos, "size": size};
    chr.appendChild(band);
}

/**
 * iterate though the bands to reset their locations in the chromsome 
 * and fix the shape at the ends of the chromsome parts
 */
ChromIdeogram.prototype.resetBands = function() {
    for( var i = 0; i < this.bandCount; i++) {
        this.resetBandCss(dojo.byId("band_"+i));
    }
}

/**
 * set the location and shape of the band
 */
ChromIdeogram.prototype.setBandCss = function(band, pos, size, background) {
    if(!background) {
        background= band.style.background? band.style.background : "#E2EBFE";
    }
    band.style.cssText = ""; 
    band.style.height = "15px";
    var left = pos/this.length;
    var width = size/this.length;

    var curvePt = 4;
    var divSize = dojo.marginBox(dojo.byId("overview")).w;
    var leftPx = left * divSize;
    var widthPx = width * divSize;
    var centromerePx = this.centromere/ this.length * divSize;

    var radius = 10;

    // If at the beginning of the first part of the chromosome and needs to be rounded
    if(leftPx < curvePt) {
        band.style.cssText = "-moz-border-radius: 5px 0 0 5px;";
        band.style.height = "15px";
        if(leftPx + widthPx < curvePt) {
            var crossSec = 2 * Math.sqrt( (radius* radius) - ((radius - leftPx - widthPx) * (radius - leftPx - widthPx)));
            if(crossSec > 15) crossSec = 15;
            band.style.height = crossSec + "px";
            band.style.top = (15 - crossSec) /2 + 5 + this.chrNameHeight + "px";
        }
    }
    // If at the end of the first part of the chromosome and needs to be rounded
    if((leftPx >= centromerePx) && (leftPx < centromerePx + curvePt)) {
        band.style.cssText = "-moz-border-radius: 5px 0 0 5px;";
        band.style.height = "15px";
        if(leftPx + widthPx < centromerePx + curvePt) {
	    var crossSec = 2 * Math.sqrt( (radius* radius) - ((radius + centromerePx - leftPx - widthPx) * (radius + centromerePx - leftPx - widthPx)));
            if(crossSec > 15) crossSec = 15;
            band.style.height = crossSec + "px";
            band.style.top = (15 - crossSec) /2 + 5 + this.chrNameHeight + "px";
        }
    }
    // If at the beginning of the second part of the chromosome and needs to be rounded
    if((widthPx + leftPx <= centromerePx+1) && (widthPx + leftPx > centromerePx - curvePt)) {
        band.style.cssText = "-moz-border-radius: 0 5px 5px 0;";
        band.style.height = "15px";
        if(leftPx > centromerePx - curvePt) {
            var crossSec = 2 * Math.sqrt( (radius* radius) - ((radius - centromerePx + leftPx) * (radius - centromerePx + leftPx)));
            if(crossSec > 15) crossSec = 15;
            band.style.height = crossSec + "px";
            band.style.top = (15 - crossSec) /2 + 5 + this.chrNameHeight + "px";
        }
    }
    // If at the end of the second part of the chromosome and needs to be rounded
    if(widthPx + leftPx > divSize - curvePt) {
        band.style.cssText = "-moz-border-radius: 0 5px 5px 0;";
        band.style.height = "15px";
        if(leftPx > divSize - curvePt) {
            var crossSec = 2 * Math.sqrt( (radius* radius) - ((radius - divSize + leftPx) * (radius - divSize + leftPx)));
            if(crossSec > 15) crossSec = 15;
            band.style.height = crossSec + "px";
            band.style.top = (15 - crossSec) /2 + 5 + this.chrNameHeight + "px";
        }
    }

    band.style.width = width*100 + "%";
    band.style.left = left*100 + "%";
    band.style.position = "absolute";
    band.style.background = background;
}

/**
 * get the length and location of the chromosome band from the stored data
 * after it is set when the chromsome is created
 */
ChromIdeogram.prototype.resetBandCss = function(band) {
    var pos = this.Bands[band.id].pos;
    var size = this.Bands[band.id].size;
    this.setBandCss(band, pos, size);
}

ChromIdeogram.prototype.clear = function() {
    if(this.div) {
        this.div.innerHTML = '';
        dojo.byId("overview").removeChild(this.div);
    }
    this.Bands = {};
    this.bandCount = 0;
    this.height = 0;
    dijit.getEnclosingWidget(dojo.byId("GenomeBrowser")).resize();
    dojo.byId("dijit_layout_ContentPane_1").style.top = dojo.marginBox(dojo.byId("navbox")).h + parseInt(dojo.byId("overview").style.height) + 10 + "px";

}
var SelectedItems = new Hash();
var selected_tracks_shown = false;

/**
 * sets the displayed tracks as selected tracks in the faceted browsing
 */
function start_faceted_browsing (currentSelection) {
    SelectedItems = new Hash();
    if(currentSelection) {
        currentSelection = String(currentSelection).split(",");
        for( var i = 0; i < currentSelection.length; i++) {
            SelectedItems.set(currentSelection[i],1);
        }
        var selected = SelectedItems.keys();
    }
    else {
        var selected = [];
    }

    if (selected.size() > 0) {
        if(selected_tracks_shown) {
            selected_tracks_text_shown(selected);
        } else {
            selected_tracks_text_hidden(selected);
        }
    } else {
        selected_tracks_text_none();
    }

    var divs = $$('.submission');
    divs.each (function (d) {
        var id = d.getAttribute('ex:itemid');
        if (SelectedItems.get(id)) {
            d.addClassName('selected');
        } else {
            d.removeClassName('selected');
        }
    });

    // For IE
    var divs2 = document.getElementById('middle_column').children[1].children[0].children[1].children[1].children[0].children;
    for(var i = 0; i < divs2.length; i++) {
        var d = divs2[i].children[0];
        var id = d.getAttribute('ex:itemid');
        if (SelectedItems.get(id)) {
            d.addClassName('selected');
        } else {
            d.removeClassName('selected');
        }
    }
}

/**
 * sets the text at the top of the faceted browsing page
 */
function selected_tracks_text_none (){
    $('selection_count').innerHTML='no tracks selected. <br/><br/>Click on the track name below to display/hide the track.';
}
function selected_tracks_text_hidden (selected){
    $('selection_count').innerHTML  = ' <a href="javascript:clear_all()">clear selected tracks</a><br/><br/>Click on the track name below to display/hide the track.';
}
function selected_tracks_text_shown (selected) {
    $('selection_count').innerHTML  = ' <a href="javascript:clear_all()">clear selected tracks</a><br/><br/>Click on the track name below to display/hide the track.';
}

/**
 * Unselects all tracks/ removes all tracks from the display
 */
function clear_all () {
    SelectedItems = new Hash();
    var divs = $$('.submission');
    divs.each (function (d) {
        var id = d.getAttribute('ex:itemid');
        if (SelectedItems.get(id)) {
            d.addClassName('selected');
        } else {
            d.removeClassName('selected');
        }
    });
    selected_tracks_text_none();
    //$('selection_count').innerHTML = 'no tracks selected';
    parent.b.removeAllTracks();
}

/**
 * add the selected tracks to the displayed tracks 
 */
function load_tracks () {
    var selected = SelectedItems.keys();
    parent.b.removeAllTracks();
    parent.b.showTracks(selected.join(","));
}

/**
 * sets the color of the track in faceted browsing based 
 * on whether it is selected when it appears
 */   
function hilight_items (d) {
    //var divs = $$('.submission');
    if(d) {
        var id = d.getAttribute('ex:itemid');
        if (SelectedItems.get(id)) {
            d.addClassName('selected');
        } else {
            d.removeClassName('selected');
        }
    }
}

/**
 * expands the track node to show information about the track
 */
function show_more_info (arrow) {
    var container = arrow.ancestors().find(
    function(el) { return el.hasClassName('submission')});

    var id = container.getAttribute('ex:itemid');
    var children = container.children;
    arrow.style.display = "none";
    for(var i = 3; i < children.length; i++) {
        children[i].style.display = "block";
    }
}

/**
 * collapses the track node to hide the information about the track
 */
function hide_more_info (arrow) {
    var container = arrow.ancestors().find(
    function(el) { return el.hasClassName('submission')});

    var id = container.getAttribute('ex:itemid');
    var children = container.children;
    children[2].style.display = "";
    for(var i = 3; i < children.length; i++) {
        children[i].style.display = "none";
    }
}

/**
 * select/ unselect the track
 */
function toggle_track (container) {

    var id = container.getAttribute('ex:itemid');

    var turn_on = !container.hasClassName('selected');

    if (turn_on) {
        container.addClassName('selected');
        SelectedItems.set(id,1);
        parent.b.showTracks(id);
    } else {
        container.removeClassName('selected');
        SelectedItems.unset(id);
        parent.dijit.getEnclosingWidget(parent.dojo.byId("label_"+id).firstChild).onClick();
    }
    var selected = SelectedItems.keys();
    if (selected.size() > 0) {
        if(selected_tracks_shown) {
            selected_tracks_text_shown(selected);
        } else {
            selected_tracks_text_hidden(selected);
        }
    } else {
        selected_tracks_text_none();
    }
}
function FeatureTrack(trackMeta, url, refSeq, browserParams) {
    //trackMeta: object with:
    //            key:   display text track name
    //            label: internal track name (no spaces, odd characters)
    //url: URL of the track's JSON file
    //refSeq: object with:
    //         start: refseq start
    //         end:   refseq end
    //browserParams: object with:
    //                changeCallback: function to call once JSON is loaded
    //                trackPadding: distance in px between tracks
    //                baseUrl: base URL for the URL in trackMeta

    Track.call(this, trackMeta.label, trackMeta.key,
               false, browserParams.changeCallback);
    this.fields = {};
    this.features = new NCList();
    this.refSeq = refSeq;
    this.baseUrl = (browserParams.baseUrl ? browserParams.baseUrl : "");
    this.url = url;
    this.trackBaseUrl = (this.baseUrl + url).match(/^.+\//);
    //number of histogram bins per block
    this.numBins = 25;
    this.histLabel = false;
    this.padding = 5;
    this.trackPadding = browserParams.trackPadding;

    this.trackMeta = trackMeta;
    this.load(this.baseUrl + url);

    var thisObj = this;
}

FeatureTrack.prototype = new Track("");

var trackpopupmenu = "";

FeatureTrack.prototype.loadSuccess = function(trackInfo) {
    var startTime = new Date().getTime();
    this.count = trackInfo.featureCount;
    this.fields = {};
    for (var i = 0; i < trackInfo.headers.length; i++) {
	this.fields[trackInfo.headers[i]] = i;
    }
    this.subFields = {};
    if (trackInfo.subfeatureHeaders) {
        for (var i = 0; i < trackInfo.subfeatureHeaders.length; i++) {
            this.subFields[trackInfo.subfeatureHeaders[i]] = i;
        }
    }
    this.features.importExisting(trackInfo.featureNCList,
                                 trackInfo.sublistIndex,
                                 trackInfo.lazyIndex,
                                 this.trackBaseUrl,
                                 trackInfo.lazyfeatureUrlTemplate);
    if (trackInfo.subfeatureArray)
        this.subfeatureArray = new LazyArray(trackInfo.subfeatureArray,
                                             this.trackBaseUrl);

    this.histScale = 4 * (trackInfo.featureCount / this.refSeq.length);
    this.labelScale = 50 * (trackInfo.featureCount / this.refSeq.length);
    this.subfeatureScale = 80 * (trackInfo.featureCount / this.refSeq.length);
    this.className = trackInfo.className;
//    if(window.b.trackClass[this.name]) {
//        this.className = window.b.trackClass[this.name];
//    }
    this.subfeatureClasses = trackInfo.subfeatureClasses;
    this.arrowheadClass = trackInfo.arrowheadClass;
    this.urlTemplate = trackInfo.urlTemplate;
    this.histogramMeta = trackInfo.histogramMeta;
    for (var i = 0; i < this.histogramMeta.length; i++) {
        this.histogramMeta[i].lazyArray =
            new LazyArray(this.histogramMeta[i].arrayParams, this.trackBaseUrl);
    }
    this.histStats = trackInfo.histStats;
    this.histBinBases = trackInfo.histBinBases;

    if (trackInfo.clientConfig) {
        var cc = trackInfo.clientConfig;
        var density = trackInfo.featureCount / this.refSeq.length;
        this.histScale = (cc.histScale ? cc.histScale : 4) * density;
        this.labelScale = (cc.labelScale ? cc.labelScale : 50) * density;
        this.subfeatureScale = (cc.subfeatureScale ? cc.subfeatureScale : 80)
                                   * density;
        if (cc.featureCss) this.featureCss = cc.featureCss;
        if (cc.histCss) this.histCss = cc.histCss;
        if (cc.featureCallback) {
            try {
                this.featureCallback = eval("(" + cc.featureCallback + ")");
            } catch (e) {
                console.log("eval failed for featureCallback on track " + this.name + ": " + cc.featureCallback);
            }
        }
    }

    //console.log((new Date().getTime() - startTime) / 1000);

    var fields = this.fields;
    var featureTrack = this;
    if (! trackInfo.urlTemplate) {
        this.onFeatureClick = function(event) {
            event = event || window.event;
	        if (event.shiftKey) return;
	        var elem = (event.currentTarget || event.srcElement);
            //depending on bubbling, we might get the subfeature here
            //instead of the parent feature
            if (!elem.feature) elem = elem.parentElement;
            if (!elem.feature) return; //shouldn't happen; just bail if it does
            var feat = elem.feature;
            // dojo dialog here
            /* CaPSID EDIT
	        alert("clicked on feature\nstart: " + feat[fields["start"]] +
	              ", end: " + feat[fields["end"]] +
                  ", strand: " + feat[fields["strand"]] +
                  ", label: " + feat[fields["name"]] +
                  ", ID: " + feat[fields["id"]]);
            */
            
            window.open("/capsiddev/mapped/show/" + feat[fields['id']], '_newtab');
        };
        var track = this;

        this.onFeatureRightClick = function(event) {
            if(!event) event = window.event;
            var trackClass = this.className;
            var trackdiv = this.parentNode.parentNode;
            if(trackpopupmenu) {
                trackpopupmenu.parentNode.removeChild(trackpopupmenu);
                trackpopupmenu = "";
            }
            var menu = document.createElement("div");
            trackpopupmenu = menu;
            this.parentNode.appendChild(menu);
            if(!event.layerY) event.layerY = event.offsetY;
            if(!event.layerX) event.layerX = event.offsetX;
            var topPlacement = (event.layerY + parseInt(this.style.top));
            var leftPlacement = (event.layerX + parseInt(this.style.left) * parseInt(this.parentNode.style.width) / 10000 * parseInt(dojo.byId('zoomContainer').style.width));
            menu.style.cssText = "position: absolute; "+
                                 "width: 10px; "+
                                 "height: 10px; "+
                                 "top: "+ topPlacement +"px; "+
                                 "left: "+ leftPlacement +"px; "+
                                 "z-index: 10000;";
            if(event.clientY > document.height - 73) {
                menu.style.top = parseInt(menu.style.top) - 73 + "px";
            }
            if(event.clientX > document.width - 154) {
                menu.style.left = parseInt(menu.style.left) - 154 + "px";
            }
            var popupmenu = document.createElement("ul");
            popupmenu.id = "popupmenu";
            popupmenu.className = "pmenu";
            menu.appendChild(popupmenu);

            var callFillCustomTrackTab = function() {
                window.brwsr.fillCustomizeTrackTab(featureTrack.name, trackClass);
            };

            var customTrack = function(newCssText) {
                var trackName = String(featureTrack.name);
                trackName = trackName.replace(/ /g,"_");
                var cssText;
                var cssTextMinus;
                var cssTextPlus;
                var plusMinusClassText;
                var minusPlusClassText;
                var trackClassName;
                var plus = (trackClass.substring(0,5) == "plus-");
                if(plus) {
                    plusMinusClassText = "."+trackClass+", .minus-"+trackClass.substring(5);
                    minusPlusClassText = ".minus-"+trackClass.substring(5)+", ."+trackClass;
                    trackClassName = trackClass.substring(5);
                }
                else {
                    plusMinusClassText = ".plus-"+trackClass.substring(6)+", ."+trackClass;
                    minusPlusClassText = "."+trackClass+", .plus-"+trackClass.substring(6);
                    trackClassName = trackClass.substring(6);
                }
                var num = window.brwsr.trackClass[featureTrack.name]? (parseInt(window.brwsr.trackClass[featureTrack.name])+1): 0;
                for( var i = 0; i < document.styleSheets[2]['cssRules'].length; i++) {
                    if(document.styleSheets[2]['cssRules'][i].selectorText == ".plus-"+trackClassName) {
                        cssTextPlus = document.styleSheets[2]['cssRules'][i].style.cssText;
                    }
                    if(document.styleSheets[2]['cssRules'][i].selectorText == ".minus-"+trackClassName) {
                        cssTextMinus = document.styleSheets[2]['cssRules'][i].style.cssText;
                    }
                    if(document.styleSheets[2]['cssRules'][i].selectorText == minusPlusClassText) {
                        cssText = document.styleSheets[2]['cssRules'][i].style.cssText;
                    }
                    if(document.styleSheets[2]['cssRules'][i].selectorText == plusMinusClassText) {
                        cssText = document.styleSheets[2]['cssRules'][i].style.cssText;
                    }
                }
                document.styleSheets[2].insertRule('.plus-'+num+trackName+', .minus-'+num+trackName+' { '+cssText+' '+newCssText+'}', document.styleSheets[2].length);
                var prefix = plus? ".plus-": ".minus-";
                document.styleSheets[2].insertRule(".plus-"+num+trackName+' { '+cssTextPlus+';}', document.styleSheets[2].length);
                document.styleSheets[2].insertRule(".minus-"+num+trackName+' { '+cssTextMinus+';}', document.styleSheets[2].length);
                window.brwsr.trackClass[featureTrack.name] = num+trackName; 
                var insertAfterNode = trackdiv.previousSibling;
                dijit.getEnclosingWidget(dojo.byId("label_"+featureTrack.name).firstChild).onClick();
                window.brwsr.displayTrack(featureTrack.name, false, insertAfterNode);
            };

                if(track_customization_on) {
                    var list2 = document.createElement("li");
                    popupmenu.appendChild(list2);

                    var item2 = document.createElement("a");
                    item2.innerHTML = "Customize Track";
                    item2.classsName = "parent";
                    list2.appendChild(item2);
                    item2.onclick = function(event) { callFillCustomTrackTab();};
                }

                var list3 = document.createElement("li");
                popupmenu.appendChild(list3);

                var item3 = document.createElement("a");
                item3.innerHTML = "Close Track";
                item3.classsName = "parent";
                list3.appendChild(item3);
                item3.onclick = function(event) { dijit.getEnclosingWidget(dojo.byId("label_"+featureTrack.name).firstChild).onClick();};

                var list4 = document.createElement("li");
                popupmenu.appendChild(list4);

/*                var item4 = document.createElement("a");
                item4.innerHTML = "Information";
                item4.classsName = "parent";
                list4.appendChild(item4);
                item4.href = "http://www.google.com";
                item4.target = "_blank";
                //item4.onclick = function(event) { track.onClick();};
*/
            event = event || window.event;
            var elem = (event.currentTarget || event.srcElement);
            //depending on bubbling, we might get the subfeature here
            //instead of the parent feature
            if (!elem.feature) elem = elem.parentElement;
            if (!elem.feature) return; //shouldn't happen; just bail if it does
            var feat = elem.feature;

            var xmlhttp;
            if(window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
                xmlhttp = new XMLHttpRequest();
            }
            else { // code for IE6, IE5
                xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
            }
            xmlhttp.onreadystatechange=function() {
                if (xmlhttp.readyState==4 && xmlhttp.status==200){
                   list4.innerHTML = xmlhttp.responseText;
                }
            }
            xmlhttp.open("GET", window.b.popUpUrl + 
                                "?start=" + feat[fields["start"]] +
                                "&end=" + feat[fields["end"]] +
                                "&strand=" + feat[fields["strand"]] +
                                "&label=" + feat[fields["name"]] +
                                "&id=" + feat[fields["id"]]+
                                "&track_name="+featureTrack.name, true);

            xmlhttp.send();

            /*var items = ["Change track height", "Change track color"];
            var itemoptions = [["height","5px","8px","10px","15px"], ["background","blue","purple","red","green", "yellow"]];

            for(var x = 0; x < items.length; x++ ) {
                var list = document.createElement("li");
                popupmenu.appendChild(list);

                var item = document.createElement("a");
                item.innerHTML = items[x];
                item.classsName = "parent";
                list.appendChild(item);

                var optionList = document.createElement("ul");
                list.appendChild(optionList);

                var options = itemoptions[x];
                var attribute = options[0];
                for(var n = 1; n < options.length; n++) {
                    var link = document.createElement("a");
                    var attr = document.createElement("div");
                    attr.style.cssText = "display: none";
                    attr.innerHTML = attribute;
                    var val = document.createElement("div");
                    val.style.cssText = "display: none";
                    val.innerHTML = options[n];
                    link.onclick = function(event) {customTrack(this.children[0].innerHTML+": "+ this.children[1].innerHTML+";"); };
                    link.innerHTML = options[n];
                    link.appendChild(attr);
                    link.appendChild(val);
                    var node = document.createElement("li");
                    optionList.appendChild(node);
                    node.appendChild(link);
                }
            }*/
            dojo.stopEvent(event);
        };
        document.body.onclick = function(event) {
            if(trackpopupmenu) {
                trackpopupmenu.parentNode.removeChild(trackpopupmenu);
                trackpopupmenu = "";
            }
        };
    }

    this.setLoaded();
};

FeatureTrack.prototype.setViewInfo = function(genomeView, numBlocks,
                                              trackDiv, labelDiv,
                                              widthPct, widthPx, scale) {
    Track.prototype.setViewInfo.apply(this, [genomeView, numBlocks,
                                             trackDiv, labelDiv,
                                             widthPct, widthPx, scale]);
    this.setLabel(this.key);
};

FeatureTrack.prototype.fillHist = function(blockIndex, block,
                                           leftBase, rightBase,
                                           stripeWidth) {
    // bases in each histogram bin that we're currently rendering
    var bpPerBin = (rightBase - leftBase) / this.numBins;
    var pxPerCount = 2;
    var logScale = false;
    for (var i = 0; i < this.histStats.length; i++) {
        if (this.histStats[i].bases >= bpPerBin) {
            //console.log("bpPerBin: " + bpPerBin + ", histStats bases: " + this.histStats[i].bases + ", mean/max: " + (this.histStats[i].mean / this.histStats[i].max));
            logScale = ((this.histStats[i].mean / this.histStats[i].max) < .01);
            pxPerCount = 100 / (logScale
                                ? Math.log(this.histStats[i].max)
                                : this.histStats[i].max);
            break;
        }
    }
    var track = this;
    var makeHistBlock = function(hist) {
        var maxBin = 0;
        for (var bin = 0; bin < track.numBins; bin++) {
            if (typeof hist[bin] == 'number' && isFinite(hist[bin])) {
                maxBin = Math.max(maxBin, hist[bin]);
            }
        }
        var binDiv;
        for (var bin = 0; bin < track.numBins; bin++) {
            if (!(typeof hist[bin] == 'number' && isFinite(hist[bin])))
                continue;
            binDiv = document.createElement("div");
	    binDiv.className = track.className + "-hist";;
            binDiv.style.cssText =
                "left: " + ((bin / track.numBins) * 100) + "%; "
                + "height: "
                + (pxPerCount * (logScale ? Math.log(hist[bin]) : hist[bin]))
                + "px;"
                + "bottom: " + track.trackPadding + "px;"
                + "width: " + (((1 / track.numBins) * 100) - (100 / stripeWidth)) + "%;"
                + (track.histCss ? track.histCss : "");
            if (Util.is_ie6) binDiv.appendChild(document.createComment());
            block.appendChild(binDiv);
        }

        track.heightUpdate(pxPerCount * (logScale ? Math.log(maxBin) : maxBin),
                           blockIndex);
    };

    // The histogramMeta array describes multiple levels of histogram detail,
    // going from the finest (smallest number of bases per bin) to the
    // coarsest (largest number of bases per bin).
    // We want to use coarsest histogramMeta that's at least as fine as the
    // one we're currently rendering.
    // TODO: take into account that the histogramMeta chosen here might not
    // fit neatly into the current histogram (e.g., if the current histogram
    // is at 50,000 bases/bin, and we have server histograms at 20,000
    // and 2,000 bases/bin, then we should choose the 2,000 histogramMeta
    // rather than the 20,000)
    var histogramMeta = this.histogramMeta[0];
    for (var i = 0; i < this.histogramMeta.length; i++) {
        if (bpPerBin >= this.histogramMeta[i].basesPerBin)
            histogramMeta = this.histogramMeta[i];
    }

    // number of bins in the server-supplied histogram for each current bin
    var binCount = bpPerBin / histogramMeta.basesPerBin;
    // if the server-supplied histogram fits neatly into our current histogram,
    if ((binCount > .9)
        &&
        (Math.abs(binCount - Math.round(binCount)) < .0001)) {
        // we can use the server-supplied counts
        var firstServerBin = Math.floor(leftBase / histogramMeta.basesPerBin);
        binCount = Math.round(binCount);
        var histogram = [];
        for (var bin = 0; bin < this.numBins; bin++)
            histogram[bin] = 0;

        histogramMeta.lazyArray.range(
            firstServerBin,
            firstServerBin + (binCount * this.numBins),
            function(i, val) {
                // this will count features that span the boundaries of
                // the original histogram multiple times, so it's not
                // perfectly quantitative.  Hopefully it's still useful, though.
                histogram[Math.floor((i - firstServerBin) / binCount)] += val;
            },
            function() {
                makeHistBlock(histogram);
            }
        );
    } else {
        // make our own counts
        this.features.histogram(leftBase, rightBase,
                                this.numBins, makeHistBlock);
    }
};

FeatureTrack.prototype.endZoom = function(destScale, destBlockBases) {
    if (destScale < this.histScale) {
        this.setLabel(this.key + "<br>per " + Math.round(destBlockBases / this.numBins) + "bp");
    } else {
        this.setLabel(this.key);
    }
    this.clear();
};

FeatureTrack.prototype.fillBlock = function(blockIndex, block,
                                            leftBlock, rightBlock,
                                            leftBase, rightBase,
                                            scale, stripeWidth,
                                            containerStart, containerEnd) {
    //console.log("scale: %d, histScale: %d", scale, this.histScale);
    if (scale < this.histScale) {
	this.fillHist(blockIndex, block, leftBase, rightBase, stripeWidth,
                      containerStart, containerEnd);
    } else {
	this.fillFeatures(blockIndex, block, leftBlock, rightBlock,
                          leftBase, rightBase, scale,
                          containerStart, containerEnd);
    }
};

FeatureTrack.prototype.cleanupBlock = function(block) {
    if (block && block.featureLayout) block.featureLayout.cleanup();
};

FeatureTrack.prototype.transfer = function(sourceBlock, destBlock, scale,
                                           containerStart, containerEnd) {
    //transfer(sourceBlock, destBlock) is called when sourceBlock gets deleted.
    //Any child features of sourceBlock that extend onto destBlock should get
    //moved onto destBlock.

    if (!(sourceBlock && destBlock)) return;
    if (!sourceBlock.featureLayout) return;

    var destLeft = destBlock.startBase;
    var destRight = destBlock.endBase;
    var blockWidth = destRight - destLeft;
    var sourceSlot;

    var overlaps = (sourceBlock.startBase < destBlock.startBase)
                       ? sourceBlock.featureLayout.rightOverlaps
                       : sourceBlock.featureLayout.leftOverlaps;

    for (var i = 0; i < overlaps.length; i++) {
	//if the feature overlaps destBlock,
	//move to destBlock & re-position
	sourceSlot = sourceBlock.featureNodes[overlaps[i].id];
	if (sourceSlot && ("label" in sourceSlot)) {
            sourceSlot.label.parentNode.removeChild(sourceSlot.label);
	}
	if (sourceSlot && sourceSlot.feature) {
	    if ((sourceSlot.layoutEnd > destLeft)
		&& (sourceSlot.feature[this.fields["start"]] < destRight)) {

                sourceBlock.removeChild(sourceSlot);
                delete sourceBlock.featureNodes[overlaps[i].id];

                var featDiv =
                    this.renderFeature(sourceSlot.feature, overlaps[i].id,
                                   destBlock, scale,
                                   containerStart, containerEnd);
                destBlock.appendChild(featDiv);
            }
        }
    }
};

FeatureTrack.prototype.fillFeatures = function(blockIndex, block,
                                               leftBlock, rightBlock,
                                               leftBase, rightBase, scale,
                                               containerStart, containerEnd) {
    //arguments:
    //block: div to be filled with info
    //leftBlock: div to the left of the block to be filled
    //rightBlock: div to the right of the block to be filled
    //leftBase: starting base of the block
    //rightBase: ending base of the block
    //scale: pixels per base at the current zoom level
    //containerStart: don't make HTML elements extend further left than this
    //containerEnd: don't make HTML elements extend further right than this
    //0-based

    var layouter = new Layout(leftBase, rightBase);
    block.featureLayout = layouter;
    block.featureNodes = {};
    block.style.backgroundColor = "#ddd";

    //are we filling right-to-left (true) or left-to-right (false)?
    var goLeft = false;
    if (leftBlock && leftBlock.featureLayout) {
        leftBlock.featureLayout.setRightLayout(layouter);
        layouter.setLeftLayout(leftBlock.featureLayout);
    }
    if (rightBlock && rightBlock.featureLayout) {
        rightBlock.featureLayout.setLeftLayout(layouter);
        layouter.setRightLayout(rightBlock.featureLayout);
        goLeft = true;
    }

    //determine the glyph height, arrowhead width, label text dimensions, etc.
    if (!this.haveMeasurements) {
        this.measureStyles();
        this.haveMeasurements = true;
    }

    var curTrack = this;
    var featCallback = function(feature, path) {
        //uniqueId is a stringification of the path in the NCList where
        //the feature lives; it's unique across the top-level NCList
        //(the top-level NCList covers a track/chromosome combination)
        var uniqueId = path.join(",");
        //console.log("ID " + uniqueId + (layouter.hasSeen(uniqueId) ? " (seen)" : " (new)"));
        if (layouter.hasSeen(uniqueId)) {
            //console.log("this layouter has seen " + uniqueId);
            return;
        }
        var featDiv =
            curTrack.renderFeature(feature, uniqueId, block, scale,
                                   containerStart, containerEnd);
        block.appendChild(featDiv);
    };

    var startBase = goLeft ? rightBase : leftBase;
    var endBase = goLeft ? leftBase : rightBase;


    this.features.iterate(startBase, endBase, featCallback,
                          function () {
                              block.style.backgroundColor = "";
                              curTrack.heightUpdate(layouter.totalHeight,
                                                    blockIndex);
                          });
};

FeatureTrack.prototype.measureStyles = function() {
    //determine dimensions of labels (height, per-character width)
    var heightTest = document.createElement("div");
    heightTest.className = "feature-label";
    heightTest.style.height = "auto";
    heightTest.style.visibility = "hidden";
    heightTest.appendChild(document.createTextNode("1234567890"));
    document.body.appendChild(heightTest);
    this.nameHeight = heightTest.clientHeight;
    this.nameWidth = heightTest.clientWidth / 10;
    document.body.removeChild(heightTest);

    //measure the height of glyphs
    var glyphBox;
    heightTest = document.createElement("div");
    //cover all the bases: stranded or not, phase or not
    heightTest.className =
        this.className
        + " plus-" + this.className
        + " plus-" + this.className + "1";
    if (this.featureCss) heightTest.style.cssText = this.featureCss;
    heightTest.style.visibility = "hidden";
    if (Util.is_ie6) heightTest.appendChild(document.createComment("foo"));
    document.body.appendChild(heightTest);
    glyphBox = dojo.marginBox(heightTest);
    this.glyphHeight = Math.round(glyphBox.h + 2);
    this.padding += glyphBox.w;
    document.body.removeChild(heightTest);

    //determine the width of the arrowhead, if any
    if (this.arrowheadClass) {
        var ah = document.createElement("div");
        ah.className = "plus-" + this.arrowheadClass;
        if (Util.is_ie6) ah.appendChild(document.createComment("foo"));
        document.body.appendChild(ah);
        glyphBox = dojo.marginBox(ah);
        this.plusArrowWidth = glyphBox.w;
        ah.className = "minus-" + this.arrowheadClass;
        glyphBox = dojo.marginBox(ah);
        this.minusArrowWidth = glyphBox.w;
        document.body.removeChild(ah);
    }
};

FeatureTrack.prototype.renderFeature = function(feature, uniqueId, block, scale,
                                                containerStart, containerEnd) {
    var fields = this.fields;
    //featureStart and featureEnd indicate how far left or right
    //the feature extends in bp space, including labels
    //and arrowheads if applicable
    var featureEnd = feature[fields["end"]];
    var featureStart = feature[fields["start"]];
    if (this.arrowheadClass) {
        switch (feature[fields["strand"]]) {
        case 1:
            featureEnd   += (this.plusArrowWidth / scale); break;
        case -1:
            featureStart -= (this.minusArrowWidth / scale); break;
        }
    }

    // if the label extends beyond the feature, use the
    // label end position as the end position for layout
    if (scale > this.labelScale) {
	featureEnd = Math.max(featureEnd,
                              feature[fields["start"]]
                              + (((fields["name"] && feature[fields["name"]])
				  ? feature[fields["name"]].length : 0)
				 * (this.nameWidth / scale)));
    }
    featureEnd += Math.max(1, this.padding / scale);

    var levelHeight =
        this.glyphHeight + 2 +
        (
            (fields["name"] && (scale > this.labelScale)) ? this.nameHeight : 0
        );

    var top = block.featureLayout.addRect(uniqueId,
                                          featureStart,
                                          featureEnd,
                                          levelHeight);

    var featDiv;
    var featUrl = this.featureUrl(feature);
    if (featUrl) {
        featDiv = document.createElement("a");
        featDiv.href = featUrl;
        featDiv.target = "_new";
    } else {
        featDiv = document.createElement("div");
        featDiv.onclick = this.onFeatureClick;
        featDiv.oncontextmenu = this.onFeatureRightClick;
    }
    featDiv.feature = feature;
    featDiv.layoutEnd = featureEnd;

    block.featureNodes[uniqueId] = featDiv;

    switch (feature[fields["strand"]]) {
    case 1:
        featDiv.className = "plus-" + this.className; break;
    case 0:
    case null:
    case undefined:
        featDiv.className = this.className; break;
    case -1:
        featDiv.className = "minus-" + this.className; break;
    }

    if ((fields["phase"] !== undefined) && (feature[fields["phase"]] !== null))
        featDiv.className = featDiv.className + feature[fields["phase"]];

    // Since some browsers don't deal well with the situation where
    // the feature goes way, way offscreen, we truncate the feature
    // to exist betwen containerStart and containerEnd.
    // To make sure the truncated end of the feature never gets shown,
    // we'll destroy and re-create the feature (with updated truncated
    // boundaries) in the transfer method.
    var displayStart = Math.max(feature[fields["start"]],
                                containerStart);
    var displayEnd = Math.min(feature[fields["end"]],
                              containerEnd);
    var blockWidth = block.endBase - block.startBase;
    featDiv.style.cssText =
        "left:" + (100 * (displayStart - block.startBase) / blockWidth) + "%;"
        + "top:" + top + "px;"
        + " width:" + (100 * ((displayEnd - displayStart) / blockWidth)) + "%;"
        + (this.featureCss ? this.featureCss : "");

    if (this.featureCallback) this.featureCallback(feature, fields, featDiv);

    if (this.arrowheadClass) {
        var ah = document.createElement("div");
        switch (feature[fields["strand"]]) {
        case 1:
            ah.className = "plus-" + this.arrowheadClass;
            ah.style.cssText = "left: 100%; top: 0px;";
            featDiv.appendChild(ah);
            break;
        case -1:
            ah.className = "minus-" + this.arrowheadClass;
            ah.style.cssText =
                "left: " + (-this.minusArrowWidth) + "px; top: 0px;";
            featDiv.appendChild(ah);
            break;
        }
    }

    if ((scale > this.labelScale)
        && fields["name"]
        && feature[fields["name"]]) {

        var labelDiv;
        if (featUrl) {
            labelDiv = document.createElement("a");
            labelDiv.href = featUrl;
            labelDiv.target = featDiv.target;
        } else {
            labelDiv = document.createElement("div");
	    labelDiv.onclick = this.onFeatureClick;
        }

        labelDiv.className = "feature-label";
        labelDiv.appendChild(document.createTextNode(feature[fields["name"]]));
        labelDiv.style.cssText =
            "left: "
            + (100 * (feature[fields["start"]] - block.startBase) / blockWidth)
            + "%; "
            + "top: " + (top + this.glyphHeight) + "px;";
	featDiv.label = labelDiv;
        labelDiv.feature = feature;
        block.appendChild(labelDiv);
    }

    if (fields["subfeatures"]
        && (scale > this.subfeatureScale)
        && feature[fields["subfeatures"]]
        && feature[fields["subfeatures"]].length > 0) {

        for (var i = 0; i < feature[fields["subfeatures"]].length; i++) {
            this.renderSubfeature(feature, featDiv,
                                  feature[fields["subfeatures"]][i],
                                  displayStart, displayEnd);
        }
    }

    //ie6 doesn't respect the height style if the div is empty
    if (Util.is_ie6) featDiv.appendChild(document.createComment());
    //TODO: handle event-handler-related IE leaks
    return featDiv;
};

FeatureTrack.prototype.featureUrl = function(feature) {
    var urlValid = true;
    var fields = this.fields;
    if (this.urlTemplate) {
        var href = this.urlTemplate.replace(/\{([^}]+)\}/g,
        function(match, group) {
            if(feature[fields[group]] != undefined)
                return feature[fields[group]];
            else
                urlValid = false;
            return 0;
        });
        if(urlValid) return href;
    }
    return undefined;
};

FeatureTrack.prototype.renderSubfeature = function(feature, featDiv, subfeature,
                                                   displayStart, displayEnd) {
    var subStart = subfeature[this.subFields["start"]];
    var subEnd = subfeature[this.subFields["end"]];
    var featLength = displayEnd - displayStart;

    var subDiv = document.createElement("div");

    if (this.subfeatureClasses) {
        var className = this.subfeatureClasses[subfeature[this.subFields["type"]]];
        switch (subfeature[this.subFields["strand"]]) {
        case 1:
            subDiv.className = "plus-" + className; break;
        case 0:
        case null:
        case undefined:
            subDiv.className = className; break;
        case -1:
            subDiv.className = "minus-" + className; break;
        }

    }

    // if the feature has been truncated to where it doesn't cover
    // this subfeature anymore, just skip this subfeature
    if ((subEnd <= displayStart) || (subStart >= displayEnd)) return;

    if (Util.is_ie6) subDiv.appendChild(document.createComment());
    subDiv.style.cssText =
        "left: " + (100 * ((subStart - displayStart) / featLength)) + "%;"
        + "top: 0px;"
        + "width: " + (100 * ((subEnd - subStart) / featLength)) + "%;";
    if (this.featureCallback)
        this.featureCallback(subfeature, this.subFields, subDiv);
    featDiv.appendChild(subDiv);
};

/*

Copyright (c) 2007-2010 The Evolutionary Software Foundation

Created by Mitchell Skinner <mitch_skinner@berkeley.edu>

This package and its accompanying libraries are free software; you can
redistribute it and/or modify it under the terms of the LGPL (either
version 2.1, or at your option, any later version) or the Artistic
License 2.0.  Refer to LICENSE for the full license text.

*/
function Animation(subject, callback, time) {
    //subject: what's being animated
    //callback: function to call at the end of the animation
    //time: time for the animation to run
    if (subject === undefined) return;
    //don't want a zoom and a slide going on at the same time
    if ("animation" in subject) subject.animation.stop();
    this.index = 0;
    this.time = time;
    this.subject = subject;
    this.callback = callback;

    var myAnim = this;
    this.animFunction = function() { myAnim.animate(); };
    // number of milliseconds between frames (e.g., 33ms at 30fps)
    this.animID = setTimeout(this.animFunction, 33);

    this.frames = 0;

    subject.animation = this;
}

Animation.prototype.animate = function () {
    if (this.finished) {
	this.stop();
	return;
    }

    // number of milliseconds between frames (e.g., 33ms at 30fps)
    var nextTimeout = 33;
    var elapsed = 0;
    if (!("startTime" in this)) {
        this.startTime = (new Date()).getTime();
    } else {
        elapsed = (new Date()).getTime() - this.startTime;
        //set the next timeout to be the average of the
        //frame times we've achieved so far.
        //The goal is to avoid overloading the browser
        //and getting a jerky animation.
        nextTimeout = Math.max(33, elapsed / this.frames);
    }

    if (elapsed < this.time) {
        this.step(elapsed / this.time);
        this.frames++;
    } else {
	this.step(1);
        this.finished = true;
	//console.log("final timeout: " + nextTimeout);
    }
    this.animID = setTimeout(this.animFunction, nextTimeout);
};

Animation.prototype.stop = function() {
    clearTimeout(this.animID);
    delete this.subject.animation;
    this.callback(this);
};

function Slider(view, callback, time, distance) {
    Animation.call(this, view, callback, time);
    this.slideStart = view.getX();
    this.slideDistance = distance;
}

Slider.prototype = new Animation();

Slider.prototype.step = function(pos) {
    var newX = (this.slideStart -
                (this.slideDistance *
                 //cos will go from 1 to -1, we want to go from 0 to 1
                 ((-0.5 * Math.cos(pos * Math.PI)) + 0.5))) | 0;

    newX = Math.max(Math.min(this.subject.maxLeft - this.subject.offset, newX),
                         this.subject.minLeft - this.subject.offset);
    this.subject.setX(newX);
};

function Zoomer(scale, toScroll, callback, time, zoomLoc) {
    Animation.call(this, toScroll, callback, time);
    this.toZoom = toScroll.zoomContainer;
    var cWidth = this.toZoom.clientWidth;

    this.initialWidth = cWidth;

    // the container width when zoomFraction is 0
    this.width0 = cWidth * Math.min(1, scale);
    // the container width when zoomFraction is 1
    var width1 = cWidth * Math.max(1, scale);
    this.distance = width1 - this.width0;
    this.zoomingIn = scale > 1;
    //this.zoomLoc = zoomLoc;
    this.center =
        (toScroll.getX() + (toScroll.elem.clientWidth * zoomLoc))
        / toScroll.scrollContainer.clientWidth;

    // initialX and initialLeft can differ when we are scrolling
    // using scrollTop and scrollLeft
    this.initialX = this.subject.getX();
    this.initialLeft = parseInt(this.toZoom.style.left);
};

Zoomer.prototype = new Animation();

Zoomer.prototype.step = function(pos) {
    var zoomFraction = this.zoomingIn ? pos : 1 - pos;
    var newWidth =
        ((zoomFraction * zoomFraction) * this.distance) + this.width0;
    var newLeft = (this.center * this.initialWidth) - (this.center * newWidth);
    this.toZoom.style.width = newWidth + "px";
    this.toZoom.style.left = (this.initialLeft + newLeft) + "px";
    var forceRedraw = this.toZoom.offsetTop;
    this.subject.updateTrackLabels(this.initialX - newLeft);
};

function GenomeView(elem, stripeWidth, refseq, zoomLevel, overviewTrackData) {
    //all coordinates are interbase

    //measure text width for the max zoom level
    var widthTest = document.createElement("div");
    widthTest.className = "sequence";
    widthTest.style.visibility = "hidden";
    var widthText = "12345678901234567890123456789012345678901234567890";
    widthTest.appendChild(document.createTextNode(widthText));
    elem.appendChild(widthTest);
    this.charWidth = widthTest.clientWidth / widthText.length;
    this.seqHeight = widthTest.clientHeight;
    elem.removeChild(widthTest);

    // measure the height of some arbitrary text in whatever font this
    // shows up in (set by an external CSS file)
    var heightTest = document.createElement("div");
    heightTest.className = "pos-label";
    heightTest.style.visibility = "hidden";
    heightTest.appendChild(document.createTextNode("42"));
    elem.appendChild(heightTest);
    this.posHeight = heightTest.clientHeight;
    // Add an arbitrary 50% padding between the position labels and the
    // topmost track
    this.topSpace = 1.5 * this.posHeight;
    elem.removeChild(heightTest);

    //the reference sequence
    this.ref = refseq;
    //current scale, in pixels per bp
    this.pxPerBp = zoomLevel;
    //width, in pixels, of the vertical stripes
    this.stripeWidth = stripeWidth;
    //the page element that the GenomeView lives in
    this.elem = elem;

    // the scrollContainer is the element that changes position
    // when the user scrolls
    this.scrollContainer = document.createElement("div");
    this.scrollContainer.id = "container";
    this.scrollContainer.style.cssText =
        "position: absolute; left: 0px; top: 0px;";
    elem.appendChild(this.scrollContainer);

    // we have a separate zoomContainer as a child of the scrollContainer.
    // they used to be the same element, but making zoomContainer separate
    // enables it to be narrower than this.elem.
    this.zoomContainer = document.createElement("div");
    this.zoomContainer.id = "zoomContainer";
    this.zoomContainer.style.cssText =
        "position: absolute; left: 0px; top: 0px; height: 100%;";
    this.scrollContainer.appendChild(this.zoomContainer);

    //width, in pixels of the "regular" (not min or max zoom) stripe
    this.regularStripe = stripeWidth;
    //width, in pixels, of stripes at full zoom (based on the sequence
    //character width)
    //The number of characters per stripe is somewhat arbitrarily set
    //at stripeWidth / 10
    this.fullZoomStripe = this.charWidth * (stripeWidth / 10);

    this.overview = dojo.byId("overview");
    this.overviewBox = dojo.marginBox(this.overview);

    this.tracks = [];
    this.uiTracks = [];
    this.trackIndices = {};

    //set up size state (zoom levels, stripe percentage, etc.)
    this.sizeInit();

    //distance, in pixels, from the beginning of the reference sequence
    //to the beginning of the first active stripe
    //  should always be a multiple of stripeWidth
    this.offset = 0;
    //largest value for the sum of this.offset and this.getX()
    //this prevents us from scrolling off the right end of the ref seq
    this.maxLeft = this.bpToPx(this.ref.end) - this.dim.width;
    //smallest value for the sum of this.offset and this.getX()
    //this prevents us from scrolling off the left end of the ref seq
    this.minLeft = this.bpToPx(this.ref.start);
    //distance, in pixels, between each track
    this.trackPadding = 20;
    //extra margin to draw around the visible area, in multiples of the visible area
    //0: draw only the visible area; 0.1: draw an extra 10% around the visible area, etc.
    this.drawMargin = 0.2;
    //slide distance (pixels) * slideTimeMultiple + 200 = milliseconds for slide
    //1=1 pixel per millisecond average slide speed, larger numbers are slower
    this.slideTimeMultiple = 0.8;
    this.trackHeights = [];
    this.trackTops = [];
    this.trackLabels = [];
    this.waitElems = [dojo.byId("moveLeft"), dojo.byId("moveRight"),
                      dojo.byId("zoomIn"), dojo.byId("zoomOut"),
                      dojo.byId("bigZoomIn"), dojo.byId("bigZoomOut"),
                      document.body, elem];
    this.prevCursors = [];
    this.locationThumb = document.createElement("div");
    this.locationThumb.className = "locationThumb";
    this.overview.appendChild(this.locationThumb);
    this.locationThumbMover = new dojo.dnd.move.parentConstrainedMoveable(this.locationThumb, {area: "margin", within: true});
    dojo.connect(this.locationThumbMover, "onMoveStop", this, "thumbMoved");

    var view = this;

    var cssScroll = dojo.isIE;

    if (cssScroll) {
        view.x = -parseInt(view.scrollContainer.style.left);
        view.y = -parseInt(view.scrollContainer.style.top);
        view.getX = function() {
            return view.x;
        };
        view.getY = function() {
            return view.y;
        };
        view.getPosition = function() {
	    return { x: view.x, y: view.y };
        };
        view.rawSetX = function(x) {
            view.scrollContainer.style.left = -x + "px"; view.x = x;
        };
        view.setX = function(x) {
	    view.x = Math.max(Math.min(view.maxLeft - view.offset, x),
                              view.minLeft - view.offset);
            view.x = Math.round(view.x);
	    view.updateTrackLabels(view.x);
	    view.showFine();
            view.scrollContainer.style.left = -view.x + "px";
        };
        view.rawSetY = function(y) {
            view.scrollContainer.style.top = -y + "px"; view.y = y;
        };
        view.setY = function(y) {
            view.y = Math.min((y < 0 ? 0 : y),
                              view.containerHeight
                              - view.dim.height);
            view.y = Math.round(view.y);
            view.updatePosLabels(view.y);
            view.scrollContainer.style.top = -view.y + "px";
        };
        view.rawSetPosition = function(pos) {
            view.scrollContainer.style.left = -pos.x + "px";
            view.scrollContainer.style.top = -pos.y + "px";
        };
        view.setPosition = function(pos) {
            view.x = Math.max(Math.min(view.maxLeft - view.offset, pos.x),
                              view.minLeft - view.offset);
            view.y = Math.min((pos.y < 0 ? 0 : pos.y),
                              view.containerHeight - view.dim.height);
            view.x = Math.round(view.x);
            view.y = Math.round(view.y);

            view.updateTrackLabels(view.x);
            view.updatePosLabels(view.y);
	    view.showFine();

            view.scrollContainer.style.left = -view.x + "px";
            view.scrollContainer.style.top = -view.y + "px";
        };
    } else {
	view.x = view.elem.scrollLeft;
	view.y = view.elem.scrollTop;
        view.getX = function() {
	    return view.x;
	};
        view.getY = function() {
	    return view.y;
	};
        view.getPosition = function() {
	    return { x: view.x, y: view.y };
        };
        view.rawSetX = function(x) {
            view.elem.scrollLeft = x; view.x = x;
        };
        view.setX = function(x) {
	    view.x = Math.max(Math.min(view.maxLeft - view.offset, x),
			      view.minLeft - view.offset);
            view.x = Math.round(view.x);
	    view.updateTrackLabels(view.x);
	    view.showFine();

            view.elem.scrollLeft = view.x;
        };
        view.rawSetY = function(y) {
            view.elem.scrollTop = y; view.y = y;
        };
        view.rawSetPosition = function(pos) {
            view.elem.scrollLeft = pos.x; view.x = pos.x;
            view.elem.scrollTop = pos.y; view.y = pos.y;
        };

        view.setY = function(y) {
            view.y = Math.min((y < 0 ? 0 : y),
                              view.containerHeight
                              - view.dim.height);
            view.y = Math.round(view.y);
            view.updatePosLabels(view.y);
            view.elem.scrollTop = view.y;
        };
        view.setPosition = function(pos) {
            view.x = Math.max(Math.min(view.maxLeft - view.offset, pos.x),
                              view.minLeft - view.offset);
            view.y = Math.min((pos.y < 0 ? 0 : pos.y),
                              view.containerHeight - view.dim.height);
            view.x = Math.round(view.x);
            view.y = Math.round(view.y);

            view.updateTrackLabels(view.x);
            view.updatePosLabels(view.y);
	    view.showFine();

            view.elem.scrollLeft = view.x;
            view.elem.scrollTop = view.y;
	};
    }

    view.dragEnd = function(event) {
	dojo.forEach(view.dragEventHandles, dojo.disconnect);

	view.dragging = false;
        //view.elem.style.cursor = "url(\"openhand.cur\"), move";
        document.body.style.cursor = "default";
        dojo.stopEvent(event);
	view.showCoarse();

        view.scrollUpdate();
	view.showVisibleBlocks(true);
    };

    var htmlNode = document.body.parentNode;
    var bodyNode = document.body;
    //stop the drag if we mouse out of the view
    view.checkDragOut = function(event) {
        if (!(event.relatedTarget || event.toElement)
            || (htmlNode === (event.relatedTarget || event.toElement))
            || (bodyNode === (event.relatedTarget || event.toElement)))
            view.dragEnd(event);
    };

    view.dragMove = function(event) {
	view.setPosition({
		x: view.winStartPos.x - (event.clientX - view.dragStartPos.x),
		y: view.winStartPos.y - (event.clientY - view.dragStartPos.y)
            });
        dojo.stopEvent(event);
    };

    view.mouseDown = function(event) {
        if ("animation" in view) {
            if (view.animation instanceof Zoomer) {
                dojo.stopEvent(event);
                return;

            } else {
                view.animation.stop();
            }
        }
	if (Util.isRightButton(event)) return;

        if (elastic_zoom_on && (event.clientY < parseInt(dojo.byId('static_track').style.height) + parseInt(dojo.byId('dijit_layout_ContentPane_1').style.top))) {
            dojo.byId('bandZoom').style.display = "block";
            dojo.byId('dynamicZoom').style.left = event.clientX -parseInt(dojo.byId('dijit_layout_ContentPane_0').style.left) + "px";
            dojo.byId('dynamicZoomStart').style.left = event.clientX -parseInt(dojo.byId('dijit_layout_ContentPane_0').style.left) + "px";
            view.zoomMover.onMoveStart( new dojo.dnd.Mover(view.zoomMover.node, event, view.zoomMover));
            return;
        }
        dojo.stopEvent(event);
	if (event.shiftKey || event.ctrlKey) return;
	view.dragEventHandles =
	    [
	     dojo.connect(document.body, "mouseup", view.dragEnd),
	     dojo.connect(document.body, "mousemove", view.dragMove),
	     dojo.connect(document.body, "mouseout", view.checkDragOut)
	     ];

	view.dragging = true;
	view.dragStartPos = {x: event.clientX,
			     y: event.clientY};
	view.winStartPos = view.getPosition();

	//document.body.style.cursor = "url(\"closedhand.cur\"), move";
	//view.elem.style.cursor = "url(\"closedhand.cur\"), move";
    };

    dojo.connect(view.elem, "mousedown", view.mouseDown);

    dojo.connect(view.elem, "dblclick", function(event) {
	    if (view.dragging) return;
	    if ("animation" in view) return;
	    var zoomLoc = (event.pageX - dojo.coords(view.elem, true).x) / view.dim.width;
	    if (event.shiftKey) {
		view.zoomOut(event, zoomLoc, 2);
	    } else {
		view.zoomIn(event, zoomLoc, 2);
	    }
	    dojo.stopEvent(event);
	});

    view.afterSlide = function() {
	view.showCoarse();
        view.scrollUpdate();
	view.showVisibleBlocks(true);
    };

    view.zoomCallback = function() { view.zoomUpdate(); };

    var wheelScrollTimeout = null;
    var wheelScrollUpdate = function() {
	view.showVisibleBlocks(true);
	wheelScrollTimeout = null;
    };

    view.wheelScroll = function(e) {
	var oldY = view.getY();
        // arbitrary 60 pixel vertical movement per scroll wheel event
	var newY = Math.min(Math.max(0, oldY - 60 * Util.wheel(e)),
			    view.containerHeight - view.dim.height);
	view.setY(newY);

	//the timeout is so that we don't have to run showVisibleBlocks
	//for every scroll wheel click (we just wait until so many ms
	//after the last one).
	if (wheelScrollTimeout)
	    clearTimeout(wheelScrollTimeout);
        // 100 milliseconds since the last scroll event is an arbitrary
        // cutoff for deciding when the user is done scrolling
        // (set by a bit of experimentation)
	wheelScrollTimeout = setTimeout(wheelScrollUpdate, 100);
	dojo.stopEvent(e);
    };

    dojo.connect(view.scrollContainer, "mousewheel",
                 view.wheelScroll, false);

    dojo.connect(view.scrollContainer, "DOMMouseScroll",
                 view.wheelScroll, false);

    var trackDiv = document.createElement("div");
    trackDiv.className = "track";
    trackDiv.style.height = this.posHeight + "px";
    trackDiv.id = "static_track";
    this.staticTrack = new StaticTrack("static_track", "pos-label", this.posHeight);
    this.staticTrack.setViewInfo(function(height) {}, this.stripeCount,
                                 trackDiv, undefined, this.stripePercent,
                                 this.stripeWidth, this.pxPerBp);
    this.zoomContainer.appendChild(trackDiv);
    this.waitElems.push(trackDiv);

    var gridTrackDiv = document.createElement("div");
    gridTrackDiv.className = "track";
    gridTrackDiv.style.cssText = "top: 0px; height: 100%;";
    gridTrackDiv.id = "gridtrack";
    var gridTrack = new GridTrack("gridtrack");
    gridTrack.setViewInfo(function(height) {}, this.stripeCount,
                          gridTrackDiv, undefined, this.stripePercent,
                          this.stripeWidth, this.pxPerBp);
    this.zoomContainer.appendChild(gridTrackDiv);

    this.uiTracks = [this.staticTrack, gridTrack];

    dojo.forEach(this.uiTracks, function(track) {
        track.showRange(0, this.stripeCount - 1,
                        Math.round(this.pxToBp(this.offset)),
                        Math.round(this.stripeWidth / this.pxPerBp),
                        this.pxPerBp);
    }, this);

    this.zoomContainer.style.paddingTop = this.topSpace + "px";

    this.ci = [];
    for(var i = 0; i < overviewTrackData.length; i++) {
        var track = overviewTrackData[i];
        var url = track.url.replace(/\{([^}]+)\}/g, refseq.name);
        var klass = eval(track.type);
        this.ci[i] = new klass(refseq,url);
    }
    this.overviewTrackData = overviewTrackData;

    this.addOverviewTrack(new StaticTrack("overview_loc_track", "overview-pos", this.overviewPosHeight));

    //document.body.style.cursor = "url(\"closedhand.cur\")";
    document.body.style.cursor = "default";

    this.showFine();
    this.showCoarse();
            //elem.appendChild(MoveTest);
}

/* moves the view by (distance times the width of the view) pixels */
GenomeView.prototype.slide = function(distance) {
    if (this.animation) this.animation.stop();
    this.trimVertical();
    // slide for an amount of time that's a function of the distance being
    // traveled plus an arbitrary extra 200 milliseconds so that
    // short slides aren't too fast (200 chosen by experimentation)
    new Slider(this,
               this.afterSlide,
               Math.abs(distance) * this.dim.width * this.slideTimeMultiple + 200,
               distance * this.dim.width);
};

GenomeView.prototype.highlightRegions = function(regionList) {
};

GenomeView.prototype.resetChromBands = function() {
    for(var i = 0; i < this.ci.length; i++) {
        this.ci[i].resetBands();
    }
}

GenomeView.prototype.setLocation = function(refseq, startbp, endbp) {
    if (startbp === undefined) startbp = this.minVisible();
    if (endbp === undefined) endbp = this.maxVisible();
    if ((startbp < refseq.start) || (startbp > refseq.end))
        startbp = refseq.start;
    if ((endbp < refseq.start) || (endbp > refseq.end))
        endbp = refseq.end;

    if (this.ref != refseq) {
	this.ref = refseq;

        for(var i = 0; i < this.ci.length; i++) {
            this.ci[i].clear();
        }
        this.ci = [];

	var removeTrack = function(track) {
            if (track.div && track.div.parentNode)
                track.div.parentNode.removeChild(track.div);
	};
	dojo.forEach(this.tracks, removeTrack);
        dojo.forEach(this.uiTracks, function(track) { track.clear(); });
	this.overviewTrackIterate2(removeTrack);

        var overviewTrackData = this.overviewTrackData;
        for(var i = 0; i < overviewTrackData.length; i++) {
            var track = overviewTrackData[i];
            var url = track.url.replace(/\{([^}]+)\}/g, refseq.name);
            var klass = eval(track.type);
            this.ci[i] = new klass(refseq, url);
        }

	this.addOverviewTrack(new StaticTrack("overview_loc_track", "overview-pos", this.overviewPosHeight));
        this.sizeInit();
        this.setY(0);
        this.containerHeight = this.topSpace;

    }
    this.pxPerBp = Math.min(this.dim.width / (endbp - startbp), this.charWidth);
    this.curZoom = Util.findNearest(this.zoomLevels, this.pxPerBp);
    if (Math.abs(this.pxPerBp - this.zoomLevels[this.zoomLevels.length - 1]) < 0.2) {
        //the cookie-saved location is in round bases, so if the saved
        //location was at the highest zoom level, the new zoom level probably
        //won't be exactly at the highest zoom (which is necessary to trigger
        //the sequence track), so we nudge the zoom level to be exactly at
        //the highest level if it's close.
        //Exactly how close is arbitrary; 0.2 was chosen to be close
        //enough that people wouldn't notice if we fudged that much.
        console.log("nudging zoom level from %d to %d", this.pxPerBp, this.zoomLevels[this.zoomLevels.length - 1]);
        this.pxPerBp = this.zoomLevels[this.zoomLevels.length - 1];
    }
    this.stripeWidth = (this.stripeWidthForZoom(this.curZoom) / this.zoomLevels[this.curZoom]) * this.pxPerBp;

    dojo.forEach(this.uiTracks, function(track) { track.clear(); });
    for (var track = 0; track < this.tracks.length; track++) {
	this.tracks[track].startZoom(this.pxPerBp, startbp, endbp);
	this.tracks[track].endZoom(this.pxPerBp, Math.round(this.stripeWidth / this.pxPerBp));
    }
    this.instantZoomUpdate();
    this.centerAtBase((startbp + endbp) / 2, true);
};

GenomeView.prototype.stripeWidthForZoom = function(zoomLevel) {
    if ((this.zoomLevels.length - 1) == zoomLevel) {
        return this.fullZoomStripe;
    } else if (0 == zoomLevel) {
        return this.minZoomStripe;
    } else {
        return this.regularStripe;
    }
};

GenomeView.prototype.instantZoomUpdate = function() {
    this.scrollContainer.style.width =
        (this.stripeCount * this.stripeWidth) + "px";
    this.zoomContainer.style.width =
        (this.stripeCount * this.stripeWidth) + "px";
    this.maxOffset =
        this.bpToPx(this.ref.end) - this.stripeCount * this.stripeWidth;
    this.maxLeft = this.bpToPx(this.ref.end) - this.dim.width;
    this.minLeft = this.bpToPx(this.ref.start);
};

GenomeView.prototype.centerAtBase = function(base, instantly) {
    base = Math.min(Math.max(base, this.ref.start), this.ref.end);
    if (instantly) {
	var pxDist = this.bpToPx(base);
	var containerWidth = this.stripeCount * this.stripeWidth;
	var stripesLeft = Math.floor((pxDist - (containerWidth / 2)) / this.stripeWidth);
	this.offset = stripesLeft * this.stripeWidth;
	this.setX(pxDist - this.offset - (this.dim.width / 2));
	this.trackIterate(function(track) { track.clear(); });
	this.showVisibleBlocks(true);
        this.showCoarse();
    } else {
	var startbp = this.pxToBp(this.x + this.offset);
	var halfWidth = (this.dim.width / this.pxPerBp) / 2;
	var endbp = startbp + halfWidth + halfWidth;
	var center = startbp + halfWidth;
	if ((base >= (startbp  - halfWidth))
	    && (base <= (endbp + halfWidth))) {
	    //we're moving somewhere nearby, so move smoothly
            if (this.animation) this.animation.stop();
            var distance = (center - base) * this.pxPerBp;
	    this.trimVertical();
            // slide for an amount of time that's a function of the
            // distance being traveled plus an arbitrary extra 200
            // milliseconds so that short slides aren't too fast
            // (200 chosen by experimentation)
            new Slider(this, this.afterSlide,
                       Math.abs(distance) * this.slideTimeMultiple + 200,
		       distance);
	} else {
	    //we're moving far away, move instantly
	    this.centerAtBase(base, true);
	}
    }
};

GenomeView.prototype.minVisible = function() {
    return this.pxToBp(this.x + this.offset);
};

GenomeView.prototype.maxVisible = function() {
    return this.pxToBp(this.x + this.offset + this.dim.width);
};

GenomeView.prototype.showFine = function() {
    this.onFineMove(this.minVisible(), this.maxVisible());
};
GenomeView.prototype.showCoarse = function() {
    this.onCoarseMove(this.minVisible(), this.maxVisible());
};

GenomeView.prototype.onFineMove = function() {};
GenomeView.prototype.onCoarseMove = function() {};

GenomeView.prototype.thumbMoved = function(mover) {
    var pxLeft = parseInt(this.locationThumb.style.left);
    var pxWidth = parseInt(this.locationThumb.style.width);
    var pxCenter = pxLeft + (pxWidth / 2);
    this.centerAtBase(((pxCenter / this.overviewBox.w) * (this.ref.end - this.ref.start)) + this.ref.start);
};

GenomeView.prototype.checkY = function(y) {
    return Math.min((y < 0 ? 0 : y), this.containerHeight - this.dim.height);
};

GenomeView.prototype.updatePosLabels = function(newY) {
    if (newY === undefined) newY = this.getY();
    this.staticTrack.div.style.top = newY + "px";
};

GenomeView.prototype.updateTrackLabels = function(newX) {
    if (newX === undefined) newX = this.getX();
    for (var i = 0; i < this.trackLabels.length; i++)
        this.trackLabels[i].style.left = newX + "px";
};

GenomeView.prototype.showWait = function() {
    var oldCursors = [];
    for (var i = 0; i < this.waitElems.length; i++) {
        oldCursors[i] = this.waitElems[i].style.cursor;
        this.waitElems[i].style.cursor = "wait";
    }
    this.prevCursors.push(oldCursors);
};

GenomeView.prototype.showDone = function() {
    var oldCursors = this.prevCursors.pop();
    for (var i = 0; i < this.waitElems.length; i++) {
        this.waitElems[i].style.cursor = oldCursors[i];
    }
};

GenomeView.prototype.pxToBp = function(pixels) {
    return pixels / this.pxPerBp;
};

GenomeView.prototype.bpToPx = function(bp) {
    return bp * this.pxPerBp;
};

GenomeView.prototype.sizeInit = function() {
    this.dim = {width: this.elem.clientWidth,
                height: this.elem.clientHeight};
    this.overviewBox = dojo.marginBox(this.overview);

    //scale values, in pixels per bp, for all zoom levels
    this.zoomLevels = [1/500000, 1/200000, 1/100000, 1/50000, 1/20000, 1/10000, 1/5000, 1/2000, 1/1000, 1/500, 1/200, 1/100, 1/50, 1/20, 1/10, 1/5, 1/2, 1, 2, 5, this.charWidth];
    //make sure we don't zoom out too far
    while (((this.ref.end - this.ref.start) * this.zoomLevels[0])
           < this.dim.width) {
        this.zoomLevels.shift();
    }
    this.zoomLevels.unshift(this.dim.width / (this.ref.end - this.ref.start));

    //width, in pixels, of stripes at min zoom (so the view covers
    //the whole ref seq)
    this.minZoomStripe = this.regularStripe * (this.zoomLevels[0] / this.zoomLevels[1]);

    this.curZoom = 0;
    while (this.pxPerBp > this.zoomLevels[this.curZoom])
        this.curZoom++;
    this.maxLeft = this.bpToPx(this.ref.end) - this.dim.width;

    delete this.stripePercent;
    //25, 50, 100 don't work as well due to the way scrollUpdate works
    var possiblePercents = [20, 10, 5, 4, 2, 1];
    for (var i = 0; i < possiblePercents.length; i++) {
        // we'll have (100 / possiblePercents[i]) stripes.
        // multiplying that number of stripes by the minimum stripe width
        // gives us the total width of the "container" div.
        // (or what that width would be if we used possiblePercents[i]
        // as our stripePercent)
        // That width should be wide enough to make sure that the user can
        // scroll at least one page-width in either direction without making
        // the container div bump into the edge of its parent element, taking
        // into account the fact that the container won't always be perfectly
        // centered (it may be as much as 1/2 stripe width off center)
        // So, (this.dim.width * 3) gives one screen-width on either side,
        // and we add a regularStripe width to handle the slightly off-center
        // cases.
        // The minimum stripe width is going to be halfway between
        // "canonical" zoom levels; the widest distance between those
        // zoom levels is 2.5-fold, so halfway between them is 0.7 times
        // the stripe width at the higher zoom level
        if (((100 / possiblePercents[i]) * (this.regularStripe * 0.7))
            > ((this.dim.width * 3) + this.regularStripe)) {
            this.stripePercent = possiblePercents[i];
            break;
        }
    }

    if (this.stripePercent === undefined) {
	console.warn("stripeWidth too small: " + this.stripeWidth + ", " + this.dim.width);
	this.stripePercent = 1;
    }

    var oldX;
    var oldStripeCount = this.stripeCount;
    if (oldStripeCount) oldX = this.getX();
    this.stripeCount = Math.round(100 / this.stripePercent);

    this.scrollContainer.style.width =
        (this.stripeCount * this.stripeWidth) + "px";
    this.zoomContainer.style.width =
        (this.stripeCount * this.stripeWidth) + "px";

    var blockDelta = undefined;
    if (oldStripeCount && (oldStripeCount != this.stripeCount)) {
        blockDelta = Math.floor((oldStripeCount - this.stripeCount) / 2);
        var delta = (blockDelta * this.stripeWidth);
        var newX = this.getX() - delta;
        this.offset += delta;
        this.updateTrackLabels(newX);
        this.rawSetX(newX);
    }

    this.trackIterate(function(track, view) {
                          track.sizeInit(view.stripeCount,
                                         view.stripePercent,
                                         blockDelta);
                      });

    var newHeight = parseInt(this.scrollContainer.style.height);
    newHeight = (newHeight > this.dim.height ? newHeight : this.dim.height);

    this.scrollContainer.style.height = newHeight + "px";
    this.containerHeight = newHeight;

    var refLength = this.ref.end - this.ref.start;
    var posSize = document.createElement("div");
    posSize.className = "overview-pos";
    posSize.appendChild(document.createTextNode(Util.addCommas(this.ref.end)));
    posSize.style.visibility = "hidden";
    this.overview.appendChild(posSize);
    // we want the stripes to be at least as wide as the position labels,
    // plus an arbitrary 20% padding so it's clear which grid line
    // a position label corresponds to.
    var minStripe = posSize.clientWidth * 1.2;
    this.overviewPosHeight = posSize.clientHeight;
    this.overview.removeChild(posSize);
    for (var n = 1; n < 30; n++) {
	//http://research.att.com/~njas/sequences/A051109
        // JBrowse uses this sequence (1, 2, 5, 10, 20, 50, 100, 200, 500...)
        // as its set of zoom levels.  That gives nice round numbers for
        // bases per block, and it gives zoom transitions that feel about the
        // right size to me. -MS
	this.overviewStripeBases = (Math.pow(n % 3, 2) + 1) * Math.pow(10, Math.floor(n/3));
	this.overviewStripes = Math.ceil(refLength / this.overviewStripeBases);
	if ((this.overviewBox.w / this.overviewStripes) > minStripe) break;
	if (this.overviewStripes < 2) break;
    }

    var overviewStripePct = 100 / (refLength / this.overviewStripeBases);
    var overviewHeight = 0;
    this.overviewTrackIterate2(function (track, view) {
	    track.clear();
	    track.sizeInit(view.overviewStripes,
			   overviewStripePct);
            track.showRange(0, view.overviewStripes - 1,
                            0, view.overviewStripeBases,
                            view.overviewBox.w /
                            (view.ref.end - view.ref.start));
	});
    this.updateOverviewHeight();
};

GenomeView.prototype.overviewTrackIterate2 = function(callback) {
    var overviewTrack = this.overview.firstChild;
    do {
        if (overviewTrack && overviewTrack.track && overviewTrack.id != 'chromosome_representation')
	    callback(overviewTrack.track, this);
    } while (overviewTrack && (overviewTrack = overviewTrack.nextSibling));
};

GenomeView.prototype.overviewTrackIterate = function(callback) {
    var overviewTrack = this.overview.firstChild;
    do {
        if (overviewTrack && overviewTrack.track)
            callback(overviewTrack.track, this);
    } while (overviewTrack && (overviewTrack = overviewTrack.nextSibling));
};

GenomeView.prototype.updateOverviewHeight = function(trackName, height) {
    var overviewHeight = 0;
    this.overviewTrackIterate(function (track, view) {
	    overviewHeight += track.height;
	});
    this.overview.style.height = overviewHeight + "px";
    this.overviewBox = dojo.marginBox(this.overview);
};

GenomeView.prototype.addOverviewTrack = function(track) {
    var refLength = this.ref.end - this.ref.start;

    var overviewStripePct = 100 / (refLength / this.overviewStripeBases);
    var trackDiv = document.createElement("div");
    trackDiv.className = "track";
    trackDiv.style.height = this.overviewBox.h + "px";
    trackDiv.style.left = (((-this.ref.start) / refLength) * this.overviewBox.w) + "px";
    trackDiv.id = "overviewtrack_" + track.name;
    trackDiv.track = track;
    var view = this;
    var heightUpdate = function(height) {
        view.updateOverviewHeight();
    };
    track.setViewInfo(heightUpdate, this.overviewStripes, trackDiv,
		      undefined,
		      overviewStripePct,
		      this.overviewStripeBases,
                      this.pxPerBp);
    this.overview.appendChild(trackDiv);
    this.updateOverviewHeight();

    return trackDiv;
};

GenomeView.prototype.trimVertical = function(y) {
    if (y === undefined) y = this.getY();
    var trackBottom;
    var trackTop = this.topSpace;
    var bottom = y + this.dim.height;
    for (var i = 0; i < this.tracks.length; i++) {
        if (this.tracks[i].shown) {
            trackBottom = trackTop + this.trackHeights[i];
            if (!((trackBottom > y) && (trackTop < bottom))) {
                this.tracks[i].hideAll();
            }
            trackTop = trackBottom + this.trackPadding;
        }
    }
};

GenomeView.prototype.zoomIn = function(e, zoomLoc, steps) {
    if (this.animation) return;
    if (zoomLoc === undefined) zoomLoc = 0.5;
    if (steps === undefined) steps = 1;
    steps = Math.min(steps, (this.zoomLevels.length - 1) - this.curZoom);
    if (0 == steps) return;

    this.showWait();
    var pos = this.getPosition();
    this.trimVertical(pos.y);

    var scale = this.zoomLevels[this.curZoom + steps] / this.pxPerBp;
    var fixedBp = this.pxToBp(pos.x + this.offset + (zoomLoc * this.dim.width));
    this.curZoom += steps;
    this.pxPerBp = this.zoomLevels[this.curZoom];
    this.maxLeft = (this.pxPerBp * this.ref.end) - this.dim.width;

    for (var track = 0; track < this.tracks.length; track++)
	this.tracks[track].startZoom(this.pxPerBp,
				     fixedBp - ((zoomLoc * this.dim.width)
                                                / this.pxPerBp),
				     fixedBp + (((1 - zoomLoc) * this.dim.width)
                                                / this.pxPerBp));
	//YAHOO.log("centerBp: " + centerBp + "; estimated post-zoom start base: " + (centerBp - ((zoomLoc * this.dim.width) / this.pxPerBp)) + ", end base: " + (centerBp + (((1 - zoomLoc) * this.dim.width) / this.pxPerBp)));

    var thisObj = this;
    // Zooms take an arbitrary 700 milliseconds, which feels about right
    // to me, although if the zooms were smoother they could probably
    // get faster without becoming off-putting. -MS
    new Zoomer(scale, this,
               function() {thisObj.zoomUpdate(zoomLoc, fixedBp);},
               700, zoomLoc);
};

GenomeView.prototype.zoomOut = function(e, zoomLoc, steps) {
    if (this.animation) return;
    if (steps === undefined) steps = 1;
    steps = Math.min(steps, this.curZoom);
    if (0 == steps) return;

    this.showWait();
    var pos = this.getPosition();
    this.trimVertical(pos.y);
    if (zoomLoc === undefined) zoomLoc = 0.5;
    var scale = this.zoomLevels[this.curZoom - steps] / this.pxPerBp;
    var edgeDist = this.bpToPx(this.ref.end) - (this.offset + pos.x + this.dim.width);
        //zoomLoc is a number on [0,1] that indicates
        //the fixed point of the zoom
    zoomLoc = Math.max(zoomLoc, 1 - (((edgeDist * scale) / (1 - scale)) / this.dim.width));
    edgeDist = pos.x + this.offset - this.bpToPx(this.ref.start);
    zoomLoc = Math.min(zoomLoc, ((edgeDist * scale) / (1 - scale)) / this.dim.width);
    var fixedBp = this.pxToBp(pos.x + this.offset + (zoomLoc * this.dim.width));
    this.curZoom -= steps;
    this.pxPerBp = this.zoomLevels[this.curZoom];

    for (var track = 0; track < this.tracks.length; track++)
	this.tracks[track].startZoom(this.pxPerBp,
				     fixedBp - ((zoomLoc * this.dim.width)
                                                / this.pxPerBp),
				     fixedBp + (((1 - zoomLoc) * this.dim.width)
                                                / this.pxPerBp));

	//YAHOO.log("centerBp: " + centerBp + "; estimated post-zoom start base: " + (centerBp - ((zoomLoc * this.dim.width) / this.pxPerBp)) + ", end base: " + (centerBp + (((1 - zoomLoc) * this.dim.width) / this.pxPerBp)));
    this.minLeft = this.pxPerBp * this.ref.start;

    var thisObj = this;
    // Zooms take an arbitrary 700 milliseconds, which feels about right
    // to me, although if the zooms were smoother they could probably
    // get faster without becoming off-putting. -MS
    new Zoomer(scale, this,
               function() {thisObj.zoomUpdate(zoomLoc, fixedBp);},
               700, zoomLoc);
};

GenomeView.prototype.zoomUpdate = function(zoomLoc, fixedBp) {
    var eWidth = this.elem.clientWidth;
    var centerPx = this.bpToPx(fixedBp) - (zoomLoc * eWidth) + (eWidth / 2);
    this.stripeWidth = this.stripeWidthForZoom(this.curZoom);
    this.scrollContainer.style.width =
        (this.stripeCount * this.stripeWidth) + "px";
    this.zoomContainer.style.width =
        (this.stripeCount * this.stripeWidth) + "px";
    var centerStripe = Math.round(centerPx / this.stripeWidth);
    var firstStripe = (centerStripe - ((this.stripeCount) / 2)) | 0;
    this.offset = firstStripe * this.stripeWidth;
    this.maxOffset = this.bpToPx(this.ref.end) - this.stripeCount * this.stripeWidth;
    this.maxLeft = this.bpToPx(this.ref.end) - this.dim.width;
    this.minLeft = this.bpToPx(this.ref.start);
    this.zoomContainer.style.left = "0px";
    this.setX((centerPx - this.offset) - (eWidth / 2));
    dojo.forEach(this.uiTracks, function(track) { track.clear(); });
    for (var track = 0; track < this.tracks.length; track++)
	this.tracks[track].endZoom(this.pxPerBp, Math.round(this.stripeWidth / this.pxPerBp));
    //YAHOO.log("post-zoom start base: " + this.pxToBp(this.offset + this.getX()) + ", end base: " + this.pxToBp(this.offset + this.getX() + this.dim.width));
    this.showVisibleBlocks(true);
    this.showDone();
    this.showCoarse();
};

GenomeView.prototype.scrollUpdate = function() {
    var x = this.getX();
    var numStripes = this.stripeCount;
    var cWidth = numStripes * this.stripeWidth;
    var eWidth = this.dim.width;
    //dx: horizontal distance between the centers of
    //this.scrollContainer and this.elem
    var dx = (cWidth / 2) - ((eWidth / 2) + x);
    //If dx is negative, we add stripes on the right, if positive,
    //add on the left.
    //We remove stripes from the other side to keep cWidth the same.
    //The end goal is to minimize dx while making sure the surviving
    //stripes end up in the same place.

    var dStripes = (dx / this.stripeWidth) | 0;
    if (0 == dStripes) return;
    var changedStripes = Math.abs(dStripes);

    var newOffset = this.offset - (dStripes * this.stripeWidth);

    if (this.offset == newOffset) return;
    this.offset = newOffset;

    this.trackIterate(function(track) { track.moveBlocks(dStripes); });

    var newX = x + (dStripes * this.stripeWidth);
    this.updateTrackLabels(newX);
    this.rawSetX(newX);
    var firstVisible = (newX / this.stripeWidth) | 0;
};

GenomeView.prototype.trackHeightUpdate = function(trackName, height) {
    var y = this.getY();
    if (! trackName in this.trackIndices) return;
    var track = this.trackIndices[trackName];
    if (Math.abs(height - this.trackHeights[track]) < 1) return;

    //console.log("trackHeightUpdate: " + trackName + " " + this.trackHeights[track] + " -> " + height);
    // if the bottom of this track is a above the halfway point,
    // and we're not all the way at the top,
    if ((((this.trackTops[track] + this.trackHeights[track]) - y)
         <  (this.dim.height / 2))
        && (y > 0) ) {
        // scroll so that lower tracks stay in place on screen
        this.setY(y + (height - this.trackHeights[track]));
        //console.log("track " + trackName + ": " + this.trackHeights[track] + " -> " + height + "; y: " + y + " -> " + this.getY());
    }
    this.trackHeights[track] = height;
    this.tracks[track].div.style.height = (height + this.trackPadding) + "px";
    var nextTop = this.trackTops[track];
    if (this.tracks[track].shown) nextTop += height + this.trackPadding;
    for (var i = track + 1; i < this.tracks.length; i++) {
        this.trackTops[i] = nextTop;
        this.tracks[i].div.style.top = nextTop + "px";
        if (this.tracks[i].shown)
            nextTop += this.trackHeights[i] + this.trackPadding;
    }
    this.containerHeight = Math.max(nextTop, this.getY() + this.dim.height);
    this.scrollContainer.style.height = this.containerHeight + "px";
};

GenomeView.prototype.showVisibleBlocks = function(updateHeight, pos, startX, endX) {
    if (pos === undefined) pos = this.getPosition();
    if (startX === undefined) startX = pos.x - (this.drawMargin * this.dim.width);
    if (endX === undefined) endX = pos.x + ((1 + this.drawMargin) * this.dim.width);
    var leftVisible = Math.max(0, (startX / this.stripeWidth) | 0);
    var rightVisible = Math.min(this.stripeCount - 1,
                               (endX / this.stripeWidth) | 0);

    var bpPerBlock = Math.round(this.stripeWidth / this.pxPerBp);

    var startBase = Math.round(this.pxToBp((leftVisible * this.stripeWidth)
                                           + this.offset));
    var containerStart = Math.round(this.pxToBp(this.offset));
    var containerEnd =
        Math.round(this.pxToBp(this.offset
                               + (this.stripeCount * this.stripeWidth)));

    this.trackIterate(function(track, view) {
                          track.showRange(leftVisible, rightVisible,
                                          startBase, bpPerBlock,
                                          view.pxPerBp,
                                          containerStart, containerEnd);
                      });
};

GenomeView.prototype.addTrack = function(track) {
    var trackNum = this.tracks.length;
    var labelDiv = document.createElement("div");
    labelDiv.className = "track-label dojoDndHandle";
    labelDiv.id = "label_" + track.name;
    this.trackLabels.push(labelDiv);
    var trackDiv = document.createElement("div");
    trackDiv.className = "track";
    trackDiv.id = "track_" + track.name;
    trackDiv.track = track;
    var view = this;
    var heightUpdate = function(height) {
        view.trackHeightUpdate(track.name, height);
    };
    track.setViewInfo(heightUpdate, this.stripeCount, trackDiv, labelDiv,
		      this.stripePercent, this.stripeWidth,
                      this.pxPerBp);

    labelDiv.style.position = "absolute";
    labelDiv.style.top = "0px";
    labelDiv.style.left = this.getX() + "px";
    trackDiv.appendChild(labelDiv);

    return trackDiv;
};

GenomeView.prototype.trackIterate = function(callback) {
    var i;
    for (i = 0; i < this.uiTracks.length; i++)
        callback(this.uiTracks[i], this);
    for (i = 0; i < this.tracks.length; i++)
        callback(this.tracks[i], this);
};

/* this function must be called whenever tracks in the GenomeView
 * are added, removed, or reordered
 */
GenomeView.prototype.updateTrackList = function() {
    var tracks = [];
    // after a track has been dragged, the DOM is the only place
    // that knows the new ordering
    var containerChild = this.zoomContainer.firstChild;
    do {
        // this test excludes UI tracks, whose divs don't have a track property
        if (containerChild.track) tracks.push(containerChild.track);
    } while ((containerChild = containerChild.nextSibling));
    this.tracks = tracks;

    var newIndices = {};
    var newHeights = new Array(this.tracks.length);
    for (var i = 0; i < tracks.length; i++) {
        newIndices[tracks[i].name] = i;
        if (tracks[i].name in this.trackIndices) {
            newHeights[i] = this.trackHeights[this.trackIndices[tracks[i].name]];
        } else {
            newHeights[i] = 0;
        }
        this.trackIndices[tracks[i].name] = i;
    }
    this.trackIndices = newIndices;
    this.trackHeights = newHeights;
    var nextTop = this.topSpace;
    for (var i = 0; i < this.tracks.length; i++) {
        this.trackTops[i] = nextTop;
        this.tracks[i].div.style.top = nextTop + "px";
        if (this.tracks[i].shown)
            nextTop += this.trackHeights[i] + this.trackPadding;
    }
};

/*

Copyright (c) 2007-2009 The Evolutionary Software Foundation

Created by Mitchell Skinner <mitch_skinner@berkeley.edu>

This package and its accompanying libraries are free software; you can
redistribute it and/or modify it under the terms of the LGPL (either
version 2.1, or at your option, any later version) or the Artistic
License 2.0.  Refer to LICENSE for the full license text.

*/
function ImageTrack(trackMeta, url, refSeq, browserParams) {
    Track.call(this, trackMeta.label, trackMeta.key,
               false, browserParams.changeCallback);
    this.refSeq = refSeq;
    this.tileToImage = {};
    this.zoomCache = {};
    this.baseUrl = (browserParams.baseUrl ? browserParams.baseUrl : "");
    this.load(this.baseUrl + url);

    this.imgErrorHandler = function(ev) {
        var img = ev.target || ev.srcElement;
        img.style.display = "none";
        dojo.stopEvent(ev);
    };
}

ImageTrack.prototype = new Track("");

ImageTrack.prototype.loadSuccess = function(o) {
    //tileWidth: width, in pixels, of the tiles
    this.tileWidth = o.tileWidth;
    //zoomLevels: array of {basesPerTile, scale, height, urlPrefix} hashes
    this.zoomLevels = o.zoomLevels;
    this.setLoaded();
};

ImageTrack.prototype.setViewInfo = function(heightUpdate, numBlocks,
                                            trackDiv, labelDiv,
                                            widthPct, widthPx, scale) {
    Track.prototype.setViewInfo.apply(this, [heightUpdate, numBlocks,
                                             trackDiv, labelDiv,
                                             widthPct, widthPx, scale]);
    this.setLabel(this.key);
};

ImageTrack.prototype.getZoom = function(scale) {
    var result = this.zoomCache[scale];
    if (result) return result;

    result = this.zoomLevels[0];
    var desiredBases = this.tileWidth / scale;
    for (i = 1; i < this.zoomLevels.length; i++) {
        if (Math.abs(this.zoomLevels[i].basesPerTile - desiredBases)
            < Math.abs(result.basesPerTile - desiredBases))
            result = this.zoomLevels[i];
    }

    this.zoomCache[scale] = result;
    return result;
};

ImageTrack.prototype.getImages = function(zoom, startBase, endBase) {
    //var startTile = ((startBase - this.refSeq.start) / zoom.basesPerTile) | 0;
    //var endTile = ((endBase - this.refSeq.start) / zoom.basesPerTile) | 0;
    var startTile = (startBase / zoom.basesPerTile) | 0;
    var endTile = (endBase / zoom.basesPerTile) | 0;
    startTile = Math.max(startTile, 0);
    var result = [];
    var im;
    for (var i = startTile; i <= endTile; i++) {
	im = this.tileToImage[i];
	if (!im) {
	    im = document.createElement("img");
            dojo.connect(im, "onerror", this.imgErrorHandler);
            //prepend this.baseUrl if zoom.urlPrefix is relative
            var absUrl = new RegExp("^(([^/]+:)|\/)");
            im.src = (zoom.urlPrefix.match(absUrl) ? "" : this.baseUrl)
                     + zoom.urlPrefix + i + ".png";
            //TODO: need image coord systems that don't start at 0?
	    im.startBase = (i * zoom.basesPerTile); // + this.refSeq.start;
	    im.baseWidth = zoom.basesPerTile;
	    im.tileNum = i;
	    this.tileToImage[i] = im;
	}
	result.push(im);
    }
    return result;
};

ImageTrack.prototype.fillBlock = function(blockIndex, block,
                                          leftBlock, rightBlock,
                                          leftBase, rightBase,
                                          scale, stripeWidth,
                                          containerStart, containerEnd) {
    var zoom = this.getZoom(scale);
    var blockWidth = rightBase - leftBase;
    var images = this.getImages(zoom, leftBase, rightBase);
    var im;

    for (var i = 0; i < images.length; i++) {
	im = images[i];
	if (!(im.parentNode && im.parentNode.parentNode)) {
            im.style.position = "absolute";
            im.style.left = (100 * ((im.startBase - leftBase) / blockWidth)) + "%";
            im.style.width = (100 * (im.baseWidth / blockWidth)) + "%";
            im.style.top = "0px";
            im.style.height = zoom.height + "px";
            block.appendChild(im);
	}
    }

    this.heightUpdate(zoom.height, blockIndex);
};

ImageTrack.prototype.startZoom = function(destScale, destStart, destEnd) {
    if (this.empty) return;
    this.tileToImage = {};
    this.getImages(this.getZoom(destScale), destStart, destEnd);
};

ImageTrack.prototype.endZoom = function(destScale, destBlockBases) {
    Track.prototype.clear.apply(this);
};

ImageTrack.prototype.clear = function() {
    Track.prototype.clear.apply(this);
    this.tileToImage = {};
};

ImageTrack.prototype.transfer = function(sourceBlock, destBlock, scale,
                                         containerStart, containerEnd) {
    if (!(sourceBlock && destBlock)) return;

    var children = sourceBlock.childNodes;
    var destLeft = destBlock.startBase;
    var destRight = destBlock.endBase;
    var im;
    for (var i = 0; i < children.length; i++) {
	im = children[i];
	if ("startBase" in im) {
	    //if sourceBlock contains an image that overlaps destBlock,
	    if ((im.startBase < destRight)
		&& ((im.startBase + im.baseWidth) > destLeft)) {
		//move image from sourceBlock to destBlock
		im.style.left = (100 * ((im.startBase - destLeft) / (destRight - destLeft))) + "%";
		destBlock.appendChild(im);
	    } else {
		delete this.tileToImage[im.tileNum];
	    }
	}
    }
};

/*

Copyright (c) 2007-2009 The Evolutionary Software Foundation

Created by Mitchell Skinner <mitch_skinner@berkeley.edu>

This package and its accompanying libraries are free software; you can
redistribute it and/or modify it under the terms of the LGPL (either
version 2.1, or at your option, any later version) or the Artistic
License 2.0.  Refer to LICENSE for the full license text.

*/
/*
 * Code for laying out rectangles, given that layout is also happening
 * in adjacent blocks at the same time
 *
 * This code does a lot of linear searching; n should be low enough that
 * it's not a problem but if it turns out to be, some of it can be changed to
 * binary searching without too much work.  Another possibility is to merge
 * contour spans and give up some packing closeness in exchange for speed
 * (the code already merges spans that have the same x-coord and are vertically
 * contiguous).
 */

function Contour(top) {
    /*
     * A contour is described by a set of vertical lines of varying heights,
     * like this:
     *                         |
     *                         |
     *               |
     *                   |
     *                   |
     *                   |
     *
     * The contour is the union of the rectangles ending on the right side
     * at those lines, and extending leftward toward negative infinity.
     *
     * <=======================|
     * <=======================|
     * <==========|
     * <=================|
     * <=================|
     * <=================|
     *
     * x -->
     *
     * As we add new vertical spans, the contour expands, either downward
     * or in the direction of increasing x.
     */
    // takes: top, a number indicating where the first span of the contour
    // will go
    if (top === undefined) top = 0;

    // spans is an array of {top, x, height} objects representing
    // the boundaries of the contour
    // they're always sorted by top
    this.spans = [{top: top, x: Infinity, height: 0}];
}

// finds a space in the contour into which the given span fits
// (i.e., the given span has higher x than the contour over its vertical span)
// returns an ojbect {above, count}; above is the index of the last span above
// where the given span will fit, count is the number of spans being
// replaced by the given span
Contour.prototype.getFit = function(x, height, minTop) {
    var aboveBottom, curSpan;
    var above = 0;
    if (minTop) {
        // set above = (index of the first span that starts below minTop)
        for (; this.spans[above].top < minTop; above++) {
            if (above >= (this.spans.length - 1))
                return {above: this.spans.length - 1, count: 0};
        }
    }
    // slide down the contour
    ABOVE: for (; above < this.spans.length; above++) {
        aboveBottom = this.spans[above].top + this.spans[above].height;
        for (var count = 1; above + count < this.spans.length; count++) {
            curSpan = this.spans[above + count];
            if ((aboveBottom + height) <= curSpan.top) {
                // the given span fits between span[above] and
                // curSpan, keeping curSpan
                return {above: above, count: count - 1};
            }
            if (curSpan.x > x) {
                // the span at [above + count] overlaps the given span,
                // so we continue down the contour
                continue ABOVE;
            }
            if ((curSpan.x <= x) &&
                ((aboveBottom + height) < (curSpan.top + curSpan.height))) {
                // the given span partially covers curSpan, and
                // will overlap it, so we keep curSpan
                return {above: above, count: count - 1};
            }
        }
        // the given span fits below span[above], replacing any
        // lower spans in the contour
        return {above: above, count: count - 1};
    }
    // the given span fits at the end of the contour, replacing no spans
    return {above: above, count: 0};
};

// add the given span to this contour where it fits, as given
// by getFit
Contour.prototype.insertFit = function(fit, x, top, height) {
    // if the previous span and the current span have the same x-coord,
    // and are vertically contiguous, merge them.
    var prevSpan = this.spans[fit.above];
    if ((Math.abs(prevSpan.x - x) < 1)
        && (Math.abs((prevSpan.top + prevSpan.height) - top) < 1) ) {
        prevSpan.height = (top + height) - prevSpan.top;
        // a bit of slop here is conservative if we take the max
        // (means things might get laid out slightly farther apart
        // than they would otherwise)
        prevSpan.x = Math.max(prevSpan.x, x);
        this.spans.splice(fit.above + 1, fit.count);
    } else {
        this.spans.splice(fit.above + 1, fit.count,
                          {
                              top: top,
                              x: x,
                              height: height
                          });
    }
};

// add the given span to this contour at the given location, if
// it would extend the contour
Contour.prototype.unionWith = function(x, top, height) {
    var startBottom, startIndex, endIndex, startSpan, endSpan;
    var bottom = top + height;
    START: for (startIndex = 0; startIndex < this.spans.length; startIndex++) {
        startSpan = this.spans[startIndex];
        startBottom = startSpan.top + startSpan.height;
        if (startSpan.top > top) {
            // the given span extends above an existing span
            endIndex = startIndex;
            break START;
        }
        if (startBottom > top) {
            // if startSpan covers (at least some of) the given span,
            if (startSpan.x >= x) {
                var covered = startBottom - top;
                // we don't have to worry about the covered area any more
                top += covered;
                height -= covered;
                // if we've eaten up the whole span, then it's submerged
                // and we don't have to do anything
                if (top >= bottom) return;
                continue;
            } else {
                // find the first span not covered by the given span
                for (endIndex = startIndex;
                     endIndex < this.spans.length;
                     endIndex++) {
                    endSpan = this.spans[endIndex];
                    // if endSpan extends below or to the right
                    // of the given span, then we need to keep it
                    if (((endSpan.top + endSpan.height) > bottom)
                        || endSpan.x > x) {
                        break START;
                    }
                }
                break START;
            }
        }
    }

    // if the previous span and the current span have the same x-coord,
    // and are vertically contiguous, merge them.
    var prevSpan = this.spans[startIndex - 1];
    if ((Math.abs(prevSpan.x - x) < 1)
        && (Math.abs((prevSpan.top + prevSpan.height) - top) < 1) ) {
        prevSpan.height = (top + height) - prevSpan.top;
        prevSpan.x = Math.max(prevSpan.x, x);
        this.spans.splice(startIndex, endIndex - startIndex);
    } else {
        this.spans.splice(startIndex, endIndex - startIndex,
                          {
                              top: top,
                              x: x,
                              height: height
                          });
    }
};

// returns the top of the to-be-added span that fits into "fit"
// (as returned by getFit)
Contour.prototype.getNextTop = function(fit) {
    return this.spans[fit.above].top + this.spans[fit.above].height;
};

function Layout(leftBound, rightBound) {
    this.leftBound = leftBound;
    this.rightBound = rightBound;
    // a Layout contains a left contour and a right contour;
    // the area between the contours is allocated, and the
    // area outside the contours is free.
    this.leftContour = new Contour();
    this.rightContour = new Contour();
    this.seen = {};
    this.leftOverlaps = [];
    this.rightOverlaps = [];
    this.totalHeight = 0;
}

Layout.prototype.addRect = function(id, left, right, height) {
    if (this.seen[id] !== undefined) return this.seen[id];
    // for each contour, we test the fit on the near side of the given rect,
    var leftFit = this.tryLeftFit(left, right, height, 0);
    var rightFit = this.tryRightFit(left, right, height, 0);

    var top;

    // and insert the far side from the side we tested
    // (we want to make sure the near side fits, but we want to extend
    //  the contour to cover the far side)
    if (leftFit.top < rightFit.top) {
        top = leftFit.top;
        this.leftContour.insertFit(leftFit.fit, this.rightBound - left,
                                   top, height);
        this.rightContour.unionWith(right - this.leftBound, top, height);
    } else {
        top = rightFit.top;
        this.rightContour.insertFit(rightFit.fit, right - this.leftBound,
                                    top, height);
        this.leftContour.unionWith(this.rightBound - left, top, height);
    }

    var existing = {id: id, left: left, right: right,
                    top: top, height: height};
    this.seen[id] = top;
    if (left <= this.leftBound) {
        this.leftOverlaps.push(existing);
        if (this.leftLayout) this.leftLayout.addExisting(existing);
    }
    if (right >= this.rightBound) {
        this.rightOverlaps.push(existing);
        if (this.rightLayout) this.rightLayout.addExisting(existing);
    }
    this.seen[id] = top;
    this.totalHeight = Math.max(this.totalHeight, top + height);
    return top;
};

// this method is called by the block to the left to see if a given fit works
// in this layout
// takes: proposed rectangle
// returns: {top: value that makes the rectangle fit in this layout,
//           fit: "fit" for passing to insertFit}
Layout.prototype.tryLeftFit = function(left, right, height, top) {
    var fit, nextFit;
    var curTop = top;
    while (true) {
        // check if the rectangle fits at curTop
        fit = this.leftContour.getFit(this.rightBound - right, height, curTop);
        curTop = Math.max(this.leftContour.getNextTop(fit), curTop);
        // if the rectangle extends onto the next block to the right;
        if (this.rightLayout && (right >= this.rightBound)) {
            // check if the rectangle fits into that block at this position
            nextFit = this.rightLayout.tryLeftFit(left, right, height, curTop);
            // if not, nextTop will be the next y-value where the rectangle
            // fits into that block
            if (nextFit.top > curTop) {
                // in that case, try again to see if that y-value works
                curTop = nextFit.top;
                continue;
            }
        }
        break;
    }
    return {top: curTop, fit: fit};
};

// this method is called by the block to the right to see if a given fit works
// in this layout
// takes: proposed rectangle
// returns: {top: value that makes the rectangle fit in this layout,
//           fit: "fit" for passing to insertFit}
Layout.prototype.tryRightFit = function(left, right, height, top) {
    var fit, nextFit;
    var curTop = top;
    while (true) {
        // check if the rectangle fits at curTop
        fit = this.rightContour.getFit(left - this.leftBound, height, curTop);
        curTop = Math.max(this.rightContour.getNextTop(fit), curTop);
        // if the rectangle extends onto the next block to the left;
        if (this.leftLayout && (left <= this.leftBound)) {
            // check if the rectangle fits into that block at this position
            nextFit = this.leftLayout.tryRightFit(left, right, height, curTop);
            // if not, nextTop will be the next y-value where the rectangle
            // fits into that block
            if (nextFit.top > curTop) {
                // in that case, try again to see if that y-value works
                curTop = nextFit.top;
                continue;
            }
        }
        break;
    }
    return {top: curTop, fit: fit};
};

Layout.prototype.hasSeen = function(id) {
    return (this.seen[id] !== undefined);
};

Layout.prototype.setLeftLayout = function(left) {
    for (var i = 0; i < this.leftOverlaps.length; i++) {
        left.addExisting(this.leftOverlaps[i]);
    }
    this.leftLayout = left;
};

Layout.prototype.setRightLayout = function(right) {
    for (var i = 0; i < this.rightOverlaps.length; i++) {
        right.addExisting(this.rightOverlaps[i]);
    }
    this.rightLayout = right;
};

Layout.prototype.cleanup = function() {
    this.leftLayout = undefined;
    this.rightLayout = undefined;
};

//expects an {id, left, right, height, top} object
Layout.prototype.addExisting = function(existing) {
    if (this.seen[existing.id] !== undefined) return;
    this.seen[existing.id] = existing.top;

    this.totalHeight =
        Math.max(this.totalHeight, existing.top + existing.height);

    if (existing.left <= this.leftBound) {
        this.leftOverlaps.push(existing);
        if (this.leftLayout) this.leftLayout.addExisting(existing);
    }
    if (existing.right >= this.rightBound) {
        this.rightOverlaps.push(existing);
        if (this.rightLayout) this.rightLayout.addExisting(existing);
    }

    this.leftContour.unionWith(this.rightBound - existing.left,
                               existing.top,
                               existing.height);
    this.rightContour.unionWith(existing.right - this.leftBound,
                                existing.top,
                                existing.height);
};

/*

Copyright (c) 2007-2010 The Evolutionary Software Foundation

Created by Mitchell Skinner <mitch_skinner@berkeley.edu>

This package and its accompanying libraries are free software; you can
redistribute it and/or modify it under the terms of the LGPL (either
version 2.1, or at your option, any later version) or the Artistic
License 2.0.  Refer to LICENSE for the full license text.

*/
/*
 * For a JSON array that gets too large to load in one go, this class
 * helps break it up into chunks and provides an
 * async API for using the information in the array.
 */

/**
 * Construct a new LazyArray
 * @class This class makes it easier to partially load a large JSON array
 * @constructor
 * @param lazyArrayParams object with:<br>
 * <ul>
 * <li><code>urlTemplate</code> - for each lazily-loaded array chunk, the chunk number will get substituted for {chunk} in this template, and the result will beused as the URL of the JSON for that array chunk</li>
 * <li><code>length</code> - length of the overall array</li>
 * <li><code>chunkSize</code> - the size of each array chunk</li>
 * </ul>
 */
function LazyArray(lazyArrayParams, baseUrl) {
    this.urlTemplate = lazyArrayParams.urlTemplate;
    this.chunkSize = lazyArrayParams.chunkSize;
    this.length = lazyArrayParams.length;
    this.baseUrl = (baseUrl === undefined ? "" : baseUrl);
    // Once a range gets loaded, it goes into the "chunks" array.
    // this.chunks[n] contains data for indices in the range
    // [n * chunkSize, Math.min(length - 1, (n * (chunkSize + 1)) - 1)]
    this.chunks = [];
    // If a range is currently loading, this will contain a property
    // "chunk number": [{start, end, callback, param}, ...]
    this.toProcess = {};
}

/**
 * call the callback on one element of the array
 * @param i index
 * @param callback callback, gets called with (i, value, param)
 * @param param (optional) callback will get this as its last parameter
 */
LazyArray.prototype.index = function(i, callback, param) {
    this.range(i, i, callback, undefined, param);
};

/**
 * call the callback on each element in the range [start, end]
 * @param start index of first element to call the callback on
 * @param end index of last element to call the callback on
 * @param callback callback, gets called with (i, value, param)
 * @param postFun (optional) callback that gets called when <code>callback</code> has been run on every element in the range
 * @param param (optional) callback will get this as its last parameter
 */
LazyArray.prototype.range = function(start, end, callback, postFun, param) {
    start = Math.max(0, start);
    end = Math.min(end, this.length - 1);

    var firstChunk = Math.floor(start / this.chunkSize);
    var lastChunk = Math.floor(end / this.chunkSize);

    if (postFun === undefined) postFun = function() {};
    var finish = new Finisher(postFun);

    for (var chunk = firstChunk; chunk <= lastChunk; chunk++) {
        if (this.chunks[chunk]) {
            // chunk is loaded
            this._processChunk(start, end, chunk, callback, param);
        } else {
            var toProcessInfo = {
                start: start,
                end: end,
                callback: callback,
                param: param,
                finish: finish
            };

            finish.inc();
            if (this.toProcess[chunk]) {
                // chunk is currently being loaded
                this.toProcess[chunk].push(toProcessInfo);
            } else {
                // start loading chunk
                this.toProcess[chunk] = [toProcessInfo];
                var url = this.urlTemplate.replace(/\{chunk\}/g, chunk);
                var thisObj = this;
                dojo.xhrGet(
                    {
                        url: this.baseUrl + url,
                        handleAs: "json",
                        load: this._makeLoadFun(chunk),
                        error: function() { finish.dec(); }
                    });
            }
        }
    }
    finish.finish();
};

LazyArray.prototype._makeLoadFun = function(chunk) {
    var thisObj = this;
    return function(data) {
        thisObj.chunks[chunk] = data;
        var toProcess = thisObj.toProcess[chunk];
        delete thisObj.toProcess[chunk];
        for (var i = 0; i < toProcess.length; i++) {
            thisObj._processChunk(toProcess[i].start,
                                  toProcess[i].end,
                                  chunk,
                                  toProcess[i].callback,
                                  toProcess[i].param);
            toProcess[i].finish.dec();
        }
    };
};

LazyArray.prototype._processChunk = function(start, end, chunk,
                                             callback, param) {
    // index (in the overall lazy array) of the first position in this chunk
    var firstIndex = chunk * this.chunkSize;

    var chunkStart = start - firstIndex;
    var chunkEnd = end - firstIndex;
    chunkStart = Math.max(0, chunkStart);
    chunkEnd = Math.min(chunkEnd, this.chunkSize - 1);

    for (var i = chunkStart; i <= chunkEnd; i++) {
        callback(i + firstIndex, this.chunks[chunk][i], param);
    }
};/*
  Implements a lazy PATRICIA tree.

  This class is a map where the keys are strings.  The map supports fast
  queries by key string prefix ("show me all the values for keys that
  start with "abc").  It also supports lazily loading subtrees.

  Each edge is labeled with a substring of a key string.
  Each node in the tree has one or more children, each of which represents
    a potential completion of the string formed by concatenating all of the
    edge strings from that node up to the root.
    Nodes also have zero or one data items.
  Leaves have zero or one data items.

  Each loaded node is an array.
    element 0 is the edge string;
    element 1 is the data item, or null if there is none;
    any further elements are the child nodes, sorted lexicographically
      by their edge string

  Each lazy node is an array where the first element is the number of
  data items in the subtree rooted at that node, and the second element
  is the edge string for that node.
    when the lazy node is loaded, the lazy array gets replaced with
    a loaded node array; lazy nodes and loaded nodes can be distinguished by:
    "string" == typeof loaded_node[0]
    "number" == typeof lazy_node[0]

  e.g., for the mappings:
    abc   => 0
    abcd  => 1
    abce  => "baz"
    abfoo => [3, 4]
    abbar (subtree to be loaded lazily)

  the structure is:

  [, , ["ab", ,
        [3, "bar"],
        ["c", 0, ["d", 1],
         ["e", "baz"]],
        ["foo", [3, 4]]
        ]
   ]

  The main goals for this structure were to minimize the JSON size on
  the wire (so, no type tags in the JSON to distinguish loaded nodes,
  lazy nodes, and leaves) while supporting lazy loading and reasonably
  fast lookups.
 */

function LazyTrie(baseURL, rootURL) {
    this.baseURL = baseURL;
    var trie = this;

    dojo.xhrGet({url: rootURL,
                 handleAs: "json",
                 load: function(o) {
                     if (!o) {
                         console.log("failed to load trie");
                         return;
                     }
                     trie.root = o;
                     trie.extra = o[0];
                     if (trie.deferred) {
                         trie.deferred.callee.apply(trie, trie.deferred);
                         delete trie.deferred;
                     }
                 }
        });
}

LazyTrie.prototype.pathToPrefix = function(path) {
    var node = this.root;
    var result = "";
    loop: for (var i = 0; i < path.length; i++) {
        switch(typeof node[path[i]][0]) {
        case 'string': // regular node
            result += node[path[i]][0];
            break;
        case 'number': // lazy node
            result += node[path[i]][1];
            break loop;
        }
        node = node[path[i]];
    }
    return result;
};

LazyTrie.prototype.valuesFromPrefix = function(query, callback) {
    var trie = this;
    this.findNode(query, function(prefix, node) {
            callback(trie.valuesFromNode(node));
        });
};

LazyTrie.prototype.mappingsFromPrefix = function(query, callback) {
    var trie = this;
    this.findNode(query, function(prefix, node) {
            callback(trie.mappingsFromNode(prefix, node));
        });
};

LazyTrie.prototype.mappingsFromNode = function(prefix, node) {
    var results = [];
    if (node[1] !== null)
        results.push([prefix, node[1]]);
    for (var i = 2; i < node.length; i++) {
        if ("string" == typeof node[i][0]) {
            results = results.concat(this.mappingsFromNode(prefix + node[i][0],
                                                           node[i]));
        }
    }
    return results;
};

LazyTrie.prototype.valuesFromNode = function(node) {
    var results = [];
    if (node[1] !== null)
        results.push(node[1]);
    for (var i = 2; i < node.length; i++)
        results = results.concat(this.valuesFromNode(node[i]));
    return results;
};

LazyTrie.prototype.exactMatch = function(key, callback) {
    var trie = this;
    this.findNode(key, function(prefix, node) {
            if ((prefix.toLowerCase() == key.toLowerCase()) && node[1])
                callback(node[1]);
        });
};

LazyTrie.prototype.findNode = function(query, callback) {
    var trie = this;
    this.findPath(query, function(path) {
        var node = trie.root;
        for (i = 0; i < path.length; i++)
            node = node[path[i]];
        var foundPrefix = trie.pathToPrefix(path);
        callback(foundPrefix, node);
    });
};

LazyTrie.prototype.findPath = function(query, callback) {
    if (!this.root) {
        this.deferred = arguments;
        return;
    }
    query = query.toLowerCase();
    var node = this.root;
    var qStart = 0;
    var childIndex;

    var path = [];

    while(true) {
        childIndex = this.binarySearch(node, query.charAt(qStart));
        if (childIndex < 0) return;
        path.push(childIndex);

        if ("number" == typeof node[childIndex][0]) {
            // lazy node
            var trie = this;
            dojo.xhrGet({url: this.baseURL + this.pathToPrefix(path) + ".json",
                         handleAs: "json",
                         load: function(o) {
                             node[childIndex] = o;
                             trie.findPath(query, callback);
                         }
                        });
            return;
        }

        node = node[childIndex];

        // if the current edge string doesn't match the
        // relevant part of the query string, then there's no
        // match
        if (query.substr(qStart, node[0].length)
            != node[0].substr(0, Math.min(node[0].length,
                                          query.length - qStart)))
            return;

        qStart += node[0].length;
        if (qStart >= query.length) {
            // we've reached the end of the query string, and we
            // have some matches
            callback(path);
            return;
        }
    }
};

LazyTrie.prototype.binarySearch = function(a, firstChar) {
    var low = 2; // skip edge string (in 0) and data item (in 1)
    var high = a.length - 1;
    var mid, midVal;
    while (low <= high) {
        mid = (low + high) >>> 1;
        switch(typeof a[mid][0]) {
        case 'string': // regular node
            midVal = a[mid][0].charAt(0);
            break;
        case 'number': // lazy node
            midVal = a[mid][1].charAt(0);
            break;
        }

        if (midVal < firstChar) {
            low = mid + 1;
        } else if (midVal > firstChar) {
            high = mid - 1;
        } else {
            return mid; // key found
        }
    }

    return -(low + 1);  // key not found.
};

/*

Copyright (c) 2007-2009 The Evolutionary Software Foundation

Created by Mitchell Skinner <mitch_skinner@berkeley.edu>

This package and its accompanying libraries are free software; you can
redistribute it and/or modify it under the terms of the LGPL (either
version 2.1, or at your option, any later version) or the Artistic
License 2.0.  Refer to LICENSE for the full license text.

*/
//After
//Alekseyenko, A., and Lee, C. (2007).
//Nested Containment List (NCList): A new algorithm for accelerating
//   interval query of genome alignment and interval databases.
//Bioinformatics, doi:10.1093/bioinformatics/btl647
//http://bioinformatics.oxfordjournals.org/cgi/content/abstract/btl647v1

function NCList() {
}

NCList.prototype.importExisting = function(nclist, sublistIndex,
                                           lazyIndex, baseURL,
                                           lazyUrlTemplate) {
    this.topList = nclist;
    this.sublistIndex = sublistIndex;
    this.lazyIndex = lazyIndex;
    this.baseURL = baseURL;
    this.lazyUrlTemplate = lazyUrlTemplate;
};

NCList.prototype.fill = function(intervals, sublistIndex) {
    //intervals: array of arrays of [start, end, ...]
    //sublistIndex: index into a [start, end] array for storing a sublist
    //              array. this is so you can use those arrays for something
    //              else, and keep the NCList bookkeeping from interfering.
    //              That's hacky, but keeping a separate copy of the intervals
    //              in the NCList seems like a waste (TODO: measure that waste).
    //half-open?
    this.sublistIndex = sublistIndex;
    var myIntervals = intervals;//.concat();
    //sort by OL
    myIntervals.sort(function(a, b) {
        if (a[0] != b[0])
            return a[0] - b[0];
        else
            return b[1] - a[1];
    });
    var sublistStack = new Array();
    var curList = new Array();
    this.topList = curList;
    curList.push(myIntervals[0]);
    var curInterval, topSublist;
    for (var i = 1, len = myIntervals.length; i < len; i++) {
        curInterval = myIntervals[i];
        //if this interval is contained in the previous interval,
        if (curInterval[1] < myIntervals[i - 1][1]) {
            //create a new sublist starting with this interval
            sublistStack.push(curList);
            curList = new Array(curInterval);
            myIntervals[i - 1][sublistIndex] = curList;
        } else {
            //find the right sublist for this interval
            while (true) {
                if (0 == sublistStack.length) {
                    curList.push(curInterval);
                    break;
                } else {
                    topSublist = sublistStack[sublistStack.length - 1];
                    if (topSublist[topSublist.length - 1][1] > curInterval[1]) {
                        //curList is the first (deepest) sublist that
                        //curInterval fits into
                        curList.push(curInterval);
                        break;
                    } else {
                        curList = sublistStack.pop();
                    }
                }
            }
        }
    }
};

NCList.prototype.binarySearch = function(arr, item, itemIndex) {
    var low = -1;
    var high = arr.length;
    var mid;

    while (high - low > 1) {
        mid = (low + high) >>> 1;
        if (arr[mid][itemIndex] > item)
            high = mid;
        else
            low = mid;
    }

    //if we're iterating rightward, return the high index;
    //if leftward, the low index
    if (1 == itemIndex) return high; else return low;
};

NCList.prototype.iterHelper = function(arr, from, to, fun, finish,
                                       inc, searchIndex, testIndex, path) {
    var len = arr.length;
    var i = this.binarySearch(arr, from, searchIndex);
    while ((i < len)
           && (i >= 0)
           && ((inc * arr[i][testIndex]) < (inc * to)) ) {

        if ("object" == typeof arr[i][this.lazyIndex]) {
            var ncl = this;
            // lazy node
            if (arr[i][this.lazyIndex].state) {
                if ("loading" == arr[i][this.lazyIndex].state) {
                    // node is currenly loading; finish this query once it
                    // has been loaded
                    finish.inc();
                    arr[i][this.lazyIndex].callbacks.push(
                        function(parentIndex) {
                            return function(o) {
                                ncl.iterHelper(o, from, to, fun, finish, inc,
                                               searchIndex, testIndex,
                                               path.concat(parentIndex));
                                finish.dec();
                            };
                        }(i)
                    );
                } else if ("loaded" == arr[i][this.lazyIndex].state) {
                    // just continue below
                } else {
                    console.log("unknown lazy type: " + arr[i]);
                }
            } else {
                // no "state" property means this node hasn't been loaded,
                // start loading
                arr[i][this.lazyIndex].state = "loading";
                arr[i][this.lazyIndex].callbacks = [];
                finish.inc();
                dojo.xhrGet(
                    {
                        url: this.baseURL +
                            this.lazyUrlTemplate.replace(
                                /\{chunk\}/g,
                                arr[i][this.lazyIndex].chunk
                            ),
                        handleAs: "json",
                        load: function(lazyFeat, lazyObj,
                                       sublistIndex, parentIndex) {
                            return function(o) {
                                lazyObj.state = "loaded";
                                lazyFeat[sublistIndex] = o;
                                ncl.iterHelper(o, from, to,
                                               fun, finish, inc,
                                               searchIndex, testIndex,
                                               path.concat(parentIndex));
                                for (var c = 0;
                                     c < lazyObj.callbacks.length;
                                     c++)
                                     lazyObj.callbacks[c](o);
                                finish.dec();
                            };
                        }(arr[i], arr[i][this.lazyIndex], this.sublistIndex, i),
                        error: function() {
                            finish.dec();
                        }
                    });
            }
        } else {
            fun(arr[i], path.concat(i));
        }

        if (arr[i][this.sublistIndex])
            this.iterHelper(arr[i][this.sublistIndex], from, to,
                            fun, finish, inc, searchIndex, testIndex,
                            path.concat(i));
        i += inc;
    }
};

NCList.prototype.iterate = function(from, to, fun, postFun) {
    // calls the given function once for each of the
    // intervals that overlap the given interval
    //if from <= to, iterates left-to-right, otherwise iterates right-to-left

    //inc: iterate leftward or rightward
    var inc = (from > to) ? -1 : 1;
    //searchIndex: search on start or end
    var searchIndex = (from > to) ? 0 : 1;
    //testIndex: test on start or end
    var testIndex = (from > to) ? 1 : 0;
    var finish = new Finisher(postFun);
    this.iterHelper(this.topList, from, to, fun, finish,
                    inc, searchIndex, testIndex, []);
    finish.finish();
};

NCList.prototype.histogram = function(from, to, numBins, callback) {
    //calls callback with a histogram of the feature density
    //in the given interval

    var result = new Array(numBins);
    var binWidth = (to - from) / numBins;
    for (var i = 0; i < numBins; i++) result[i] = 0;
    //this.histHelper(this.topList, from, to, result, numBins, (to - from) / numBins);
    this.iterate(from, to,
                 function(feat) {
	             var firstBin =
                         Math.max(0, ((feat[0] - from) / binWidth) | 0);
                     var lastBin =
                         Math.min(numBins, ((feat[1] - from) / binWidth) | 0);
	             for (var bin = firstBin; bin <= lastBin; bin++)
                         result[bin]++;
                 },
                 function() {
                     callback(result);
                 }
                 );
};

/*

Copyright (c) 2007-2009 The Evolutionary Software Foundation

Created by Mitchell Skinner <mitch_skinner@berkeley.edu>

This package and its accompanying libraries are free software; you can
redistribute it and/or modify it under the terms of the LGPL (either
version 2.1, or at your option, any later version) or the Artistic
License 2.0.  Refer to LICENSE for the full license text.

*/
function SequenceTrack(trackMeta, url, refSeq, browserParams) {
    //trackMeta: object with:
    //  key:   display text track name
    //  label: internal track name (no spaces or odd characters)
    //  className: CSS class for sequence
    //  args: object with:
    //    seqDir: directory in which to find the sequence chunks
    //    chunkSize: size of sequence chunks, in characters
    //refSeq: object with:
    //  start: refseq start
    //  end:   refseq end
    //browserParams: object with:
    //  changeCallback: function to call once JSON is loaded
    //  trackPadding: distance in px between tracks
    //  baseUrl: base URL for the URL in trackMeta
    //  charWidth: width, in pixels, of sequence base characters
    //  seqHeight: height, in pixels, of sequence elements

    Track.call(this, trackMeta.label, trackMeta.key,
               false, browserParams.changeCallback);
    this.browserParams = browserParams;
    this.trackMeta = trackMeta;
    this.setLoaded();
    this.chunks = [];
    this.chunkSize = trackMeta.args_chunkSize;
    this.baseUrl = (browserParams.baseUrl ? browserParams.baseUrl : "") + url;
}

SequenceTrack.prototype = new Track("");

SequenceTrack.prototype.startZoom = function(destScale, destStart, destEnd) {
    this.hide();
    this.heightUpdate(0);
};

SequenceTrack.prototype.endZoom = function(destScale, destBlockBases) {
    if (destScale == this.browserParams.charWidth) this.show();
    Track.prototype.clear.apply(this);
};

SequenceTrack.prototype.setViewInfo = function(genomeView, numBlocks,
                                               trackDiv, labelDiv,
                                               widthPct, widthPx, scale) {
    Track.prototype.setViewInfo.apply(this, [genomeView, numBlocks,
                                             trackDiv, labelDiv,
                                             widthPct, widthPx, scale]);
    if (scale == this.browserParams.charWidth) {
        this.show();
    } else {
        this.hide();
    }
    this.setLabel(this.key);
};

SequenceTrack.prototype.fillBlock = function(blockIndex, block,
                                             leftBlock, rightBlock,
                                             leftBase, rightBase,
                                             scale, stripeWidth,
                                             containerStart, containerEnd) {
    if (this.shown) {
        this.getRange(leftBase, rightBase,
                      function(start, end, seq) {
                          //console.log("adding seq from %d to %d: %s", start, end, seq);
                          var seqNode = document.createElement("div");
                          seqNode.className = "sequence";
                          seqNode.appendChild(document.createTextNode(seq));
	                  seqNode.style.cssText = "top: 0px;";
                          block.appendChild(seqNode);
                      });
        this.heightUpdate(this.browserParams.seqHeight, blockIndex);
    } else {
        this.heightUpdate(0, blockIndex);
    }
};

SequenceTrack.prototype.getRange = function(start, end, callback) {
    //start: start coord, in interbase
    //end: end coord, in interbase
    //callback: function that takes (start, end, seq)
    var firstChunk = Math.floor((start) / this.chunkSize);
    var lastChunk = Math.floor((end - 1) / this.chunkSize);
    var callbackInfo = {start: start, end: end, callback: callback};
    var chunkSize = this.chunkSize;
    var chunk;

    for (var i = firstChunk; i <= lastChunk; i++) {
        //console.log("working on chunk %d for %d .. %d", i, start, end);
        chunk = this.chunks[i];
        if (chunk) {
            if (chunk.loaded) {
                callback(start, end,
                         chunk.sequence.substring(start - (i * chunkSize),
                                                  end - (i * chunkSize)));
            } else {
                //console.log("added callback for %d .. %d", start, end);
                chunk.callbacks.push(callbackInfo);
            }
        } else {
            chunk = {
                loaded: false,
                num: i,
                callbacks: [callbackInfo]
            };
            this.chunks[i] = chunk;
            dojo.xhrGet({
                            url: this.baseUrl + i + ".txt",
                            load: function (response) {
                                var ci;
                                chunk.sequence = response;
                                for (var c = 0; c < chunk.callbacks.length; c++) {
                                    ci = chunk.callbacks[c];
                                    ci.callback(ci.start,
                                                ci.end,
                                                response.substring(ci.start - (chunk.num * chunkSize),
                                                                   ci.end - (chunk.num * chunkSize)));
                                }
                                chunk.callbacks = undefined;
                                chunk.loaded = true;
                            }
                        });
        }
    }
};



function CompareObjPos(nodes, touch) {
   var samePos = 0,
       j= 0,
       top = touch.pageY;
   
   for (var i=0; i < nodes.length; i++) {
      samePos = j++;
      var position = findPos(nodes[i]);
      if(position.top > top) {
         break;
      }
   }
   return samePos;
}

function checkAvatarPosition(first) {
      var leftPane = document.getElementById("tracksAvail"),
          rigthPane = document.getElementById("container");
     
       if (first.pageX < (leftPane.offsetLeft + leftPane.offsetWidth)) 
        {
         return leftPane;
         }
      else {
        return rigthPane;
        }
}  

var startX;

function removeTouchEvents() {

startX = null;

}


function touchSimulated(event)
{
    if(event.touches.length <= 1) {
   
        var touches = event.changedTouches,
            first = touches[0],
            type1 = "",
            type2 = "mouseover",
            objAvatar = document.getElementsByClassName("dojoDndAvatar"),
            obj = {},
            pane = checkAvatarPosition(first),
            nodes = pane.getElementsByClassName("dojoDndItem"),
            element = {},  
            simulatedEvent_1 = document.createEvent("MouseEvent"),
            simulatedEvent_2 = document.createEvent("MouseEvent");
            

               switch (event.type) {
            
                case "touchstart": 
                    startX = first.pageX;
                    type1 = "mousedown";
                    break;
        
                case "touchmove": 
                    event.preventDefault();
                    type1 = "mousemove";
                    break;
            
                default:
                return;
              }
            

            
            
        
    
    simulatedEvent_1.initMouseEvent(type1, true, true, window, 1, first.pageX, first.pageY, first.clientX,              first.clientY,
                                  false, false, false, false, 0, null);
                                                                            

simulatedEvent_2.initMouseEvent(type2, true, true, window, 1, first.pageX, first.pageY, first.clientX, first.clientY,
                               false, false, false, false, 0, null);
     
                        
                     
    
    switch (event.type) {
            
                case "touchstart": 
                    first.target.dispatchEvent(simulatedEvent_1);
                    first.target.dispatchEvent(simulatedEvent_2);
                    initialPane = pane;
                    break;
                case "touchmove": 
                    
                    if(objAvatar.length > 0) {
                        if (nodes.length > 0) {
                            element = CompareObjPos(nodes,first);
                            obj = nodes[element];
                        }
     
                        try {
                            
                            if (initialPane != pane) {
                                var simulatedEvent_3 = document.createEvent("MouseEvent");
                                var type3 = "mouseout";
                                simulatedEvent_3.initMouseEvent(type3, true, true, window, 1, 
                                first.pageX, first.pageY, first.clientX, first.clientY,
                                false, false, false, false, 0, null);
                                initialPane.dispatchEvent(simulatedEvent_3);
                            }
                           obj.dispatchEvent(simulatedEvent_2);
                             obj.dispatchEvent(simulatedEvent_1);
                        
                        }
                        catch(err) 
                        {
                            //No Elements in the pane
                            pane.dispatchEvent(simulatedEvent_2);
                            pane.dispatchEvent(simulatedEvent_1);
                        }
                    }
                    break;
                            
                default:
                return;
            }
       
  }
  else {
   removeTouchEvents();
   } 
}

function touchEnd(event) {
         
        
         
        var touches = event.changedTouches,
            first = touches[0],
            type1 = "mouseup",
            type2 = "mouseover",
            objAvatar = document.getElementsByClassName("dojoDndAvatar"),
            obj = {},
            pane = checkAvatarPosition(first),
            nodes = pane.getElementsByClassName("dojoDndItem"),
            element = {},  
            simulatedEvent_1 = document.createEvent("MouseEvent"),
            simulatedEvent_2 = document.createEvent("MouseEvent");
            
            
             if (startX !==  first.pageX) {
             //slide ocurrs
             event.preventDefault();
             }
            
            var test = findPos(first.target);
            
simulatedEvent_1.initMouseEvent(type1, true, true, window, 1, first.pageX, first.pageY, first.clientX,              first.clientY,
                                  false, false, false, false, 0, null);
                                                                            

simulatedEvent_2.initMouseEvent(type2, true, true, window, 1, first.pageX, first.pageY, first.clientX, first.clientY,
                               false, false, false, false, 0, null);




                    if(objAvatar.length > 0) {   
                        if (nodes.length > 0) {
                           element = CompareObjPos(nodes,first);
                            obj = nodes[element];
                         }
                                                                                   
                        try {
                            obj.dispatchEvent(simulatedEvent_2);
                            obj.dispatchEvent(simulatedEvent_1);
                            }
                        catch(error) 
                            {
                            first.target.dispatchEvent(simulatedEvent_2);
                            pane.dispatchEvent(simulatedEvent_2);
                            }    
                        }
                    else {
                            first.target.dispatchEvent(simulatedEvent_1);
                            first.target.dispatchEvent(simulatedEvent_2);
                        }



   removeTouchEvents();
}

function touchHandle(event)
{
 
    dojo.query(".dojoDndItemAnchor").connect("touchstart", touchSimulated);
    dojo.query(".dojoDndItemAnchor").connect("touchmove", touchSimulated);
    dojo.query(".dojoDndItemAnchor").connect("touchend", touchEnd); 
    dojo.query(".dojoDndItemAnchor").connect("click" , function(){void(0);});
   
     if(event.touches.length <= 1) {
   
     
		 var touches = event.changedTouches,
		 first = touches[0],
		 type = "";
		 
		 
		 
		 switch(event.type)
		 {
			 case "touchstart": 
				 startX = first.pageX;
				 type = "mousedown";
				 break;
				 
			 case "touchmove": 
				 event.preventDefault();
				 type = "mousemove";
				 break;
				 
			 case "touchend": 
				 if (startX !==  first.pageX) {
					 //slide ocurrs
					 event.preventDefault();
				 }
				 type = "mouseup";
				 break;
				 
				 
			 default:
				 return;
		 }
		 
		 
		 var simulatedEvent = document.createEvent("MouseEvent");
		 
		 simulatedEvent.initMouseEvent(type, true, true, window, 1, first.screenX, first.screenY, first.clientX, first.clientY,
									   false, false, false, false, 0/*left*/, null);
		 
		 first.target.dispatchEvent(simulatedEvent);
		 
	 }
	 else {
   removeTouchEvents();
   }
}




function touchinit() 
{
    dojo.query(".dojoDndItem").connect("touchstart", touchSimulated);
    dojo.query(".dojoDndItem").connect("touchmove", touchSimulated);
    dojo.query(".dojoDndItem").connect("touchend", touchEnd);
    
    dojo.query(".locationThumb").connect("touchstart", touchHandle);
    dojo.query(".locationThumb").connect("touchmove", touchHandle);
    dojo.query(".locationThumb").connect("touchend", touchHandle);
    
    dojo.query(".dojoDndItem").connect("click" , function(){void(0);});
    
    dojo.query(".dojoDndTarget").connect("touchstart", touchHandle);
    dojo.query(".dojoDndTarget").connect("touchmove", touchHandle);
    dojo.query(".dojoDndTarget").connect("touchend", touchHandle);
    
    dojo.query(".dijitSplitter").connect("touchstart", touchHandle);
    dojo.query(".dijitSplitter").connect("touchmove", touchHandle);
    dojo.query(".dijitSplitter").connect("touchend", touchHandle);
    
 }


function load()
{
  
    touchinit();
    document.documentElement.style.webkitTouchCallout = "none";
}

function findPos(obj) {
    var curtop = 0,
        objP = {};
	
    if (obj.offsetParent) {
	do {
			curtop += obj.offsetTop;
        } while ((obj = obj.offsetParent));
}

objP.top = curtop;

return objP;
}
function Track(name, key, loaded, changeCallback) {
    this.name = name;
    this.key = key;
    this.loaded = loaded;
    this.changed = changeCallback;
    this.height = 0;
    this.shown = true;
    this.empty = false;
}

Track.prototype.load = function(url) {
    var curTrack = this;
    dojo.xhrGet({url: url,
                 handleAs: "json",
                 load: function(o) { curTrack.loadSuccess(o); },
                 error: function(o) { curTrack.loadFail(o); }
	        });
};

Track.prototype.loadFail = function(error) {
    this.empty = true;
    this.setLoaded();
};

Track.prototype.setViewInfo = function(heightUpdate, numBlocks,
                                       trackDiv, labelDiv,
                                       widthPct, widthPx, scale) {
    var track = this;
    this.heightUpdate = function(height, blockIndex) {
        if (!this.shown) {
            heightUpdate(0);
            return;
        }
        if (blockIndex !== undefined) track.blockHeights[blockIndex] = height;

        track.height = Math.max(track.height, height);
        if (!track.inShowRange) {
            heightUpdate(Math.max(track.labelHeight, track.height));
        }
    };
    this.div = trackDiv;
    this.label = labelDiv;
    this.widthPct = widthPct;
    this.widthPx = widthPx;

    this.leftBlank = document.createElement("div");
    this.leftBlank.className = "blank-block";
    this.rightBlank = document.createElement("div");
    this.rightBlank.className = "blank-block";
    this.div.appendChild(this.rightBlank);
    this.div.appendChild(this.leftBlank);

    this.sizeInit(numBlocks, widthPct);
    this.labelHTML = "";
    this.labelHeight = 0;
};

Track.prototype.hide = function() {
    if (this.shown) {
        this.div.style.display = "none";
        this.shown = false;
    }
};

Track.prototype.show = function() {
    if (!this.shown) {
        this.div.style.display = "block";
        this.shown = true;
    }
};

Track.prototype.initBlocks = function() {
    this.blocks = new Array(this.numBlocks);
    this.blockHeights = new Array(this.numBlocks);
    for (var i = 0; i < this.numBlocks; i++) this.blockHeights[i] = 0;
    this.firstAttached = null;
    this.lastAttached = null;
    this._adjustBlanks();
};

Track.prototype.clear = function() {
    if (this.blocks) {
        for (var i = 0; i < this.numBlocks; i++)
            this._hideBlock(i);
    }
    this.initBlocks();
};


Track.prototype.setLabel = function(newHTML) {
    if (this.label === undefined) return;

    if (this.labelHTML == newHTML) return;
    this.labelHTML = newHTML;
    if(this.label.children.length < 2) {
        var labelText = document.createElement("span");
        labelText.style.cssText = "display: inline; vertical-align: middle;";
        labelText.innerHTML = newHTML;
        this.label.appendChild(labelText);
        this.labelHeight = this.label.offsetHeight;
        this.deleteButtonContainer = labelText;
    } 
    else {
        this.label.children[1].innerHTML = newHTML;
    }
};

Track.prototype.transfer = function() {};

Track.prototype.startZoom = function(destScale, destStart, destEnd) {};
Track.prototype.endZoom = function(destScale, destBlockBases) {};

Track.prototype.showRange = function(first, last, startBase, bpPerBlock, scale,
                                     containerStart, containerEnd) {
    if (this.blocks === undefined) return 0;

    // this might make more sense in setViewInfo, but the label element
    // isn't in the DOM tree yet at that point
    if ((this.labelHeight == 0) && this.label)
        this.labelHeight = this.label.offsetHeight;

    this.inShowRange = true;
    this.height = this.labelHeight;

    var firstAttached = (null == this.firstAttached ? last + 1 : this.firstAttached);
    var lastAttached =  (null == this.lastAttached ? first - 1 : this.lastAttached);

    var i, leftBase;
    var maxHeight = 0;
    //fill left, including existing blocks (to get their heights)
    for (i = lastAttached; i >= first; i--) {
        leftBase = startBase + (bpPerBlock * (i - first));
        this._showBlock(i, leftBase, leftBase + bpPerBlock, scale,
                        containerStart, containerEnd);
    }
    //fill right
    for (i = lastAttached + 1; i <= last; i++) {
        leftBase = startBase + (bpPerBlock * (i - first));
        this._showBlock(i, leftBase, leftBase + bpPerBlock, scale,
                        containerStart, containerEnd);
    }

    //detach left blocks
    var destBlock = this.blocks[first];
    for (i = firstAttached; i < first; i++) {
        this.transfer(this.blocks[i], destBlock, scale,
                      containerStart, containerEnd);
        this.cleanupBlock(this.blocks[i]);
        this._hideBlock(i);
    }
    //detach right blocks
    destBlock = this.blocks[last];
    for (i = lastAttached; i > last; i--) {
        this.transfer(this.blocks[i], destBlock, scale,
                      containerStart, containerEnd);
        this.cleanupBlock(this.blocks[i]);
        this._hideBlock(i);
    }

    this.firstAttached = first;
    this.lastAttached = last;
    this._adjustBlanks();
    this.inShowRange = false;
    this.heightUpdate(this.height);
};

Track.prototype.cleanupBlock = function() {};

Track.prototype._hideBlock = function(blockIndex) {
    if (this.blocks[blockIndex]) {
        this.div.removeChild(this.blocks[blockIndex]);
        this.blocks[blockIndex] = undefined;
        this.blockHeights[blockIndex] = 0;
    }
};

Track.prototype._adjustBlanks = function() {
    if ((this.firstAttached === null)
        || (this.lastAttached === null)) {
        this.leftBlank.style.left = "0px";
        this.leftBlank.style.width = "50%";
        this.rightBlank.style.left = "50%";
        this.rightBlank.style.width = "50%";
    } else {
        this.leftBlank.style.width = (this.firstAttached * this.widthPct) + "%";
        this.rightBlank.style.left = ((this.lastAttached + 1)
                                      * this.widthPct) + "%";
        this.rightBlank.style.width = ((this.numBlocks - this.lastAttached - 1)
                                       * this.widthPct) + "%";
    }
};

Track.prototype.hideAll = function() {
    if (null == this.firstAttached) return;
    for (var i = this.firstAttached; i <= this.lastAttached; i++)
        this._hideBlock(i);


    this.firstAttached = null;
    this.lastAttached = null;
    this._adjustBlanks();
    //this.div.style.backgroundColor = "#eee";
};

Track.prototype.setLoaded = function() {
    this.loaded = true;
    this.hideAll();
    this.changed();
};

Track.prototype._loadingBlock = function(blockDiv) {
    blockDiv.appendChild(document.createTextNode("Loading..."));
    blockDiv.style.backgroundColor = "#eee";
    return 50;
};

Track.prototype._showBlock = function(blockIndex, startBase, endBase, scale,
                                      containerStart, containerEnd) {
    if (this.blocks[blockIndex]) {
        this.heightUpdate(this.blockHeights[blockIndex], blockIndex);
        return;
    }
    if (this.empty) {
        this.heightUpdate(this.labelHeight, blockIndex);
        return;
    }

    var blockDiv = document.createElement("div");
    blockDiv.className = "block";
    blockDiv.style.left = (blockIndex * this.widthPct) + "%";
    blockDiv.style.width = this.widthPct + "%";
    blockDiv.startBase = startBase;
    blockDiv.endBase = endBase;
    if (this.loaded) {
        this.fillBlock(blockIndex,
                       blockDiv,
                       this.blocks[blockIndex - 1],
                       this.blocks[blockIndex + 1],
                       startBase,
                       endBase,
                       scale,
                       this.widthPx,
                       containerStart,
                       containerEnd);
    } else {
         this._loadingBlock(blockDiv);
    }

    this.blocks[blockIndex] = blockDiv;
    this.div.appendChild(blockDiv);
};

Track.prototype.moveBlocks = function(delta) {
    var newBlocks = new Array(this.numBlocks);
    var newHeights = new Array(this.numBlocks);
    var i;
    for (i = 0; i < this.numBlocks; i++)
        newHeights[i] = 0;

    var destBlock;
    if ((this.lastAttached + delta < 0)
        || (this.firstAttached + delta >= this.numBlocks)) {
        this.firstAttached = null;
        this.lastAttached = null;
    } else {
        this.firstAttached = Math.max(0, Math.min(this.numBlocks - 1,
                                                 this.firstAttached + delta));
        this.lastAttached = Math.max(0, Math.min(this.numBlocks - 1,
                                                  this.lastAttached + delta));
        if (delta < 0)
            destBlock = this.blocks[this.firstAttached - delta];
        else
            destBlock = this.blocks[this.lastAttached - delta];
    }

    for (i = 0; i < this.blocks.length; i++) {
        var newIndex = i + delta;
        if ((newIndex < 0) || (newIndex >= this.numBlocks)) {
            //We're not keeping this block around, so delete
            //the old one.
            if (destBlock && this.blocks[i])
                this.transfer(this.blocks[i], destBlock);
            this._hideBlock(i);
        } else {
            //move block
            newBlocks[newIndex] = this.blocks[i];
            if (newBlocks[newIndex])
                newBlocks[newIndex].style.left =
                    ((newIndex) * this.widthPct) + "%";

            newHeights[newIndex] = this.blockHeights[i];
        }
    }
    this.blocks = newBlocks;
    this.blockHeights = newHeights;
    this._adjustBlanks();
};

Track.prototype.sizeInit = function(numBlocks, widthPct, blockDelta) {
    var i, oldLast;
    this.numBlocks = numBlocks;
    this.widthPct = widthPct;
    if (blockDelta) this.moveBlocks(-blockDelta);
    if (this.blocks && (this.blocks.length > 0)) {
        //if we're shrinking, clear out the end blocks
        var destBlock = this.blocks[numBlocks - 1];
        for (i = numBlocks; i < this.blocks.length; i++) {
            if (destBlock && this.blocks[i])
                this.transfer(this.blocks[i], destBlock);
            this._hideBlock(i);
        }
        oldLast = this.blocks.length;
        this.blocks.length = numBlocks;
        this.blockHeights.length = numBlocks;
        //if we're expanding, set new blocks to be not there
        for (i = oldLast; i < numBlocks; i++) {
            this.blocks[i] = undefined;
            this.blockHeights[i] = 0;
        }
        this.lastAttached = Math.min(this.lastAttached, numBlocks - 1);
        if (this.firstAttached > this.lastAttached) {
            //not sure if this can happen
            this.firstAttached = null;
            this.lastAttached = null;
        }

        if (this.blocks.length != numBlocks) throw new Error("block number mismatch: should be " + numBlocks + "; blocks.length: " + this.blocks.length);
        for (i = 0; i < numBlocks; i++) {
            if (this.blocks[i]) {
                //if (!this.blocks[i].style) console.log(this.blocks);
                this.blocks[i].style.left = (i * widthPct) + "%";
                this.blocks[i].style.width = widthPct + "%";
            }
        }
    } else {
        this.initBlocks();
    }
};

/*

Copyright (c) 2007-2009 The Evolutionary Software Foundation

Created by Mitchell Skinner <mitch_skinner@berkeley.edu>

This package and its accompanying libraries are free software; you can
redistribute it and/or modify it under the terms of the LGPL (either
version 2.1, or at your option, any later version) or the Artistic
License 2.0.  Refer to LICENSE for the full license text.

*/
//This track is for (e.g.) position and sequence information that should
//always stay visible at the top of the view

function StaticTrack(name, labelClass, posHeight) {
    Track.call(this, name, name, true, function() {});
    this.labelClass = labelClass;
    this.posHeight = posHeight;
    this.height = posHeight;
}

StaticTrack.prototype = new Track("");

StaticTrack.prototype.fillBlock = function(blockIndex, block,
                                           leftBlock, rightBlock,
					   leftBase, rightBase, scale,
					   padding, stripeWidth) {
    var posLabel = document.createElement("div");
    posLabel.className = this.labelClass;
    posLabel.appendChild(document.createTextNode(Util.addCommas(leftBase)));
    posLabel.style.top = "0px";// y + "px";
    block.appendChild(posLabel);
    this.heightUpdate(this.posHeight, blockIndex);
};

//This track is for drawing the vertical gridlines

function GridTrack(name) {
    Track.call(this, name, name, true, function() {});
}

GridTrack.prototype = new Track("");

GridTrack.prototype.fillBlock = function(blockIndex, block,
                                         leftBlock, rightBlock,
                                         leftBase, rightBase, scale,
                                         padding, stripeWidth) {
    var gridline = document.createElement("div");
    gridline.className = "gridline";
    gridline.style.cssText = "left: 0%; width: 0px;";
    block.appendChild(gridline);
    this.heightUpdate(100, blockIndex);
};

/*

Copyright (c) 2007-2009 The Evolutionary Software Foundation

Created by Mitchell Skinner <mitch_skinner@berkeley.edu>

This package and its accompanying libraries are free software; you can
redistribute it and/or modify it under the terms of the LGPL (either
version 2.1, or at your option, any later version) or the Artistic
License 2.0.  Refer to LICENSE for the full license text.

*/
var Util = {};

Util.is_ie = navigator.appVersion.indexOf('MSIE') >= 0;
Util.is_ie6 = navigator.appVersion.indexOf('MSIE 6') >= 0;
Util.addCommas = function(nStr)
{
	nStr += '';
	x = nStr.split('.');
	x1 = x[0];
	x2 = x.length > 1 ? '.' + x[1] : '';
	var rgx = /(\d+)(\d{3})/;
	while (rgx.test(x1)) {
		x1 = x1.replace(rgx, '$1' + ',' + '$2');
	}
	return x1 + x2;
}

Util.wheel = function(event){
    var delta = 0;
    if (!event) event = window.event;
    if (event.wheelDelta) {
        delta = event.wheelDelta/120;
        if (window.opera) delta = -delta;
    } else if (event.detail) { delta = -event.detail/3;	}
    return Math.round(delta); //Safari Round
}

Util.isRightButton = function(e) {
    if (!e) var e = window.event;
    if (e.which) return e.which == 3;
    else if (e.button) return e.button == 2;
}

Util.getViewportWidth = function() {
  var width = 0;
  if( document.documentElement && document.documentElement.clientWidth ) {
    width = document.documentElement.clientWidth;
  }
  else if( document.body && document.body.clientWidth ) {
    width = document.body.clientWidth;
  }
  else if( window.innerWidth ) {
    width = window.innerWidth - 18;
  }
  return width;
};

Util.getViewportHeight = function() {
  var height = 0;
  if( document.documentElement && document.documentElement.clientHeight ) {
    height = document.documentElement.clientHeight;
  }
  else if( document.body && document.body.clientHeight ) {
    height = document.body.clientHeight;
  }
  else if( window.innerHeight ) {
    height = window.innerHeight - 18;
  }
  return height;
};

Util.findNearest = function(numArray, num) {
    var minIndex = 0;
    var min = Math.abs(num - numArray[0]);
    for (var i = 0; i < numArray.length; i++) {
        if (Math.abs(num - numArray[i]) < min) {
            minIndex = i;
            min = Math.abs(num - numArray[i]);
        }
    }
    return minIndex;
}

if (!Array.prototype.reduce)
{
  Array.prototype.reduce = function(fun /*, initial*/)
  {
    var len = this.length;
    if (typeof fun != "function")
      throw new TypeError();

    // no value to return if no initial value and an empty array
    if (len == 0 && arguments.length == 1)
      throw new TypeError();

    var i = 0;
    if (arguments.length >= 2)
    {
      var rv = arguments[1];
    }
    else
    {
      do
      {
        if (i in this)
        {
          rv = this[i++];
          break;
        }

        // if array contains no values, no initial value to return
        if (++i >= len)
          throw new TypeError();
      }
      while (true);
    }

    for (; i < len; i++)
    {
      if (i in this)
        rv = fun.call(null, rv, this[i], i, this);
    }

    return rv;
  };
}

function Finisher(fun) {
    this.fun = fun;
    this.count = 0;
}

Finisher.prototype.inc = function() {
    this.count++;
};

Finisher.prototype.dec = function() {
    this.count--;
    this.finish();
};

Finisher.prototype.finish = function() {
    if (this.count <= 0) this.fun();
};

/*

Copyright (c) 2007-2010 The Evolutionary Software Foundation

Created by Mitchell Skinner <mitch_skinner@berkeley.edu>

This package and its accompanying libraries are free software; you can
redistribute it and/or modify it under the terms of the LGPL (either
version 2.1, or at your option, any later version) or the Artistic
License 2.0.  Refer to LICENSE for the full license text.

*/


