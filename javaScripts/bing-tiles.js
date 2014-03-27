// API key for http://openlayers.org. Please get your own at
// http://bingmapsportal.com/ and use that instead.
var apiKey = "AkpioNuOZOdJiXnWUQtWloLIACB-AJpwTpvS884VsCzcmjWtT9Tf3l3qvREekSgF";


function mapRefresher(){
   
    var re = /^(map_)/;
    allDivs = document.getElementsByTagName('div');
    for(i=0;i<allDivs.length;i++){
        var curDiv = allDivs[i];
        if(curDiv.getAttribute("id") && curDiv.getAttribute("id").match(re)){
           
            var map = new OpenLayers.Map(curDiv.getAttribute("id"));
            var longitude = curDiv.getAttribute("longitude");
            var latitude = curDiv.getAttribute("latitude");
            var longLat = new OpenLayers.LonLat(longitude, latitude);
                
            var road = new OpenLayers.Layer.Bing({
                key: apiKey,
                type: "Road",
                // custom metadata parameter to request the new map style - only useful
                // before May 1st, 2011
                metadataParams: {
                    mapVersion: "v1"
                }
            });
            
            var markers = new OpenLayers.Layer.Markers( "Markers" );
            var overview = new OpenLayers.Control.OverviewMap({
                maximized: true
            });
            
            
            var size = new OpenLayers.Size(21,25);
            var offset = new OpenLayers.Pixel(-(size.w/2), -size.h);
            var icon = new OpenLayers.Icon('/OpenLayers/img/marker.png',size,offset);
            
            markers.addMarker(new OpenLayers.Marker(longLat,icon));
            
            map.addLayers([road,markers]);
            //map.addControl(new OpenLayers.Control.LayerSwitcher());
            map.addControl(overview);
            map.setCenter(longLat.transform(
                new OpenLayers.Projection("EPSG:4326"),
                map.getProjectionObject()
                ), 7);
         
        }
    }
}

$(document).ready(function() {
    Exhibit.TileView.prototype._reconstruct = (function(fn){
        return function(){
            retValue = fn.call(this);
        
            if(mapRefresher){
                mapRefresher();
            }
            return retValue;
        }
    })(Exhibit.TileView.prototype._reconstruct );
});
