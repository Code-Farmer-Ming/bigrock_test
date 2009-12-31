module TextFieldDefaultValue
  #设置 input text的默认显示值
  ##id input text id
  ##default_value text defaultValue

  def text_default_value(id,default_value="",options ={})
    js_options = {}
    js_options[:default_text_color] = options[:default_text_color] || "'gray'"

    fun = "new TextDefaultValue('#{id}','#{default_value}',#{options_for_javascript(js_options)})"
    javascript_tag(fun)
  end

  def drop_list(src_id,target_id,array_value)

    script = "var options = {};"
    array_value.each do |id, subitems|
      script += "options[#{id}] = ["
  
      subitems.each do |i1,i2|
        if subitems.last[0]==i1
          script +="['#{i1}','#{i2}']"
        else
          script +="['#{i1}','#{i2}'],"
        end
      end
      script += "];"
    end
    fun =script + " new DropList('#{src_id}','#{target_id}',options)"
    javascript_tag(fun)

  end
end


