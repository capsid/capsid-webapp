//>>built
require({cache:{"JBrowse/Model/DataView":function(){define("JBrowse/Model/DataView",["jDataView"],function(k){var f=function(){k.apply(this,arguments)};try{f.prototype=new k(new ArrayBuffer([1]),0,1)}catch(b){console.error(b)}f.prototype.getUint64Approx=function(a,b){var i=this._getBytes(8,a,b),g=i[0]*Math.pow(2,56)+i[1]*Math.pow(2,48)+i[2]*Math.pow(2,40)+i[3]*Math.pow(2,32)+i[4]*Math.pow(2,24)+(i[5]<<16)+(i[6]<<8)+i[7];if(i[0]||i[1]&224)g=new Number(g),g.overflow=!0;return g};f.prototype.getUint64=
function(a,b){var i=this.getUint64Approx(a,b);if(i.overflow)throw"integer overflow";return i};return f})},"jDataView/jdataview":function(){define([],function(){var k={};(function(f){var b={ArrayBuffer:"undefined"!==typeof ArrayBuffer,DataView:"undefined"!==typeof DataView&&("getFloat64"in DataView.prototype||"getFloat64"in new DataView(new ArrayBuffer(1))),NodeBuffer:"undefined"!==typeof Buffer&&"readInt16LE"in Buffer.prototype},a={Int8:1,Int16:2,Int32:4,Uint8:1,Uint16:2,Uint32:4,Float32:4,Float64:8},
d={Int8:"Int8",Int16:"Int16",Int32:"Int32",Uint8:"UInt8",Uint16:"UInt16",Uint32:"UInt32",Float32:"Float",Float64:"Double"},i=function(g,o,c,q){if(!(this instanceof i))throw Error("jDataView constructor may not be called as a function");this.buffer=g;if(!(b.NodeBuffer&&g instanceof Buffer)&&!(b.ArrayBuffer&&g instanceof ArrayBuffer)&&"string"!==typeof g)throw new TypeError("jDataView buffer has an incompatible type");this._isArrayBuffer=b.ArrayBuffer&&g instanceof ArrayBuffer;this._isDataView=b.DataView&&
this._isArrayBuffer;this._isNodeBuffer=b.NodeBuffer&&g instanceof Buffer;this._littleEndian=Boolean(q);var j=this._isArrayBuffer?g.byteLength:g.length;void 0===o&&(o=0);this.byteOffset=o;void 0===c&&(c=j-o);this.byteLength=c;if(!this._isDataView){if("number"!==typeof o)throw new TypeError("jDataView byteOffset is not a number");if("number"!==typeof c)throw new TypeError("jDataView byteLength is not a number");if(0>o)throw Error("jDataView byteOffset is negative");if(0>c)throw Error("jDataView byteLength is negative");
}if(this._isDataView)this._view=new DataView(g,o,c),this._start=0;this._start=o;if(o+c>j)throw Error("jDataView (byteOffset + byteLength) value is out of bounds");this._offset=0;if(this._isDataView)for(var l in a)a.hasOwnProperty(l)&&function(j,e){var h=a[j];e["get"+j]=function(n,c){if(void 0===c)c=e._littleEndian;if(void 0===n)n=e._offset;e._offset=n+h;return e._view["get"+j](n,c)}}(l,this);else if(this._isNodeBuffer&&b.NodeBuffer)for(l in a)a.hasOwnProperty(l)&&function(j,e,h){var c=a[j];e["get"+
j]=function(j){if(void 0===j)j=e._offset;e._offset=j+c;return e.buffer[h](e._start+j)}}(l,this,"Int8"===l||"Uint8"===l?"read"+d[l]:q?"read"+d[l]+"LE":"read"+d[l]+"BE");else for(l in a)a.hasOwnProperty(l)&&function(j,e){var h=a[j];e["get"+j]=function(c,g){if(void 0===g)g=e._littleEndian;if(void 0===c)c=e._offset;e._offset=c+h;if(e._isArrayBuffer&&0===(e._start+c)%h&&(1===h||g))return(new f[j+"Array"](e.buffer,e._start+c,1))[0];if("number"!==typeof c)throw new TypeError("jDataView byteOffset is not a number");
if(c+h>e.byteLength)throw Error("jDataView (byteOffset + size) value is out of bounds");return e["_get"+j](e._start+c,g)}}(l,this)};i.createBuffer=b.NodeBuffer?function(){return new Buffer(arguments)}:b.ArrayBuffer?function(){return(new Uint8Array(arguments)).buffer}:function(){return String.fromCharCode.apply(null,arguments)};i.prototype={compatibility:b,_getBytes:function(g,b,c){var a;if(void 0===c)c=this._littleEndian;if(void 0===b)b=this._offset;if("number"!==typeof b)throw new TypeError("jDataView byteOffset is not a number");
if(0>g||b+g>this.byteLength)throw Error("jDataView length or (byteOffset+length) value is out of bounds");b+=this._start;this._isArrayBuffer?a=new Uint8Array(this.buffer,b,g):(a=this.buffer.slice(b,b+g),this._isNodeBuffer||(a=Array.prototype.map.call(a,function(j){return j.charCodeAt(0)&255})));c&&1<g&&(a instanceof Array||(a=Array.prototype.slice.call(a)),a.reverse());this._offset=b-this._start+g;return a},getBytes:function(g,b,c){var a=this._getBytes.apply(this,arguments);a instanceof Array||(a=
Array.prototype.slice.call(a));return a},getString:function(g,a){var c;if(this._isNodeBuffer){if(void 0===a)a=this._offset;if("number"!==typeof a)throw new TypeError("jDataView byteOffset is not a number");if(0>g||a+g>this.byteLength)throw Error("jDataView length or (byteOffset+length) value is out of bounds");c=this.buffer.toString("ascii",this._start+a,this._start+a+g);this._offset=a+g}else c=String.fromCharCode.apply(null,this._getBytes(g,a,!1));return c},getChar:function(a){return this.getString(1,
a)},tell:function(){return this._offset},seek:function(a){if("number"!==typeof a)throw new TypeError("jDataView byteOffset is not a number");if(0>a||a>this.byteLength)throw Error("jDataView byteOffset value is out of bounds");return this._offset=a},_getFloat64:function(a,b){var c=this._getBytes(8,a,b),d=1-2*(c[0]>>7),j=((c[0]<<1&255)<<3|c[1]>>4)-(Math.pow(2,10)-1),c=(c[1]&15)*Math.pow(2,48)+c[2]*Math.pow(2,40)+c[3]*Math.pow(2,32)+c[4]*Math.pow(2,24)+c[5]*Math.pow(2,16)+c[6]*Math.pow(2,8)+c[7];return 1024===
j?0!==c?NaN:Infinity*d:-1023===j?d*c*Math.pow(2,-1074):d*(1+c*Math.pow(2,-52))*Math.pow(2,j)},_getFloat32:function(a,b){var c=this._getBytes(4,a,b),d=1-2*(c[0]>>7),j=(c[0]<<1&255|c[1]>>7)-127,c=(c[1]&127)<<16|c[2]<<8|c[3];return 128===j?0!==c?NaN:Infinity*d:-127===j?d*c*Math.pow(2,-149):d*(1+c*Math.pow(2,-23))*Math.pow(2,j)},_getInt32:function(a,b){var c=this._getUint32(a,b);return c>Math.pow(2,31)-1?c-Math.pow(2,32):c},_getUint32:function(a,b){var c=this._getBytes(4,a,b);return c[0]*Math.pow(2,24)+
(c[1]<<16)+(c[2]<<8)+c[3]},_getInt16:function(a,b){var c=this._getUint16(a,b);return c>Math.pow(2,15)-1?c-Math.pow(2,16):c},_getUint16:function(a,b){var c=this._getBytes(2,a,b);return(c[0]<<8)+c[1]},_getInt8:function(a){a=this._getUint8(a);return a>Math.pow(2,7)-1?a-Math.pow(2,8):a},_getUint8:function(a){return this._getBytes(1,a)[0]}};"undefined"!==typeof jQuery&&"1.6.2"<=jQuery.fn.jquery&&(jQuery.ajaxSetup({converters:{"* dataview":function(a){return new i(a)}},accepts:{dataview:"text/plain; charset=x-user-defined"},
responseHandler:{dataview:function(a,b,c){var d;if("mozResponseArrayBuffer"in c)d=c.mozResponseArrayBuffer;else if("responseType"in c&&"arraybuffer"===c.responseType&&c.response)d=c.response;else if("responseBody"in c){b=c.responseBody;try{d=IEBinaryToArray_ByteStr(b)}catch(j){window.execScript("Function IEBinaryToArray_ByteStr(Binary)\r\n\tIEBinaryToArray_ByteStr = CStr(Binary)\r\nEnd Function\r\nFunction IEBinaryToArray_ByteStr_Last(Binary)\r\n\tDim lastIndex\r\n\tlastIndex = LenB(Binary)\r\n\tif lastIndex mod 2 Then\r\n\t\tIEBinaryToArray_ByteStr_Last = AscB( MidB( Binary, lastIndex, 1 ) )\r\n\tElse\r\n\t\tIEBinaryToArray_ByteStr_Last = -1\r\n\tEnd If\r\nEnd Function\r\n",
"vbscript"),d=IEBinaryToArray_ByteStr(b)}for(var b=IEBinaryToArray_ByteStr_Last(b),c="",l=0,s=d.length%8,e;l<s;)e=d.charCodeAt(l++),c+=String.fromCharCode(e&255,e>>8);for(s=d.length;l<s;)c+=String.fromCharCode((e=d.charCodeAt(l++),e&255),e>>8,(e=d.charCodeAt(l++),e&255),e>>8,(e=d.charCodeAt(l++),e&255),e>>8,(e=d.charCodeAt(l++),e&255),e>>8,(e=d.charCodeAt(l++),e&255),e>>8,(e=d.charCodeAt(l++),e&255),e>>8,(e=d.charCodeAt(l++),e&255),e>>8,(e=d.charCodeAt(l++),e&255),e>>8);-1<b&&(c+=String.fromCharCode(b));
d=c}else d=c.responseText;a.text=d}}}),jQuery.ajaxPrefilter("dataview",function(a){if(jQuery.support.ajaxResponseType){if(!a.hasOwnProperty("xhrFields"))a.xhrFields={};a.xhrFields.responseType="arraybuffer"}a.mimeType="text/plain; charset=x-user-defined"}));f.jDataView=(f.module||{}).exports=i;if("undefined"!==typeof module)module.exports=i})(k);return k.jDataView})},"JBrowse/Store/SeqFeature/BigWig/Window":function(){define(["dojo/_base/declare","dojo/_base/lang","dojo/_base/array","./RequestWorker"],
function(k,f,b,a){return k(null,{constructor:function(a,b,g,f){this.bwg=a;if(!(0<=b))throw"invalid cirTreeOffset!";if(!(0<g))throw"invalid cirTreeLength!";this.cirTreeOffset=b;this.cirTreeLength=g;this.isSummary=f},BED_COLOR_REGEXP:/^[0-9]+,[0-9]+,[0-9]+/,readWigData:function(a,b,g,f,c){(a=this.bwg.refsByName[a])?this.readWigDataById(a.id,b,g,f,c):f([])},readWigDataById:function(d,i,g,k,c){this.cirHeader?(new a(this,d,i,g,k,c)).cirFobRecur([this.cirTreeOffset+48],1):(d=f.hitch(this,"readWigDataById",
d,i,g,k,c),this.cirHeaderLoading?this.cirHeaderLoading.push(d):(this.cirHeaderLoading=[d],this.bwg.data.read(this.cirTreeOffset,48,f.hitch(this,function(a){this.cirHeader=a;this.cirBlockSize=this.bwg.newDataView(a,4,4).getUint32();b.forEach(this.cirHeaderLoading,function(a){a()});delete this.cirHeaderLoading}),c)))}})})},"JBrowse/Store/SeqFeature/BigWig/RequestWorker":function(){define("dojo/_base/declare,dojo/_base/lang,dojo/_base/array,JBrowse/Util,JBrowse/Util/RejectableFastPromise,dojo/promise/all,JBrowse/Model/Range,JBrowse/Model/SimpleFeature,jszlib/inflate,jszlib/arrayCopy".split(","),
function(k,f,b,a,d,i,g,o,c){var q=function(){console.log.apply(console,arguments)};return k(null,{BIG_WIG_TYPE_GRAPH:1,BIG_WIG_TYPE_VSTEP:2,BIG_WIG_TYPE_FSTEP:3,constructor:function(a,b,c,e,h,n){this.window=a;this.source=a.bwg.name||void 0;this.blocksToFetch=[];this.outstanding=0;this.chr=b;this.min=c;this.max=e;this.callback=h;this.errorCallback=n||function(e){console.error(e,e.stack,arguments.caller)}},cirFobRecur:function(a,b){this.outstanding+=a.length;for(var c=4+32*this.window.cirBlockSize,
e,h=0;h<a.length;++h){var n=new g(a[h],Math.min(a[h]+c,this.window.cirTreeOffset+this.window.cirTreeLength));e=e?e.union(n):n}c=e.ranges();for(e=0;e<c.length;++e)this.cirFobStartFetch(a,c[e],b)},cirFobStartFetch:function(a,c,b){var e=c.max()-c.min();this.window.bwg._read(c.min(),e,f.hitch(this,function(e){for(var n=0;n<a.length;++n)c.contains(a[n])&&(this.cirFobRecur2(e,a[n]-c.min(),b),--this.outstanding,0==this.outstanding&&this.cirCompleted())}),this.errorCallback)},cirFobRecur2:function(a,c,b){var a=
this.window.bwg.newDataView(a,c),e=a.getUint8(),c=a.getUint16(2);if(0!=e)for(e=0;e<c;++e){var h=a.getUint32(),n=a.getUint32(),d=a.getUint32(),g=a.getUint32(),f=a.getUint64(),b=a.getUint64();(h<this.chr||h==this.chr&&n<=this.max)&&(d>this.chr||d==this.chr&&g>=this.min)&&this.blocksToFetch.push({offset:f,size:b})}else{for(var m=[],e=0;e<c;++e)h=a.getUint32(),n=a.getUint32(),d=a.getUint32(),g=a.getUint32(),f=a.getUint64(),(h<this.chr||h==this.chr&&n<=this.max)&&(d>this.chr||d==this.chr&&g>=this.min)&&
m.push(f);0<m.length&&this.cirFobRecur(m,b+1)}},cirCompleted:function(){this.blockGroupsToFetch=this.groupBlocks(this.blocksToFetch);0==this.blockGroupsToFetch.length?this.callback([]):(this.features=[],this.readFeatures())},groupBlocks:function(a){a.sort(function(a,e){return(a.offset|0)-(e.offset|0)});for(var c=[],b,e,h=0;h<a.length;h++)b&&2E3>=a[h].offset-e?(b.size+=a[h].size-e+a[h].offset,b.blocks.push(a[h])):c.push(b={blocks:[a[h]],size:a[h].size,offset:a[h].offset}),e=b.offset+b.size;return c},
createFeature:function(a,c,b){var a={start:a,end:c,source:this.source},e;for(e in b)a[e]=b[e];this.features.push(new o({data:a}))},maybeCreateFeature:function(a,c,b){a<=this.max&&c>=this.min&&this.createFeature(a,c,b)},parseSummaryBlock:function(a,c){for(var b=this.window.bwg.newDataView(a,c),e=a.byteLength/32,h=0;h<e;++h){var n=b.getInt32(),d=b.getInt32(),g=b.getInt32(),f=b.getInt32();b.getFloat32();b.getFloat32();var m=b.getFloat32();b.getFloat32();if(n==this.chr){n={score:m/f};if("bigbed"==this.window.bwg.type)n.type=
"density";this.maybeCreateFeature(d,g,n)}}},parseBigWigBlock:function(a,b){var c=this.window.bwg.newDataView(a,b),e=c.getUint32(16),h=c.getUint8(20),n=c.getUint16(22);if(h==this.BIG_WIG_TYPE_FSTEP)for(var d=c.getInt32(4),g=c.getUint32(12),h=0;h<n;++h){var f=c.getFloat32(4*h+24);this.maybeCreateFeature(d+h*g,d+h*g+e,{score:f})}else if(h==this.BIG_WIG_TYPE_VSTEP)for(h=0;h<n;++h)d=c.getInt32(8*h+24),f=c.getFloat32(),this.maybeCreateFeature(d,d+e,{score:f});else if(h==this.BIG_WIG_TYPE_GRAPH)for(h=0;h<
n;++h)d=c.getInt32(12*h+24),e=c.getInt32(),f=c.getFloat32(),d>e&&(d=e),this.maybeCreateFeature(d,e,{score:f});else q("Currently not handling bwgType="+h)},parseBigBedBlock:function(a,c){for(var b=this.window.bwg.newDataView(a,c),e=0;e<a.length;){for(var h=b.getUint32(e),d=b.getInt32(e+4),f=b.getInt32(e+8),e=e+12,i="";e<a.length;){var p=b.getUint8(e++);if(0!=p)i+=String.fromCharCode(p);else break}var p={},m=i.split("\t");if(0<m.length)p.label=m[0];if(1<m.length)p.score=parseInt(m[1]);if(2<m.length)p.orientation=
m[2];if(5<m.length&&(i=m[5],this.window.BED_COLOR_REGEXP.test(i)))p.override_color="rgb("+i+")";if(9>m.length)h==this.chr&&this.maybeCreateFeature(d,f,p);else if(h==this.chr&&d<=this.max&&f>=this.min){var h=m[3]|0,f=m[4]|0,i=m[6]|0,k=m[7].split(","),t=m[8].split(",");p.type="bb-transcript";var o=new Feature;o.id=m[0];o.type="bb-transcript";o.notes=[];p.groups=[o];if(10<m.length){var o=m[9],m=m[10],r=new Feature;r.id=o;r.label=m;r.type="gene";p.groups.push(r)}m=null;for(o=0;o<i;++o)r=(t[o]|0)+d,r=
new g(r,r+(k[o]|0)),m=m?m.union(r):r;k=m.ranges();for(d=0;d<k.length;++d)i=k[d],this.createFeature(i.min(),i.max(),p);if(f>h&&(d=m.intersection(new g(h,f)))){p.type="bb-translation";h=d.ranges();for(d=0;d<h.length;++d)i=h[d],this.createFeature(i.min(),i.max(),p)}}}},readFeatures:function(){var a=this,g=b.map(a.blockGroupsToFetch,function(c){var e=new d;a.window.bwg._read(c.offset,c.size,function(a){c.data=a;e.resolve(c)},f.hitch(e,"reject"));return e},a);i(g).then(function(d){b.forEach(d,function(e){b.forEach(e.blocks,
function(b){var d=b.offset-e.offset;0<a.window.bwg.uncompressBufSize?(b=c(e.data,d+2,b.size-2),d=0):b=e.data;a.window.isSummary?a.parseSummaryBlock(b,d):"bigwig"==a.window.bwg.type?a.parseBigWigBlock(b,d):"bigbed"==a.window.bwg.type?a.parseBigBedBlock(b,d):q("Don't know what to do with "+a.window.bwg.type)})});a.callback(a.features)},a.errorCallback)}})})},"JBrowse/Util/RejectableFastPromise":function(){define([],function(){var k=function(){this.callbacks=[];this.errbacks=[]};k.prototype.then=function(f,
b){"value"in this?f(this.value):"error"in this?b(this.error):(this.callbacks.push(f),this.errbacks.push(b))};k.prototype.resolve=function(f){this.value=f;delete this.errbacks;f=this.callbacks;delete this.callbacks;for(var b=0;b<f.length;b++)f[b](this.value)};k.prototype.reject=function(f){this.error=f;delete this.callbacks;var b=this.errbacks;delete this.errbacks;for(var a=0;a<b.length;a++)b[a](f)};return k})},"JBrowse/Model/Range":function(){define("JBrowse/Model/Range",["dojo/_base/declare"],function(k){var f=
k(null,{constructor:function(){this._ranges=2==arguments.length?[{min:arguments[0],max:arguments[1]}]:0 in arguments[0]?dojo.clone(arguments[0]):[arguments[0]]},min:function(){return this._ranges[0].min},max:function(){return this._ranges[this._ranges.length-1].max},contains:function(b){for(var a=0;a<this._ranges.length;++a){var d=this._ranges[a];if(d.min<=b&&d.max>=b)return!0}return!1},isContiguous:function(){return 1<this._ranges.length},ranges:function(){return this._ranges.map(function(b){return new f(b.min,
b.max)})},toString:function(){return this._ranges.map(function(b){return"["+b.min+"-"+b.max+"]"}).join(",")},union:function(b){for(var b=this.ranges().concat(b.ranges()).sort(this.rangeOrder),a=[],d=b[0],i=1;i<b.length;++i){var g=b[i];g.min()>d.max()+1?(a.push(d),d=g):g.max()>d.max()&&(d=new f(d.min(),g.max()))}a.push(d);return 1==a.length?a[0]:new _Compound(a)},intersection:function(b){for(var a,d=this.ranges(),i=b.ranges(),g=d.length,k=i.length,c=0,q=0,j=[];c<g&&q<k;){a=d[c];var b=i[q],l=Math.max(a.min(),
b.min()),s=Math.min(a.max(),b.max());s>=l&&j.push(new f(l,s));a.max()>b.max()?++q:++c}return 0==j.length?null:1==j.length?j[0]:new _Compound(j)},coverage:function(){for(var b=0,a=this.ranges(),d=0;d<a.length;++d)var f=a[d],b=b+(f.max()-f.min()+1);return b},rangeOrder:function(b,a){2>arguments.length&&(a=b,b=this);return b.min()<a.min()?-1:b.min()>a.min()?1:b.max()<a.max()?-1:a.max()>b.max()?1:0}});return f})},"JBrowse/Model/SimpleFeature":function(){define("JBrowse/Model/SimpleFeature",["JBrowse/Util"],
function(k){var f=0,b=k.fastDeclare({constructor:function(a){a=a||{};this.data=a.data||{};this._parent=a.parent;this._uniqueID=a.id||this.data.uniqueID||(this._parent?this._parent.id()+"_"+f++:"SimpleFeature_"+f++);if(a=this.data.subfeatures)for(var d=0;d<a.length;d++)"function"!=typeof a[d].get&&(a[d]=new b({data:a[d],parent:this}))},get:function(a){return this.data[a]},set:function(a,b){this.data[a]=b},tags:function(){var a=[],b=this.data,f;for(f in b)b.hasOwnProperty(f)&&a.push(f);return a},id:function(a){if(a)this._uniqueID=
a;return this._uniqueID},parent:function(){return this._parent},children:function(){return this.get("subfeatures")}});return b})}}});
define("JBrowse/Store/SeqFeature/BigWig","dojo/_base/declare,dojo/_base/lang,dojo/_base/array,dojo/_base/url,JBrowse/Model/DataView,JBrowse/has,JBrowse/Errors,JBrowse/Store/SeqFeature,JBrowse/Store/DeferredStatsMixin,JBrowse/Store/DeferredFeaturesMixin,./BigWig/Window,JBrowse/Util,JBrowse/Model/XHRBlob".split(","),function(k,f,b,a,d,i,g,o,c,q,j,l,s){return k([o,c,q],{BIG_WIG_MAGIC:-2003829722,BIG_BED_MAGIC:-2021002517,BIG_WIG_TYPE_GRAPH:1,BIG_WIG_TYPE_VSTEP:2,BIG_WIG_TYPE_FSTEP:3,_littleEndian:!0,
constructor:function(b){this.data=b.blob||new s(this.resolveUrl(b.urlTemplate||"data.bigwig"));this.name=b.name||this.data.url&&(new a(this.data.url)).path.replace(/^.+\//,"")||"anonymous";this._load()},_defaultConfig:function(){return l.deepUpdate(dojo.clone(this.inherited(arguments)),{chunkSizeLimit:3E7})},_getGlobalStats:function(a){var b=this._globalStats||{};if(!("scoreMean"in b))b.scoreMean=b.basesCovered?b.scoreSum/b.basesCovered:0;if(!("scoreStdDev"in b))b.scoreStdDev=this._calcStdFromSums(b.scoreSum,
b.scoreSumSquares,b.basesCovered);a(b)},_read:function(a,b,c,d){b>this.config.chunkSizeLimit?d(new g.DataOverflow("Too much data. Chunk size "+l.commifyNumber(b)+" bytes exceeds chunkSizeLimit of "+l.commifyNumber(this.config.chunkSizeLimit)+".")):this.data.read.apply(this.data,arguments)},_load:function(){this._read(0,512,f.hitch(this,function(a){if(a){var b=this.newDataView(a),c=b.getInt32();if(c!=this.BIG_WIG_MAGIC&&c!=this.BIG_BED_MAGIC&&(this._littleEndian=!1,b=this.newDataView(a),b.getInt32()!=
this.BIG_WIG_MAGIC&&c!=this.BIG_BED_MAGIC)){console.error("Not a BigWig or BigBed file");deferred.reject("Not a BigWig or BigBed file");return}this.type=c==this.BIG_BED_MAGIC?"bigbed":"bigwig";(this.fileSize=a.fileSize)||console.warn("cannot get size of BigWig/BigBed file, widest zoom level not available");this.version=b.getUint16();this.numZoomLevels=b.getUint16();this.chromTreeOffset=b.getUint64();this.unzoomedDataOffset=b.getUint64();this.unzoomedIndexOffset=b.getUint64();this.fieldCount=b.getUint16();
this.definedFieldCount=b.getUint16();this.asOffset=b.getUint64();this.totalSummaryOffset=b.getUint64();this.uncompressBufSize=b.getUint32();this.zoomLevels=[];for(c=0;c<this.numZoomLevels;++c){var d=b.getUint32(4*(6*c+16)),g=b.getUint64(4*(6*c+18)),i=b.getUint64(4*(6*c+20));this.zoomLevels.push({reductionLevel:d,dataOffset:g,indexOffset:i})}this.totalSummaryOffset?function(){var b=this.newDataView(a,this.totalSummaryOffset);this._globalStats={basesCovered:b.getUint64(),scoreMin:b.getFloat64(),scoreMax:b.getFloat64(),
scoreSum:b.getFloat64(),scoreSumSquares:b.getFloat64()}}.call(this):console.warn("BigWig "+this.data.url+" has no total summary data.");this._readChromTree(function(){this._deferred.features.resolve({success:!0});this._deferred.stats.resolve({success:!0})},f.hitch(this,"_failAllDeferred"))}else this._failAllDeferred("BBI header not readable")}),f.hitch(this,"_failAllDeferred"))},newDataView:function(a,b,c){return new d(a,b,c,this._littleEndian)},_readChromTree:function(a,b){var c=this;this.refsByNumber=
{};this.refsByName={};for(var d=this.unzoomedDataOffset;0!=d%4;)++d;this._read(this.chromTreeOffset,d-this.chromTreeOffset,function(b){if(i("typed-arrays")){var d=c.newDataView(b);if(2026540177!==d.getUint32())throw"parse error: not a Kent bPlusTree";d.getUint32();var h=d.getUint32();d.getUint32();d.getUint64();var f=function(a){if(a>=b.length)throw"reading beyond end of buffer";for(var e=d.getUint8(a),g=d.getUint16(a+2),a=a+4,i=0;i<g;++i)if(e){for(var j="",l=0;l<h;++l){var k=d.getUint8(a++);0!=k&&
(j+=String.fromCharCode(k))}l=d.getUint32(a);k=d.getUint32(a+4);a+=8;k={name:j,id:l,length:k};c.refsByName[c.browser.regularizeReferenceName(j)]=k;c.refsByNumber[l]=k}else a+=h,j=d.getUint64(a),a+=8,j-=c.chromTreeOffset,f(j)};f(32);a.call(c,c)}else c._failAllDeferred("Web browser does not support typed arrays")},b)},hasRefSeq:function(a,b,c){var d=this,a=d.browser.regularizeReferenceName(a);this._deferred.features.then(function(){b(a in d.refsByName)},c)},_getFeatures:function(a,c,d,f){var g=this.browser.regularizeReferenceName(a.ref),
i=a.start,j=a.end;(a=a.basesPerSpan?this.getView(1/a.basesPerSpan):a.scale?this.getView(a.scale):this.getView(1))?a.readWigData(g,i,j,dojo.hitch(this,function(a){b.forEach(a||[],c);d()}),f):d()},getUnzoomedView:function(){if(!this.unzoomedView){var a=4E3;this.zoomLevels[0]&&(a=this.zoomLevels[0].dataOffset-this.unzoomedIndexOffset);this.unzoomedView=new j(this,this.unzoomedIndexOffset,a,!1)}return this.unzoomedView},getView:function(a){if(!this.zoomLevels||!this.zoomLevels.length)return null;if(!this._viewCache||
this._viewCache.scale!=a)this._viewCache={scale:a,view:this._getView(a)};return this._viewCache.view},_getView:function(a){var a=1/a,b=this.zoomLevels.length;for(this.fileSize||b--;0<b;b--){var c=this.zoomLevels[b];if(c&&c.reductionLevel<=2*a)return new j(this,c.indexOffset,b<this.zoomLevels.length-1?this.zoomLevels[b+1].dataOffset-c.indexOffset:this.fileSize-4-c.indexOffset,!0)}return this.getUnzoomedView()}})});