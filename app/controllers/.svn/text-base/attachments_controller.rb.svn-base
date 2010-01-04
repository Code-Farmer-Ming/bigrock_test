class AttachmentsController < ApplicationController
  protect_from_forgery :except => :create
  def create
    type=params[:type]
    @icon= type.constantize.new(:uploaded_data=>params[:Filedata])
    @icon.save()
    render :update do |page|
      page["uploaded_file_id"].value = @icon.id
      page["upload_img"].src = @icon.public_filename
    end 
  rescue
    flash.now[:error]= "上传错误 #{$!}"
    render :update do |page|
      page["flash_msg"].replace_html(render(:partial=>"comm_partial/flash_msg"))
    end
  end
end
