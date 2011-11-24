include ActionView::Helpers::TextHelper
include ActionView::Helpers
 
class TopicTextToRichText < ActiveRecord::Migration

  def self.up
    Topic.all.each do |item|
      item.content = simple_format(item.content)
      item.save
    end
  end

  def self.down
  end
end
