/*
Created By: Chris Campbell
Website: http://particletree.com
Date: 2/1/2006

Inspired by the lightbox implementation found at http://www.huddletogether.com/projects/lightbox/
 */


//Browser detect script origionally created by Peter Paul Koch at http://www.quirksmode.org/
var Lightbox;
Event.observe(window, 'load', initialize, false);
var lightbox = Class.create();
lightbox.prototype = {
    yPos : 0,
    xPos : 0,

    initialize: function() {
        this.addLightboxMarkup();
    },
    center_position: function(){
        $('lightbox').style.margin ="";
        $('lightbox').style.height ="";
        $('lightbox').style.width = "";
         $('lightbox').style.height = $('lightbox').scrollHeight + 'px';
     //   $('lightbox').style.width = $('lightbox').scrollWidth  + 'px';

        $('lightbox').style.margin = "-" +  $('lightbox').scrollHeight /2 +"px 0 0 "
        + "-" + $('lightbox').scrollWidth /2 +"px";
    },
	
    // Turn everything on - mainly the IE fixes
    show: function(url){
        this.content = url

        if (Prototype.Browser.IE){
            this.getScroll();
            this.prepareIE('100%', 'hidden');
            this.setScroll(0,0);
            this.hideSelects('hidden');
        }
        Element.update("lightbox_content",  "<p id='LoadMessage'></p>");
        this.displayLightbox("block");
        this.center_position();
    },
    // Add in markup necessary to make this work. Basically two divs:
    // Overlay holds the shadow
    // Lightbox is the centered square that the content is put into.
    addLightboxMarkup: function () {
        if ($("overlay")!=null) return;
        bod 				= document.getElementsByTagName('body')[0];
        overlay 			= document.createElement('div');
        overlay.id		= 'overlay';
        lb					= document.createElement('div');
        lb.id				= 'lightbox';
     
      

        title = document.createElement('div');
        title.id = "lightbox_title";
        title.innerHTML = "<a id='lightbox_close' href='#' onclick='Lightbox.close();'></a>"
        lb.appendChild(title);
        
        lightbox_msg = document.createElement('div');
        lightbox_msg.id = "lightbox_msg";
        lb.appendChild(lightbox_msg);
        lightbox_content  = document.createElement('div');
        lightbox_content.id = "lightbox_content";
       
        lb.appendChild(lightbox_content);
        document.body.appendChild(overlay);
        document.body.appendChild(lb);
    },
    // Ie requires height to 100% and overflow hidden or else you can scroll down past the lightbox
    prepareIE: function(height, overflow){
        bod = document.getElementsByTagName('body')[0];
        bod.style.height = height;
        bod.style.overflow = overflow;
  
        htm = document.getElementsByTagName('html')[0];
        htm.style.height = height;
        htm.style.overflow = overflow;
    },
	
    // In IE, select elements hover on top of the lightbox
    hideSelects: function(visibility){
        selects = document.getElementsByTagName('select');
        for(i = 0; i < selects.length; i++) {
            selects[i].style.visibility = visibility;
        }
    },
	
    // Taken from lightbox implementation found at http://www.huddletogether.com/projects/lightbox/
    getScroll: function(){
        if (self.pageYOffset) {
            this.yPos = self.pageYOffset;
        } else if (document.documentElement && document.documentElement.scrollTop){
            this.yPos = document.documentElement.scrollTop;
        } else if (document.body) {
            this.yPos = document.body.scrollTop;
        }
    },
	
    setScroll: function(x, y){
        window.scrollTo(x, y);
    },
	
    displayLightbox: function(display){
 
        $('overlay').style.display = display;
        $('lightbox').style.display = display;
        if(display != 'none') this.loadInfo();

    //
    //            $("overlay").style.display = display;
    //        $("lightbox").style.display = display;
    //        if(display != 'none'){
   
    //        new Effect.Appear('overlay', {
    //            duration: 0.4,
    //            queue: 'end'
    //        });
    //            this.loadInfo();
    //        }else
    //        {
    //            new Effect.Fade('lightbox', {
    //                duration: 0.4
    //            });
    //            new Effect.Fade('overlay', {
    //                duration: 0.4
    //            });
    //        }
    },
	
    // Begin Ajax request based off of the href of the clicked linked
    loadInfo: function() {
        var myAjax = new Ajax.Request(
            this.content,
            {
                method: 'get',
                parameters: "from=Lightbox",
                onComplete: this.processInfo.bindAsEventListener(this)
            }
            );
    },
	
    // Display Ajax response
    processInfo: function(response){
        Element.update("lightbox_content", response.responseText );
        $('lightbox').className = "done";
        this.center_position();
    },
	
    // Example of creating your own functionality once lightbox is initiated
    close: function(){
        Element.update('lightbox_content','');
        Element.update('lightbox_msg','');
        if (Prototype.Browser.IE){
            this.setScroll(0,this.yPos);
            this.prepareIE("auto", "auto");
            this.hideSelects("visible");
        }
        new Effect.Fade('overlay', {
            duration: 0.4
        });
        this.displayLightbox("none");
    }
}

function initialize(){
    Lightbox = new lightbox();
}

