# == Schema Information
#
# Table name: base_infos
#
#  id               :integer       not null, primary key
#  type_name        :string(18)    
#  user_id          :integer       
#  birthday         :date          
#  sex              :boolean       
#  address          :string(255)   
#  mobile           :string(255)   
#  telephone        :string(255)   
#  phone3           :string(255)   
#  phone4           :string(255)   
#  blog_website     :string(255)   
#  personal_website :string(255)   
#  website3         :string(255)   
#  website4         :string(255)   
#  self_description :text          
#  goal             :string(255)   
#  interests        :string(255)   
#  qq               :string(255)   
#  msn              :string(255)   
#  city             :string(255)   
#  industry         :string(255)   
#  is_current       :boolean       
#  created_at       :datetime      
#  updated_at       :datetime      
#  city_id          :integer       
#  state_id         :integer       
#

class BaseInfo < ActiveRecord::Base
  #简历类型
  #  RESUME_TYPES=["中文","英文"]
  #  validates_format_of :blog_website, :with =>  /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix

  belongs_to :state
  belongs_to :city
  belongs_to :user,:class_name=> "User",:foreign_key =>"user_id"
  attr_accessor :user_name
  #  has_many :passes,:dependent=>:destroy ,:order=>"begin_date desc,is_current desc"
  #  has_many :current_passes,:class_name=>"Pass",:conditions=>{:is_current=>true}
  #经历过的公司  包含当前公司的
  #  has_many :pass_companies ,:through=>:passes,:source=>:company
  #  has_many :current_companies ,:through=>:current_passes,:source=>:company
  
  #  has_many :educations,:dependent=>:destroy,:order=>"begin_date desc"
  #  has_many :specialities,:dependent=>:destroy do
  #    def skill_text
  #      self.map(&:name).sort.join(Skill::DELIMITER)
  #    end
  #  end
  #  has_many :skills,:through=>:specialities,:source=>:skill
  #
  #   def skill_list
  #    skills.reload
  #    skills.to_s
  #  end
  
  def user_name=(value)
    user.nick_name = value
    user.save
  end
  
  def user_name
    user.nick_name
  end
end
