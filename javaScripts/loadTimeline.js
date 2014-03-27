var tl;
       
window.onload = function(){
    
    var eventSource = new Timeline.DefaultEventSource(0);
            
            var theme = Timeline.ClassicTheme.create();
            theme.event.label.width = 550; // px
            theme.event.bubble.width = 320;
            theme.event.bubble.height = 220;
            theme.ether.backgroundColors[1] = theme.ether.backgroundColors[0];
            var lastyear = new Date().getFullYear() -1;
            var d = Timeline.DateTime.parseGregorianDateTime(lastyear)
            var bandInfos = [
                Timeline.createBandInfo({
                    width:          "0%", 
                    intervalUnit:   Timeline.DateTime.YEAR, 
                    intervalPixels: 100,
                    date:           d,
                    showEventText:  false,
                    autoWidth:      false,
                    theme:          theme
                }),
                Timeline.createBandInfo({
                    width:          "100%",
                    intervalUnit:   Timeline.DateTime.YEAR, 
                    intervalPixels: 150,
                    eventSource:    eventSource,
                    date:           d,
                    autoWidth:      false,
                    theme:          theme
                })
            ];
            bandInfos[0].etherPainter = new Timeline.YearCountEtherPainter({
                startDate:  "July 28 2006 00:00:00 GMT",
                multiple:   1,
                theme:      theme
            });
            bandInfos[0].syncWith = 1;
            bandInfos[0].highlight = false;
            bandInfos[0].decorators = [
                new Timeline.SpanHighlightDecorator({
                    startDate:  "July 28 2006 00:00:00 GMT",
                    endDate:    "February 15 2013 00:00:00 GMT",
                    startLabel: "",
                    endLabel:   "",
                    color:      "#FFC080",
                    opacity:    50,
                    theme:      theme
                })
            ];
            
            tl = Timeline.create(document.getElementById("tl"), bandInfos, Timeline.HORIZONTAL);
            tl.loadXML("EMEKeyDates.xml", function(xml, url) {
                eventSource.loadXML(xml, url);
            });
}

var resizeTimerID = null;

function onResize() {
    alert("resize");
    if (resizeTimerID == null) {
        resizeTimerID = window.setTimeout(function() {
            resizeTimerID = null;
            tl.layout();
        }, 500);
    }
}