require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "create groups name already exists" do
    group =  Group.new
    group.name = "MyString1"
    group.group_type_id=0
    group.create_user_id= 1
    group.join_type =  Group::JOIN_TYPES[0][1]
    assert !group.save,"save error"
    assert group.errors.invalid?("name")
  end

  test "create group" do
    group =  Group.new
    group.name = "MyString12"
    group.group_type_id=0
    group.create_user_id= 1
    group.join_type =  Group::JOIN_TYPES[0][1]
    assert group.save,"save error"
    group.reload
    assert group.root_members.exists?(users(:one))
  end

  test "add to member" do
    group =  groups(:three)
    group.add_to_member(users(:one))
    assert group.is_member?(users(:one))
  end

  test "destroy member" do
    group =  groups(:one)
    assert_difference('Member.count',-1) do
      group.remove_member(users(:one))
    end
    assert !group.is_member?(users(:one))
    users(:one).reload
 
  end
end
