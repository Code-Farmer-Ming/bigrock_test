# To change this template, choose Tools | Templates
# and open the template in the editor.
class ActiveRecord::Base #:nodoc:

  module IncludeMethods
    def add_skills incoming
      tag_cast_to_string(incoming).each do |tag_name|
        begin
          skill = Skill.find_or_create_by_name(tag_name)
          raise Skill::Error, "tag could not be saved: #{tag_name}" if skill.new_record?
          skills << skill
        rescue ActiveRecord::StatementInvalid => e
          raise unless e.to_s =~ /duplicate/i
        end
      end
    end

    # Removes tags from <tt>self</tt>. Accepts a string of tagnames, an array of tagnames, an array of ids, or an array of Tags.
    def remove_skills outgoing
      outgoing = tag_cast_to_string(outgoing)
      return [] if outgoing.empty?
      outgoing_tags = skills.find_all_by_name(outgoing)
      outgoing_taggings = skill_taggings.find_all_by_skill_id(outgoing_tags.map(&:id))
      skill_taggings.destroy(*outgoing_taggings)

    end


    # Replace the existing tags on <tt>self</tt>. Accepts a string of tagnames, an array of tagnames, an array of ids, or an array of Tags.
    def skill_with list
      list = tag_cast_to_string(list)
      # Transactions may not be ideal for you here; be aware.
      Skill.transaction do
        current = skills.map(&:name)
        add_skills(list - current)
        remove_skills(current - list)
      end
    end

    # Returns the tags on <tt>self</tt> as a string.
    def skill_list #:nodoc:
      skills.reload
      skills.to_s
    end

    def skill_list=(value)
      skill_with(value)
    end

  


    def tag_cast_to_string obj #:nodoc:
      case obj
      when Array
        obj.map! do |item|
          case item
          when /^\d+$/, Fixnum then Skill.find(item).name # This will be slow if you use ids a lot.
          when Skill then item.name
          when String then item
          else
            raise "Invalid type"
          end
        end
      when String
        obj = obj.split(Skill::DELIMITER).map do |tag_name|
          tag_name.strip.squeeze(" ")
        end
      else
        raise "Invalid object of class #{obj.class} as tagging method parameter"
      end.flatten.compact.map(&:downcase).uniq
    end
  end


  include IncludeMethods

  
end

