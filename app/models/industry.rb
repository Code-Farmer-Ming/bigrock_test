# == Schema Information
#
# Table name: industries
#
#  id   :integer       not null, primary key
#  name :string(255)   
#

class Industry < ActiveRecord::Base
  has_many :companies
end
