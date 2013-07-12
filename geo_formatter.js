// UMD from https://github.com/umdjs/umd/blob/master/returnExports.js
(function(root, factory){
  if (typeof define === 'function' && define.amd){
    // AMD. Register as an anonymous module.
    define(factory);
  } else if (typeof exports === 'object'){
    // Node. Does not work with strict CommonJS, but
    // only CommonJS-like enviroments that support module.exports,
    // like Node.
    module.exports = factory();
  } else {
    // Browser globals (root is window)
    root.GeoFormatter = factory();
  }

}(this, function(){
  var geoFormatter = function(result){
    this.result = result;
  };

  geoFormatter.prototype.getCoordinates = function(){
    var loc = this.result.geometry.location;
    return [loc.lat(), loc.lng()];
  };

  geoFormatter.prototype.getAddress = function(){
    return this.result.formatted_address;
  };

  geoFormatter.prototype.getCity = function(){
    return this.matchingTypes({
      locality: true,
      sublocality: true,
      administrative_area_level_3: true,
      administrative_area_level_2: true
    }, true);
  };

  geoFormatter.prototype.getState = function(){
    return this.matchingTypes({ administrative_area_level_1: true });
  };

  geoFormatter.prototype.getStateCode = function(){
    return this.matchingTypes({ administrative_area_level_1: true }, true);
  };

  geoFormatter.prototype.getCountry = function(){
    return this.matchingTypes({ country: true });
  };

  geoFormatter.prototype.matchingTypes = function(types, shortName){
    var components = this.result.address_components,
      component, compTypes, i, j;

    for (i = 0; i < components.length; i++){
      component = components[i];
      compTypes = component.types;
      for (j = 0; j < compTypes.length; j++){
        if (types[compTypes[j]]){
          return shortName ? component.short_name : component.long_name;
        }
      }
    }
  };

  return geoFormatter;
}));
