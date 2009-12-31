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

class CompanyIcon < Attachment
  has_attachment :content_type => :image,
    :min_size => 0.kilobytes,
    :max_size => 10.megabytes,
    :resize_to => '100x100>' ,#120*90
    :thumbnails   => { :thumb => '68x68>' },
    :path_prefix => 'public/images/upload/company_img'
  validates_as_attachment
  belongs_to :company ,:foreign_key => "master_id"

end
