var login_check=false;
var t=null;

function addMenuItems(){
    $.ajax({
        url: 'downloadDetails/getMenuItem.jsp',
        success: function( data ) {
            appendUID(data);
        }
    });
}

function appendUID(data){
    var selector = $("div[class='areahp']:first").parent().find(">:first-child");
   
    $.ajax({
        url: 'downloadDetails/getUID.jsp',
        success: function( uid ) {
            var append="";
            if($.trim(uid)!='null'){
                append="Welcome, "+uid + "  ";
            }
            
            $("#upperMenu").remove();
            if($.trim(data)=="true"){
                login_check=true;
                $(selector).append("<div id=\"upperMenu\">"+append+"<a href='downloadDetails/index.jsp' target=\"downloadDetails\">Download Details  </a>&nbsp;<a href=\"/sso/logout?sso_redirect=/EME\">Logout</a></div>");
                
                if(t!=null){
                    clearInterval(t);
                    t=null;
                }
            }
            else {
                $(selector).append("<div id=\"upperMenu\"><a href='/sso/login?sso_redirect=/EME/downloadDetails/index.jsp' target=\"downloadDetails\">Login</a></div>");
                    
                if(login_check){
                    clearInterval(t);
                }else{
                    if(t==null){
                        t=setInterval(addMenuItems,10000);
                    }
                }
            }
        }
    });
}



$(document).ready(function(){
    addMenuItems();
 
    //update menu links
    $("div[class='navButton']").find("a").each(function(){
        if($(this).html()=="World Usage"){
            $(this).attr({
                "href":"eme_world.jsp?errorRedirect=101",
                "target":"_blank"
            });
        }else if($(this).html()=="U.S. Usage"){
            $(this).attr({
                "href":"eme_usa.jsp?errorRedirect=101",
                "target":"_blank"
            });
        }
    });
});
