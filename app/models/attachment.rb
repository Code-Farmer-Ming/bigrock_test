# == Schema Information
#
# Table name: attachments
#
#  id           :integer       not null, primary key
#  filename     :string(255)   
#  type         :string(255)   
#  content_type :string(255)   
#  size         :integer       
#  width        :integer       
#  height       :integer       
#  parent_id    :integer       
#  thumbnail    :string(255)   
#  master_id    :integer       
#  created_at   :datetime      
#  updated_at   :datetime      
#

require 'mime/types'

class Attachment < ActiveRecord::Base
  before_save :destroy_temp
  has_attachment  :storage => :file_system

  def destroy_temp
    Attachment.destroy_all( "thumbnail is null and parent_id is null and master_id is null and created_at<'#{ 5.minutes.ago.to_s(:db)}'")
  end


  #  def swf_uploaded_data=(data)
  #    data.content_type = MIME::Types.type_for(data.original_filename)
  #    self.uploaded_data = data
  #  end
end

