require 'test_helper'

class SpecialityTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "add new" do
    speci = Speciality.create(:name=>"new",:description=>"descirption")
    assert_equal("new", speci.name)
  end
  
  test "destroy" do
    assert_equal(2,Skill.count)
    specialities(:one).destroy
    assert_equal(1,Skill.count)
  end

  test "destroy mult skill" do
    assert_equal(2,Skill.count)
    speci = Speciality.create(:name=>skills(:one).name,:description=>"descirption")
    specialities(:one).destroy
    assert_equal(2,Skill.count)
  end
end
