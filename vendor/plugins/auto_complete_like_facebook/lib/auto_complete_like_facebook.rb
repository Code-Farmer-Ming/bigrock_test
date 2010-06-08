# 
module AutoCompleteLikeFacebook
  #    options: {
  #    className: "pui-autocomplete",         // CSS class name prefix
  #    max: {selection: 10, selected:false},  // Max values fort autocomplete,
  #                                           // selection : max item in pulldown menu
  #                                           // selected  : max selected items (false = no limit)
  #    url: false,                            // Url for ajax completion
  #    delay: 0.2,                            // Delay before running ajax request
  #    shadow: false,                         // Shadow theme name (false = no shadow)
  #    highlight: false,                      // Highlight search string in list
  #    tokens: false,                         // Tokens used to automatically adds a new entry (ex tokens:[KEY_COMA, KEY_SPACE] for coma and spaces)
  #    unique: true                           // Do not display in suggestion a selected value
  #  }
  def auto_complete_like_facebook_field(element,options={})
    default_values = options[:defaultEntries]
   options.delete(:defaultEntries)
   options = {
       :highlight=>true
     }.merge!(options)
    function = "var pui = new UI.AutoComplete('#{element}',#{params_for_javascript(options)}"
    
    function << ");"
    if default_values then
      default_values.each { |item|      function << "pui.add('#{item[1][:text]}','#{item[1][:value]}');"  }
         javascript_tag("Event.observe(window, 'load', function() {#{function}})")
    else
      javascript_tag function
    end




  end

    def text_field_with_auto_complete_like_facebook(object, method, tag_options = {}, completion_options = {})
      url_text = url_for(:controller=>completion_options[:controller] || '', :action =>completion_options[:action] || "auto_complete_for_#{object}_#{method}" )
      text_field(object, method, tag_options) +  auto_complete_like_facebook_field("#{object}_#{method}", { :url => "#{url_text}"  }.update(completion_options))
  end
 private
   def params_for_javascript(params) #options_for_javascript doesn't works fine

    '{' + params.map {|k, v| "#{k}: #{
      case v
      when Hash then params_for_javascript( v )
      when String then  k!=:parameters ? "'#{v}'" : v
      else v   #Isn't neither Hash or String
      end }"}.sort.join(', ') + '}'
  end

  
end