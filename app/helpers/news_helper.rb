module NewsHelper

  def options_for_view_count(default_value)
    options_for_select([["不排序",''],["按浏览量降序",'desc'],["按浏览量升序",'asc']],default_value)
  end

  def options_for_created_order(default_value)
    options_for_select([["按发布日期降序",'desc'],["按发布日期升序",'asc']],default_value)
  end
end
