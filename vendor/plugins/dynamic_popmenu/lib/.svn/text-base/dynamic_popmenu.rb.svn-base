# DynamicPopmenu
module DynamicPopmenu

  #		  target_id		 触发弹出菜单的 元素
  #			pop_id	  需要弹出的元素
  def popmenu(target_id,pop_id )
    function ="  new DynamicPopmenu('#{target_id}','#{pop_id }')"
    javascript_tag(function)
  end
 
  def menu_item(content="",html_option={},&block)
    contenttag= content_tag(:li, (block_given? ? content + capture(&block).strip : content.strip),:class=>(html_option[:class] || ""))
    block_given? ? concat(contenttag.strip) :  contenttag.strip
  end
  
  def menu(id,html_option={},&block)
    contenttag = content_tag(:ul,(capture(&block).chomp.strip if !block.blank?),:id=>id,:class=>(html_option[:class] ? html_option[:class] : "popmenu"),:style=>"display:none")
    concat(contenttag.chomp.strip)
  end

end