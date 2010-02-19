// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
//function triggerEvent(trigger,eventName)
//{
//    trigger =$(trigger);
//    if (document.createEvent)
//    {
//        var evt = document.createEvent('HTMLEvents');
//        evt.initEvent(eventName, true, true);
//        return trigger.dispatchEvent(evt);
//    }
//
//    if (this.fireEvent)
//        return trigger.fireEvent('on' + eventName);
//}
//标签输入控制组件
//实现标签的输入时的控制动作和控制
TagInput = Class.create();
TagInput.prototype= {
    initialize : function(tag_input_element,tags_element,options){
        this.options = options || { };
        this.options.splitStr    = this.options.splitStr || " ";
        this.options.disableClass    = this.options.disableClass || "disable_tag";
        
        if (typeof(tag_input_element)== 'undefined' || tag_input_element=="" )
            return;
        this.tag_input =$(tag_input_element);
        this.tags_element = tags_element;
        $$(this.tags_element).each(function(el){
            Event.observe(el, 'click',this.onclick.bindAsEventListener(this));
        }.bind(this))
        Event.observe(this.tag_input, 'keyup',this.onkeyup.bindAsEventListener(this));
        this.input_tag_test();
    },
    onkeyup : function (){
        this.input_tag_test();
    },
    onclick : function (event){
        //        new_str = this.tag_input.value.replace(this.options.splitStr + event.currentTarget.innerHTML.strip(),"");
        event_el_value = event.target.innerHTML.strip();
        tag_values = $F(this.tag_input).split(this.options.splitStr);
        search_index = -1;
        for(var i in tag_values)
            if  (tag_values[i]==event_el_value)
            {
                search_index = this.tag_input.value.search(event_el_value);
                break;
            }
        if (search_index>-1)
            if (search_index==0)
                this.tag_input.value = this.tag_input.value.replace(event_el_value,"");
            else
                this.tag_input.value = this.tag_input.value.replace(this.options.splitStr + event_el_value,"");
        else
        if (this.tag_input.value.strip()=="")
            this.tag_input.value = event_el_value  ;
        else
            this.tag_input.value += this.options.splitStr + event_el_value  ;
        this.input_tag_test();
    },

    input_tag_test : function()
    {
        tag_values = $F(this.tag_input).split(this.options.splitStr);
        tag_els= $$(this.tags_element);
        for (var i=0;i<tag_els.length;i++)
        {
            var el = tag_els[i];
            for (j in tag_values)
            {
                value = tag_values[j]
                if (el.innerHTML.strip()==value)
                {
                    Element.addClassName(el,this.options.disableClass);
                    break;
                }
                else
                {
                    Element.removeClassName(el,this.options.disableClass);
                }
            }
        }
    }
}
DropList = Class.create();
DropList.prototype= {
    initialize : function(src_select,target_select,array_value){
        this.src_select = $(src_select);
        this.option_collection = array_value
        this.target_select = $(target_select);
        Event.observe(this.src_select, 'change',this.onchange.bindAsEventListener(this));        
        for(var i=0; i < this.option_collection[this.src_select.value].length; i++) {
            this.target_select.options[i] = new Option(this.option_collection[this.src_select.value][i][1],
                this.option_collection[this.src_select.value][i][0]);
        }
    },
    onchange : function(event){
        this.target_select.options.length = 0;
        for(var i=0; i < this.option_collection[this.src_select.value].length; i++) {
            this.target_select.options[i] = new Option(this.option_collection[this.src_select.value][i][1],
                this.option_collection[this.src_select.value][i][0]);
        }
//        triggerEvent(this.target_select,'change');
    }    
}

function PerpareNew(element)
{
    el =$(element);
    if (!el) return;
    el.show();
    el.scrollIntoView();
    el.select("Form").each(function(el){
        el.reset();
        el.focusFirstElement();
    });
}
//编辑之前的准备
function PerpareEdit(element)
{
    el =$(element);
    if (!el) return;
    el.hide();
    el_container = $("edit_container_"+element);
    if (!el_container) return;
    el_container.show();
}

Ajax.Responders.register({
    onCreate: function(requester,xhrObject) {
        if (Ajax.activeRequestCount > 0)
        {
            //            Element.show('form-indicator');
            if (requester && requester.container && requester.container["success"])
            {
                $(requester.container["success"]).update("<p class='loading'></p>","top");
            }
        }
    },
    onComplete: function(requester) {
        if (Ajax.activeRequestCount == 0)
        {
            if (requester && requester.container && requester.container["success"] && $(requester.container["success"]).select(".loading"))
            {
                $(requester.container["success"]).select(".loading").each(function(el){
                    el.remove();
                });
            }
        }
    //    　Element.hide('form-indicator');
    }
});
function AddHover(element){
    section_el =$(element);
    section_el.select(".edit_section").each(function(el){
        Event.observe(el, "mouseover", function(){
            this.addClassName("hover");
            this.setAttribute('style','');
        });
        Event.observe(el, "mouseout", function(){
            this.removeClassName("hover");
        });
    });

}

Event.observe(window, "load", function() {
    Nifty('#nav a', "top");
    Nifty('div.main_info');
    Nifty('div.user_icon',"small");
});

function SetCookie(Cookie_name,value)　　
{　　
　var Then = new Date()　　
　Then.setTime(Then.getTime() + 2*3600000 ) //小时　　
　document.cookie = Cookie_name+"="+value+";expires="+ Then.toGMTString()　　
}　　
function GetCookie(Cookie_name)　　
{　　
　var cookieString = new String(document.cookie)　　
　var cookieHeader = Cookie_name+"="　　
　var beginPosition = cookieString.indexOf(cookieHeader)　　
　if (beginPosition != -1) //cookie已经设置值，应该 不显示提示框　　
　{　　
　　return cookieString.substring(beginPosition + cookieHeader.length);　　
　}　　
　else　//cookie没有设置值，应该显示提示框　　
　{　　
　  return null;　　
　}　　
}　　
function MoveCookie(Cookie_name)　　
{　　
　document.cookie = Cookie_name+"=;expires=Fri, 02-Jan-1970 00:00:00 GMT";　　
}　