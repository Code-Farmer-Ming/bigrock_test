/**
* 星星评级js类 by zwli
* 2008-3-21 v0.3
*/
function StarRank() {
}

StarRank.prototype = {
    titles:new Array('', '', '', '', ''),
    /* 星星的三种状态图片*/
    //三个 class的名称
    imgEmpty_class:'output_empty_star',
    imgOver_class:'input_full_star',
    imgFull_class:'output_full_star',
    /* 组件的元素集合*/
    links:null,
    /* 组件的id*/
    id:null,
    /* 当前选中的评级值*/
    rankValue:0,
    /* 是否允许点击*/
    disabled:false,
    /* 禁止点击时的提示文字*/
    disabledMessage:'请稍后再点击评级^_^',
    setRankValue:function(value) {
        if(typeof(value) != 'undefined' && value != null) {
            this.rankValue = Number(value);
            this.refresh();
        }
    },

    /* Private刷新星星显示*/
    refresh:function() {
        for (var i=0; i < this.links.length; i++)
        {
            if (this.rankValue > i) {
                this.links[i].className = this.imgFull_class;
            }else {
                this.links[i].className = this.imgEmpty_class;
            }
        }
        Element.update(this.title,this.titles[this.rankValue-1] || '&nbsp;');
    },

    create:function(divParent, id) {
        this.create = null; //防止第二次创建资源
        var _self = this;
        this.id = id;
   
        this.links = new Array(5);
        this.title = document.createElement("span");
        this.title.setAttribute('style', "DISPLAY: inline-block;");

        for(var i = 5; i >= 1; i--) {
            var lnk1
            
            if (this.disabled)
            {
                lnk1 = document.createElement("span");
            }
            else{
                lnk1 = document.createElement("a");
                lnk1.setAttribute('href', "javascript:;");
            }
         
            lnk1.setAttribute('disabled', this.disabled );
            lnk1.setAttribute('rank', i);
            lnk1.setAttribute('style', "background-color:transparent; ");
            lnk1.setAttribute('id', "rankimg" + id + "i" + i);
            lnk1.setAttribute('class', this.imgEmpty_class);
            lnk1.setAttribute('title', this.titles[i-1]);
            lnk1.onclick = function(){
                _self.rankPreClick(_self, id, this.getAttribute('rank'));
            };
            lnk1.onmouseover = function(){
                _self.rankPreMouseOver(_self, id, this.getAttribute('rank'));
            };
            lnk1.onmouseout = function(){
                _self.rankPreMouseOut(_self, id, this.getAttribute('rank'));
            };
            $(divParent).insertBefore(lnk1,$(divParent).childNodes[0]);
            this.links[i-1] = lnk1;
        }
        $(divParent).insert(this.title);
        this.refresh();
    },

    callback:function(type, message) {
    },

    //点击事件，可覆盖方法处理
    rankClick:function(sender, id, value) {
        
    },

    //点击的预处理，请不要覆盖
    rankPreClick:function(sender, id, value){
        if(this.disabled) {
            this.callback('warn', this.disabledMessage);
            return;
        }
        this.rankValue = value;
        this.refresh();
        this.rankClick(sender, id, value);
    },

    rankMouseOver:function(sender, id, value) {
    },

    rankPreMouseOver:function(sender, id, value) {
        if(!this.disabled) {
            for (var i=0; i < this.links.length; i++)
            {
                if (value > i) {
                    this.links[i].className = this.imgOver_class;
                }else {
                    this.links[i].className = this.imgEmpty_class;
                }
            }
        }
        Element.update(this.title,this.titles[value-1]);
        this.rankMouseOver(sender, id, value);
    },

    rankMouseOut:function(sender, id, value) {
    },

    rankPreMouseOut:function(sender, id, value) {
        this.refresh();
        this.rankMouseOut(sender, id, value);
    }
}

