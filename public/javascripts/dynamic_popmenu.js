/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

// Place your application-specific JavaScript functions and classes here
// 显示弹出菜单
// This file is automatically included by javascript_include_tag :defaults

DynamicPopmenu = Class.create();
 
DynamicPopmenu.prototype= {
    initialize : function(target,popElement){
        if ( target != null)
        {
            this.target=$(target);
            this.popElement = $(popElement);
            Event.observe(this.target, 'click',this.onclick.bind(this));
            Event.observe(document, 'click',this.ondocumentClick.bind(this));
        }
    },
    ondocumentClick : function(event){
        var obj =event.target ;
        if (obj != this.target && obj != this.popElement) {
            this.popElement.style.display = "none";
        }
    },
    onclick : function (event){
        if (this.popElement.style.display == "block") {
            this.popElement.style.display = "none";
        }
        else {
            this.popElement.style.left = this.target.cumulativeOffset()[0]+"px";
            this.popElement.style.top =this.target.cumulativeOffset()[1]+this.target.offsetHeight+"px";
            this.popElement.style.display = "block";
         
        }
   
    }
}
