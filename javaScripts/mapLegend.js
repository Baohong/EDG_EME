mapLegend = function(config){
    var self = this;
    var gradientPoints=[];
    var minDownloadCount = null;
    var maxDownloadCount = null;
    var totalDataPoints = {};
    
    var colorGradientCoder = function(key, flags) {
     
        var getColor = function(key){
            if (key.constructor != Number) {
                key = parseFloat(key);
            }
            
            for (var j = 0; j < self.gradientPoints.length; j++) {
                
                if (key == self.gradientPoints[j].value) {
                    return rgbToHex(self.gradientPoints[j].red, self.gradientPoints[j].green, self.gradientPoints[j].blue);
                } else if (self.gradientPoints[j+1] != null) {
                    if (key < self.gradientPoints[j+1].value) {
                        var fraction = (key - self.gradientPoints[j].value)/(self.gradientPoints[j+1].value - self.gradientPoints[j].value);
                        var newRed = Math.floor(self.gradientPoints[j].red + fraction*(self.gradientPoints[j+1].red - self.gradientPoints[j].red));
                        var newGreen = Math.floor(self.gradientPoints[j].green + fraction*(self.gradientPoints[j+1].green - self.gradientPoints[j].green));
                        var newBlue = Math.floor(self.gradientPoints[j].blue + fraction*(self.gradientPoints[j+1].blue - self.gradientPoints[j].blue));
                        return rgbToHex(newRed, newGreen, newBlue)
                    }
                }
            }
        }

        var rgbToHex = function(r, g, b) {
           
            var decToHex = function(n) {
                if (n == 0) {
                    return "00"
                }
                else {
                    var tmp = n.toString(16);
                    if(tmp.length==2){
                        return tmp;
                    }else{
                        return "0"+tmp;
                    }
                }
            }
            
            return "#" + decToHex(r) + decToHex(g) + decToHex(b);
        }
	
        return getColor(key);
        
        if (key >= gradientPoints[0].value & key <= gradientPoints[gradientPoints.length-1].value) {
            if (flags) flags.keys.add(key);
            return getColor(key);
        } else if (key == null) {
            if (flags) flags.missing = true;
            return this._missingCase.color;
        } else {
            if (flags) flags.others = true;
            return this._othersCase.color;
        }
    };
    
    var drawGradient_ = function(){
        var uniqueDownloadData = [];
        var parent = $("#"+config["renderInDiv"]);
        var noOfDivs = function(){
            var count = 0;
            for(keys in self.totalDataPoints){
                uniqueDownloadData.push(keys);
                count++;
            }
            return count;
        }();
        var widthPerDiv = parseInt(Math.floor(($(parent).width()/noOfDivs)),10);
        //sort array
        uniqueDownloadData.sort(function(a,b){
            return a-b
        });
        //get opacity
        var op = $("#"+config["mapDivID"]).attr("ex:opacity");
        var divStyle = "height:24px; width:"+widthPerDiv+"px;float:left;cursor:pointer;"
        if(op!=undefined){
            divStyle += "opacity:"+op+";filter:alpha(opacity="+(parseFloat(op)*100)+");";
        }
        
        for(var i=0,len=uniqueDownloadData.length;i<len;i++){
            $(parent).append('<div title="'+uniqueDownloadData[i]+' downloads" style="'+divStyle+'background-color:'+colorGradientCoder(uniqueDownloadData[i])+';">&nbsp;</div>');
        }
        $(parent).append("<div style=\"clear:both;\"></div>");
    }
    
    var drawGradient = function(){
        var parent = $("#"+config["renderInDiv"]);
        var skip = 1;
        var noOfDivsCpy = null;
        var widthPerDiv = 0;
        var parentWidth = $(parent).width();
        
        
        var gradientCount = 0;
        var currentColorCode = null;
        var viewableColorCodes = {};
        for(var i=self.minDownloadCount;i<self.maxDownloadCount;i++){
            currentColorCode = colorGradientCoder(i);
            if(!(viewableColorCodes[currentColorCode])){
                viewableColorCodes[currentColorCode] = i;
                gradientCount++;
            }
        }
        noOfDivsCpy = gradientCount;
        do{
            widthPerDiv = parseInt(Math.round((parentWidth/noOfDivsCpy)),10);
            noOfDivsCpy = gradientCount/(++skip);
        }while(widthPerDiv==0);
        
        //skip--;
        
        //get opacity
        var op = $("#"+config["mapDivID"]).attr("ex:opacity");
        var divStyle = "height:24px; width:"+widthPerDiv+"px;float:left;cursor:pointer;"
        if(op!=undefined){
            divStyle += "opacity:"+op+";filter:alpha(opacity="+(parseFloat(op)*100)+");";
        }
        var count=0;
        
        $(parent).append('<div style="float:left;font-weight:bold; height:24px;line-height:24px; width:100px; text-align:right; margin-right:4px;">'+self.minDownloadCount+'</div>');
        for(keys in viewableColorCodes){
            /*
            if(count++==skip){
                count = 0;
                continue;
            }*/
            $(parent).append('<div title="'+viewableColorCodes[keys]+' downloads" style="'+divStyle+'background-color:'+keys+';">&nbsp;</div>');
        }
        $(parent).append('<div style="float:left;font-weight:bold; height:24px;line-height:24px; width:100px; text-align:left; margin-left:4px;">'+self.maxDownloadCount+'</div>');
        $(parent).append("<div style=\"clear:both;\"></div>");
        $(parent).css({"width":((widthPerDiv*gradientCount)+208)+"px"});
    }
    
    
    var init = function(){
        var idOfCoder = config["idOfCoder"];
        var dataURL = config["dataURL"];
        var gradientPoints = [];
       
       
                    
        //get data points
        $.ajax({
            url: dataURL,
            dataType : "text",
            async : false,
            error: function(jqXHR, textStatus, errorThrown){
                alert("Error : " + textStatus);
            },
            success: function(data) {
                var totalDataPoints = {};
                var myData = eval(data);
                self.minDownloadCount = self.maxDownloadCount = myData[0].downloadcount;
                for(var i=1,len=myData.length;i<len;i++){
                    var val = myData[i].downloadcount;
                    totalDataPoints[val]=val;
                    
                    if(myData[i].downloadcount< self.minDownloadCount){
                        self.minDownloadCount = myData[i].downloadcount;
                    }
                    if(myData[i].downloadcount> self.maxDownloadCount){
                        self.maxDownloadCount = myData[i].downloadcount;
                    }
                }
                self.totalDataPoints = totalDataPoints;
            }
        });
        //end
        
        //set gradientPoints
       
        var coder = ($("#"+idOfCoder).attr("ex:gradientPoints")).toString().split(";");
        for(var i=0,len=coder.length;i<len;i++){
            var range = coder[i].split(",");
            var point = range[0];
            var value = parseFloat(point);
            var colorIndex = range[1].indexOf("#") + 1;
            var red = parseInt(range[1].substr(colorIndex,2), 16);
            var green = parseInt(range[1].substr(colorIndex+2,2), 16);
            var blue = parseInt(range[1].substr(colorIndex+4,2), 16);
            gradientPoints.push({
                value: value, 
                red: red, 
                green: green, 
                blue: blue
            });
        }
        self.gradientPoints = gradientPoints;
        //end
        
        drawGradient();
        
        Exhibit.ViewPanel.prototype._createView = (function(fn){
            return function(){
                retValue = fn.call(this);
                
                if($("div.exhibit-mapView-map").css("display")!=undefined){
                    $("#"+config["renderInDiv"]).show();
                }else{
                    $("#"+config["renderInDiv"]).hide();
                
                }
            }
        })(Exhibit.ViewPanel.prototype._createView);
        
    }();
}