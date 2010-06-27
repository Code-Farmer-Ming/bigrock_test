# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  STAR_TITLE=['', '', '', '', '']

  #获取百分比
  def get_percent(count,sub_count)
    (count>0) ?  ((sub_count.to_f/count.to_f)*100).round(1) : 0
  end
  #日期的 文字描述
  def date_ago_in_words(date_time)
    if  date_time.to_date ==  Time.now.tomorrow.to_date
      return "明天"
    else if date_time.today?
        return  "今天"
      else if date_time.to_date== Time.now.yesterday.to_date
          return "昨天"
    
        else if date_time.to_date == (Time.now.to_date-2)
            return "前天"
          else
            localize(date_time.to_date)
          end
        end
      end
    end
  end
  
  #时间 文字描述
  def time_ago_in_words_plus(date_time)
    date_str = date_ago_in_words(date_time)
    if (Time.now.to_date - date_time.to_date)<1
      time_ago_in_words(date_time)+"前"
    elsif date_str !=date_time.to_date
      date_str +" "+ date_time.strftime('%H:%M')
    else
      localize(date_time)
    end
  end

  #通用 分块显示子块
  def  sub_block_div(title="",right_text="",&block)
    contenttag = content_tag(:div,  (right_text!="" ? content_tag(:div,right_text,:class=>"sub_block_operation") : "" )+
        ( title!="" ? content_tag(:div,title,:class=>"sub_block_title") : "")+
        (content_tag(:div,(capture(&block) if !block.blank?) ,:class=>"sub_block_content")) ,:class=>"sub_block")
    concat(contenttag)
  end
  
  #显示用户的链接
  def link_to_user_name(user,html_option={},&block)
    html_option[:href] =  (user.anonymity? || user.id==-1) ? "#" : user.is_alias? ? new_account_msg_path(:write_to=> user.salt) :  !current_user ? user_resumes_path(user)  : user_path(user)
    html_option[:title] = (user.id!=-1 && user.is_alias?) ? "我只是个马甲，单击可以给我发消息" :  user.name
    block.blank? ? content_tag(:a,user.name,html_option) : concat(content_tag(:a,capture(&block),html_option))  
  end
  # 进度条
  def process_bar(value)
    content_tag(:span,"",:class=>"process_bar",:style=>"width:#{value}px;")+"#{value}%"
  end
  


  #大星星 
  def big_star(star)
    content_tag(:span,"",:title=>STAR_TITLE[star.to_i],:class=>"big_star_#{star.to_i}").strip
  end
  #中大星星
  def middle_star(star)
    content_tag(:span,"",:title=>STAR_TITLE[star.to_i],:class=>"middle_star_#{star.to_i}").strip
  end
  #小星星
  def small_star(star)
    content_tag(:span,"",:title=>STAR_TITLE[star.to_i],:class=>"small_star_#{star.to_i}").strip
  end
  #小星星 和进度
  def small_star_and_process_bar(star,value)
    small_star(star) + process_bar(value)
  end
  # link_to_remote 可用block的
  def link_to_remote_with_block(name, options = {}, html_options = nil,&block)
    link_to("",:onclick=>remote_function(options)+ ";return false;",:href=>"#") do
      (block_given? ? concat(capture(&block)) : "").strip + name.strip
    end
  end

  def search_form(url=nil,&block)
    form_for "search",:url=> url || {:action=>'search'},:html=>{:method=>"get",:class=>"form_info"},&block
  end
end
