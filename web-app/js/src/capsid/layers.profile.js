// this file is located at:
//
//      <server root>/js/src/mylayer.profile.js
//
    // This profile is used just to illustrate the layout of a layered build.
    // All layers have an implicit dependency on dojo.js.
//
// Normally you should not specify a layer object for dojo.js, as it will
// be built by default with the right options. Custom dojo.js files are
// possible, but not recommended for most apps.

    dependencies = {
            layers: [
                     {
            // where the output file goes, relative to the dojo dir
                            name: "../dijit/dijit.js",
            // what the module's name will be, i.e., what gets generated
            // for dojo.provide(<name here>);
                            resourceName: "dijit.dijit",
            // modules not to include code for
                            layerDependencies: [
                            ],
            // modules to use as the "source" for this layer
                            dependencies: [
                            ]
                    },
                    {
            // where the output file goes, relative to the dojo dir
                            name: "../dojox/dojox.js",
            // what the module's name will be, i.e., what gets generated
            // for dojo.provide(<name here>);
                            resourceName: "dojox.dojox",
            // modules not to include code for
                            layerDependencies: [
                                    "dijit.dijit"
                            ],
            // modules to use as the "source" for this layer
                            dependencies: [
                            ]
                    },
        {
            // where to put the output relative to the Dojo root in a build
            name: "../capsid/capsid.js",
            // what to name it (redundant w/ or example layer)
            resourceName: "capsid.capsid",
            // what other layers to assume will have already been loaded
            // specifying modules here prevents them from being included in
            // this layer's output file
                            layerDependencies: [
                                   "dijit.dijit",
                                   "dojox.dojox"
                            ],
            // which modules to pull in. All of the dependencies not
            // provided by dojo.js or other items in the "layerDependencies"
            // array are also included.
                            dependencies: [
                                // our acme.mylayer specifies all the stuff our app will
                                // need, so we don't need to list them all out here.
                                'capsid.capsid',
                            ]
        }
    ],

    prefixes: [
        // the system knows where to find the "dojo/" directory, but we
        // need to tell it about everything else. Directories listed here
        // are, at a minimum, copied to the build directory.
        [ "dijit", "../dijit" ],
        [ "dojox", "../dojox" ],
        [ "capsid", "../../capsid" ]
    ]
}
