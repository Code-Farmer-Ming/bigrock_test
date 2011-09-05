class ConvertSignature < ActiveRecord::Migration
  def self.up
    User.real_users.each { |e|
      e.signature =  e.my_languages.current_phrase ?  e.my_languages.current_phrase.content : ""
      e.save
    }

  end

  def self.down
  end
end
