# == Schema Information
#
# Table name: members
#
#  id         :integer       not null, primary key
#  group_id   :integer       not null
#  user_id    :integer       not null
#  type       :string(18)    default("Normal")
#  created_at :datetime      
#  updated_at :datetime      
#

class Manager < Member

end
