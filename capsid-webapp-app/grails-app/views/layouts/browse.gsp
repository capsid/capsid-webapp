<%@ page import="ca.on.oicr.capsid.User" %>
<!doctype html>
<html>
  <head>
    <meta http-equiv="Content-Type" content = "text/html; charset=utf-8">
	<g:set var="user" value="${User.findByUsername(sec?.username())}" />
    <title><g:layoutTitle default="${meta(name: 'app.name')}"/></title>


    <link rel="stylesheet" type="text/css" href="${resource(dir:'css', 'genome.css')}">
    <script type="text/javascript" charset="utf-8" src="${resource(dir:'js/dojo/nls',file:'dojo_en-us.js')}" data-dojo-config="async: 1"></script>
    <script type="text/javascript" src="${resource(dir:'js/dojo',file:'dojo.js')}" data-dojo-config="async: 1"></script>

    <script type="text/javascript">
        window.onerror=function(msg){
            if( document.body )
                document.body.setAttribute("JSError",msg);
        }

        var JBrowse;
        require( { baseUrl: 'src',
                   packages: [ 'dojo', 'dijit', 'dojox', 'jszlib',
                               { name: 'lazyload', main: 'lazyload' },
                               'dgrid', 'xstyle', 'put-selector',
                               { name: 'jDataView', location: 'jDataView/src', main: 'jdataview' },
                               'JBrowse', 'FileSaver'
                             ]
                 },
            [ 'JBrowse/Browser', 'dojo/io-query', 'dojo/json' ],
            function (Browser,ioQuery,JSON) {
                   var queryParams = ioQuery.queryToObject( window.location.search.slice(1) );
                   var dataRoot = queryParams.data || 'data';

                   // the initial configuration of this JBrowse instance
                   var config = {
                       containerID: "GenomeBrowser",
                       refSeqs: dataRoot + "/seq/refSeqs.json",
                       baseUrl: dataRoot+'/',
                       include: [
                           'jbrowse_conf.json',
                           dataRoot + "/trackList.json"
                       ],
                       nameUrl: dataRoot + "/names/root.json",
                       queryParams: queryParams,
                       location: queryParams.loc,
                       forceTracks: queryParams.tracks,
                       initialHighlight: queryParams.highlight,
                       show_nav: queryParams.nav,
                       show_tracklist: queryParams.tracklist,
                       show_overview: queryParams.overview,
                       stores: { url: { type: "JBrowse/Store/SeqFeature/FromConfig", features: [] } },
                       makeFullViewURL: function( browser ) {

                           // the URL for the 'Full view' link
                           // in embedded mode should be the current
                           // view URL, except with 'nav', 'tracklist',
                           // and 'overview' parameters forced to 1.

                           return browser.makeCurrentViewURL({ nav: 1, tracklist: 1, overview: 1 });
                       },
                       updateBrowserURL: true
                   };

                   //if there is ?addFeatures in the query params,
                   //define a store for data from the URL
                   if( queryParams.addFeatures ) {
                       config.stores.url.features = JSON.parse( queryParams.addFeatures );
                   }

                   // if there is ?addTracks in the query params, add
                   // those track configurations to our initial
                   // configuration
                   if( queryParams.addTracks ) {
                       config.tracks = JSON.parse( queryParams.addTracks );
                   }

                   // if there is ?addStores in the query params, add
                   // those store configurations to our initial
                   // configuration
                   if( queryParams.addStores ) {
                       config.stores = JSON.parse( queryParams.addStores );
                   }

                   // create a JBrowse global variable holding the JBrowse instance
                   JBrowse = new Browser( config );
        });
    </script>

  </head>

  <body>
    <div id="GenomeBrowser" style="height: 100%; width: 100%; padding: 0; border: 0;"></div>
    <div style="display: none">JBrowseDefaultMainPage</div>
  </body>
</html>
