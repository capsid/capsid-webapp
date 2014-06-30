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

function CapsidFeatureAdapter(args) {

    _.extend(this, Backbone.Events);

    this.host = null;
    this.gzip = true;
    this.urlBase = 'api/browser/feature';

    this.params = {};
    if (args != null) {
        if (args.urlBase != null) {
            this.urlBase = args.urlBase;
         }
        if (args.host != null) {
            this.host = args.host;
        }
        if (args.species != null) {
            this.species = args.species;
        }
        if (args.category != null) {
            this.category = args.category;
        }
        if (args.subCategory != null) {
            this.subCategory = args.subCategory;
        }
        if (args.resource != null) {
            this.resource = args.resource;
        }
        if (args.featureCache != null) {
            var argsFeatureCache = args.featureCache;
        }
        if (args.params != null) {
            this.params = args.params;
        }
        if (args.filters != null) {
            this.filters = args.filters;
        }
        if (args.options != null) {
            this.options = args.options;
        }
        if (args.featureConfig != null) {
            if (args.featureConfig.filters != null) {
                this.filtersConfig = args.featureConfig.filters;
            }
            if (args.featureConfig.options != null) {
                this.optionsConfig = args.featureConfig.options;
                for (var i = 0; i < this.optionsConfig.length; i++) {
                    if (this.optionsConfig[i].checked == true) {
                        this.options[this.optionsConfig[i].name] = true;
                        this.params[this.optionsConfig[i].name] = true;
                    }
                }
            }
        }
    }
    this.featureCache = new FeatureCache(argsFeatureCache);
}

CapsidFeatureAdapter.prototype.clearData = function () {
    this.featureCache.clear();
};

CapsidFeatureAdapter.prototype.setFilters = function (filters) {
    this.clearData();
    this.filters = filters;
    for (filter in filters) {
        var value = filters[filter].toString();
        delete this.params[filter];
        if (value != '') {
            this.params[filter] = value;
        }
    }
};
CapsidFeatureAdapter.prototype.setOption = function (opt, value) {
    if (opt.fetch) {
        this.clearData();
    }
    this.options[opt.name] = value;
    for (option in this.options) {
        if (this.options[opt.name] != null) {
            this.params[opt.name] = this.options[opt.name];
        } else {
            delete this.params[opt.name];
        }
    }
};

CapsidFeatureAdapter.prototype.getData = function (args) {
    var _this = this;
    var rnd = String.fromCharCode(65 + Math.round(Math.random() * 10));

    var params = {
        histogram: args.histogram,
        interval: args.interval,
        chromosome: args.chromosome,
        resource: args.resource
    }

    var start = (args.start < 1) ? 1 : args.start;
    var end = (args.end > 300000000) ? 300000000 : args.end;

    var dataType = 'data';
    if (params.histogram) {
        dataType = 'histogram' + params.interval;
    }

    params['dataType'] = dataType;

    var firstChunk = this.featureCache._getChunk(start);
    var lastChunk = this.featureCache._getChunk(end);
    var chunks = [];
    var itemList = [];
    for (var i = firstChunk; i <= lastChunk; i++) {
        var key = args.chromosome + ':' + i;
        if (this.featureCache.cache[key] == null || this.featureCache.cache[key][dataType] == null) {
            chunks.push(i);
        } else {
            var item = this.featureCache.getFeatureChunk(key);
            itemList.push(item);
        }
    }

//    var segmentObj = {chromosome: params.chromosome, start: start, end: end};

    var webServiceCallBack = function (data, segment) {
        var jsonResponse = data['data'];

        if (params.histogram == true) {
            jsonResponse = data;
        }

        var activeFeatureTypes = [];

        if (_this.filters) {
            for (i in _this.filters.terms) {
                if (_this.filters.terms[i].active) {
                    activeFeatureTypes.push(_this.filters.terms[i].term);
                }
            }
        }
        var fc = _this.featureCache._getChunk(segment.start);
        var k = segment.chromosome + ':' + fc;
        if (_this.featureCache.cache[key] == null || _this.featureCache.cache[key][dataType] == null) {
            _this.featureCache.putFeaturesByRegion(jsonResponse, segment, 'read', dataType);
        }

        var items = _this.featureCache.getFeatureChunksByRegion(segment);
        if (items != null) {
            itemList = itemList.concat(items);
        }
        if (itemList.length > 0) {
            _this.trigger('data:ready', {items: itemList, params: params, cached: false, sender: _this});
        }
    };

    var queries = [];
    var updateStart = true;
    var updateEnd = true;
    if (chunks.length > 0) {
        //		console.log(chunks);

        for (var i = 0; i < chunks.length; i++) {

            if (updateStart) {
                var chunkStart = parseInt(chunks[i] * this.featureCache.chunkSize);
                updateStart = false;
            }
            if (updateEnd) {
                var chunkEnd = parseInt((chunks[i] * this.featureCache.chunkSize) + this.featureCache.chunkSize - 1);
                updateEnd = false;
            }

            if (chunks[i + 1] != null) {
                if (chunks[i] + 1 == chunks[i + 1]) {
                    updateEnd = true;
                } else {
                    var query = args.chromosome + ':' + chunkStart + '-' + chunkEnd;
                    queries.push(query);
                    updateStart = true;
                    updateEnd = true;
                }
            } else {
                var query = args.chromosome + ':' + chunkStart + '-' + chunkEnd;
                queries.push(query);
                updateStart = true;
                updateEnd = true;
            }
        }
        //		console.log(querys);
        console.time(_this.resource + ' get and save ' + rnd);
        for (query in queries) {
            this._callWebService(queries[query], webServiceCallBack, params);
        }
    } else {
        if (itemList.length > 0) {
            _this.trigger('data:ready', {items: itemList, params: params, sender: this});
        }
    }
};

CapsidFeatureAdapter.prototype._callWebService = function (segmentString, callback, params) {
    var callParams = {
        segment: segmentString,
        resource: 'feature',
        histogram: params.histogram,
        interval: params.interval,
        exclude: params.exclude
    };
    for(var paramKey in this.params){
        if(this.params.hasOwnProperty(paramKey))
            callParams[paramKey] = this.params[paramKey];
    }
    var url = this.urlBase + this._getQuery(callParams);
//    console.log(url);
    $.ajax({
        type: 'GET',
        url: url,
        dataType: 'json',//still firefox 20 does not auto serialize JSON, You can force it to always do the parsing by adding dataType: 'json' to your call.
        async: true,
        success: function (data) {
            var region = new Region({str: segmentString});
            callback(data, region);
        }
    });
};

CapsidFeatureAdapter.prototype._getQuery = function (paramsWS) {
    var query = "";
    for (var key in paramsWS) {
        if (paramsWS[key] != null)
            query += key + '=' + paramsWS[key] + '&';
    }
    if (query != '')
        query = "?" + query.slice(0, -1);
    return query;
};
