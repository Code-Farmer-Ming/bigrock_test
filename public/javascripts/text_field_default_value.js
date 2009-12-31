/* 
设置 input text 默认显示内容
 */

TextDefaultValue = Class.create();
TextDefaultValue.prototype= {
    initialize : function(inputTextID,defaultText,options){
        this.inputText = $(inputTextID);
        var parentForm=  this.inputText.up("form");
        this.options = options || { };
        this.defaultValue = defaultText;
        this.isPassword= this.inputText.type && this.inputText.type == 'password';
        //        if (this.isPassword) this.inputText.type='text';   
        if (this.isPassword)
        {
            this.clone_input= this.clone_input_password();
            this.inputText.hide();
            new Insertion.After(this.inputText,this.clone_input);
            this.clone_input.observe('focus',function(){
                this.inputText.show();
                this.clone_input.hide();
                setTimeout(function () {
                    this.inputText.focus();
                }.bind(this), 1);
            
            }.bindAsEventListener(this));
                
            this.inputText.observe('blur',function(){
                if ($F(this.inputText)===""){
                    this.clone_input.show();
                    this.inputText.hide();
                }
            }.bindAsEventListener(this));
                
        }
        else
        {
            this.inputText.style.color=this.options.default_text_color;
            this.inputText.value=this.defaultValue;
            this.inputText.observe('focus',function(){
                if (this.inputText.value==this.defaultValue){
                    this.inputText.value='';
                    this.inputText.style.color='';
                //                if (this.isPassword) this.inputText.type='password';
                }
            }.bindAsEventListener(this));
            this.inputText.observe('blur',function(){
                if(this.inputText.value=='')
                {
                    if (this.isPassword) this.inputText.type='text';
                    this.inputText.value=this.defaultValue;
                    this.inputText.style.color=this.options.default_text_color;
         
                }
            }.bindAsEventListener(this));
        }
        if (parentForm){
            parentForm.observe("submit",function(){
                if(this.inputText.value==this.defaultValue)
                {
                    this.inputText.value="";
                }
            }.bind(this));
        }
    },
    clone_input_password :function(){
        clone_input = document.createElement("input");
        clone_input.setAttribute("style",this.inputText.style);
        clone_input.style.color=this.options.default_text_color;
        clone_input.value = this.defaultValue;
        clone_input.type="text";
        clone_input.className = this.inputText.className;
        return $(clone_input);
    }
}

