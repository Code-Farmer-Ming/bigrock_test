# ViewTabs
module ViewTabs

  #		  target_id		 触发弹出菜单的 元素
  #			pop_id	  需要弹出的元素
  def tab_panel(id,html_option={},&block )
    contenttag= content_tag(:div, (block_given? ?  capture(&block).strip : ""),:id=>id,:class=>"panel " +(html_option[:class] || ""))
    block_given? ? concat(contenttag.strip) :  contenttag.strip
  end

  def tab_button(text,anchor_panel_id,html_option={})
    content_tag(:li, link_to(content_tag(:span,text),:anchor=>anchor_panel_id),:class=>(html_option[:class] || ""))
  end

  def tabs(id="",html_option={},&block)
    contenttag =content_tag(:div, content_tag(:ul,(capture(&block).chomp.strip if !block.blank?),:id=>id,:class=>(html_option[:class] ? html_option[:class] : "tabs")),
      :class=>"tab")
    concat(contenttag.chomp.strip)
  end

end