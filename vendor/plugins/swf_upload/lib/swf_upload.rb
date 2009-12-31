# encoding: utf-8
module SwfUpload

  
  def img_upload_field(url,default_img="",button_id=nil,options={},max_size="2 MB",types="*.png;*.jpg;*.jpeg;*.gif;",upload_button_class=nil,html_options={})
    button_id = "upload_file_placeholder" unless button_id
    upload_button_class = "upload_file_button" unless upload_button_class
    content_tag(:div ,
      image_tag(default_img,:id=>"upload_img") + content_tag(:div,content_tag(:span,"",:id=> "upload_file_placeholder"),:class=>upload_button_class),html_options)+
      hidden_field_tag(:uploaded_file_id)+
      swf_javascript(url,{:file_types=>types,:button_placeholder_id=>button_id,
        :file_types_description=>"图片文件",:file_size_limit=>max_size}.merge!(options) )
 
  end
  #      custom_settings : {
  #        upload_target : 'divFileProgressContainer'
  #      },
  #      file_size_limit : '3 MB',
  #      file_types : '*.jpg',
  #      file_types_description : 'JPG Images',
  #      file_upload_limit : '0',
  #      file_queue_error_handler : fileQueueError,
  #      file_dialog_complete_handler : fileDialogComplete,
  #      upload_progress_handler : uploadProgress,
  #      upload_error_handler : uploadError,
  #      upload_success_handler : uploadSuccess,
  #      upload_complete_handler : uploadComplete,
  #
  #			// Button Settings
  #			button_image_url : \"/images/spyglass.png\",
  #			button_placeholder_id : \"spanButtonPlaceholder\",
  #			button_width: 180,
  #			button_height: 18,
  #			button_text : '<span class=\"button\">Select Images <span class=\"buttonSmall\">(3 MB Max)</span></span>',
  #			button_text_style : '.button { font-family: Helvetica, Arial, sans-serif; font-size: 12pt; } .buttonSmall { font-size: 10pt; }',
  #			button_text_top_padding: 0,
  #			button_text_left_padding: 18,
  #			button_window_mode: SWFUpload.WINDOW_MODE.TRANSPARENT,
  #			button_cursor: SWFUpload.CURSOR.HAND,
 
  #			custom_settings : {
  #				upload_target : \"divFileProgressContainer\"
  #			},
  def swf_javascript(url,options={})
    options[:post_params] ={:authenticity_token=>"#{form_authenticity_token}"}.merge!(options[:post_params])
    options = {
      :upload_url => url,

      :debug=> :false,
      :flash_url =>"/flash/swfupload.swf",
      :button_cursor=> :"SWFUpload.CURSOR.HAND",
      :file_dialog_complete_handler=>:"function(){this.startUpload();}",
      :file_queue_error_handler=>:"function (file, errorCode, message) {alert(errorCode + message);}",
      :upload_error_handler=>:"function (file, errorCode, message) {alert(errorCode + message);}",
      :button_window_mode=> :"SWFUpload.WINDOW_MODE.TRANSPARENT",
      :upload_success_handler=>:"function (fileObj, server_data)
      { return eval(server_data) }"
    }.merge!(options )

    options[:file_dialog_complete_handler] = options[:file_dialog_complete_handler] if !options[:file_dialog_complete_handler] ||
      (!options[:up_load])
    javascript_tag " var  swfu = new SWFUpload(#{params_for_javascript(options)});"
  end
  def params_for_javascript(params) #options_for_javascript doesn't works fine

    '{' + params.map {|k, v| "#{k}: #{
      case v
      when Hash then params_for_javascript( v )
      when String then  k!=:parameters ? "'#{v}'" : v
      else v   #Isn't neither Hash or String
      end }"}.sort.join(', ') + '}'
  end

end