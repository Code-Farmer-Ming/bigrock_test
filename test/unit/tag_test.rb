require File.dirname(__FILE__) + '/../test_helper'

class TagTest < ActiveSupport::TestCase
  fixtures :companies
  
  def setup
    @obj = Company.find(:first)
    @obj.tag_with "pale imperial"
    @obj1 = Group.find(:first)
    @obj1.tag_with "pale imperial"
  end

  def test_to_s
    assert_equal "imperial pale", Company.find(:first).tags.to_s
  end
  def test_group
    assert_equal "imperial pale", Group.find(:first).tags.to_s
  end
end
