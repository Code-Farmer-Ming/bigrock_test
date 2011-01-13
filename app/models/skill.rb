# == Schema Information
#
# Table name: skills
#
#  id         :integer       not null, primary key
#  name       :string(255)   
#  created_at :datetime      
#  updated_at :datetime      
#

class Skill < ActiveRecord::Base
  has_many :specialities
 
  def before_destroy
    self.specialities.count==0
  end

  DELIMITER = " " # Controls how to split and join tagnames from strings. You may need to change the <tt>validates_format_of parameters</tt> if you change this.

  # If database speed becomes an issue, you could remove these validations and rescue the ActiveRecord database constraint errors instead.
  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false
  

  # Change this validation if you need more complex tag names.
#  validates_format_of :name, :with => /^[a-zA-Z0-9\_\-]+$/, :message => "can not contain special characters"

  # Set up the polymorphic relationship.
  has_many_polymorphs :taggables,
    :from => [:jobs,:need_jobs],
    :through => :skill_taggings,
    :dependent => :destroy,
    :skip_duplicates => false,
    :parent_extend => proc {
      # Defined on the taggable models, not on Tag itself. Return the tagnames associated with this record as a string.
      def to_s
        self.map(&:name).sort.join(Skill::DELIMITER)
      end
    }

  # Callback to strip extra spaces from the tagname before saving it. If you allow tags to be renamed later, you might want to use the <tt>before_save</tt> callback instead.
  def before_create
    self.name = name.downcase.strip.squeeze(" ")
  end

  # Tag::Error class. Raised by ActiveRecord::Base::TaggingExtensions if something goes wrong.
  class Error < StandardError
  end
end
