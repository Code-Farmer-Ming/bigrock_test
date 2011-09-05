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
    group.all_members.clear
    group.add_to_member(users(:one))
    assert group.is_member?(users(:one))
    assert users(:one).my_follow_groups.exists?(group)
  end

  test "add to member with aliase" do
    group =  groups(:three)
    group.all_members.clear
    group.add_to_member(users(:one).aliases.first)
    assert group.is_member?(users(:one).aliases.first)
    assert users(:one).my_follow_groups.exists?(group)
  end
  
  test "destroy member" do
    group =  groups(:one)
    assert_difference('Member.count',-1) do
      group.remove_member(users(:one))
    end
    assert !group.is_member?(users(:one))
    assert !users(:one).my_follow_groups.exists?(group)
    users(:one).reload
 
  end

  test "related popular groups" do
    group_one =  groups(:one)
    group_two =  groups(:two)
    assert_equal 0,group_one.related_popular_groups.size
    group_two.add_to_member(users(:one))
    group_one.reload()
    assert_equal 1,group_one.related_popular_groups.size
  end

  test "log items" do
    group =  groups(:three)
    group.all_members.clear
    assert_difference("group.logable_log_items.count",2) do
      group.add_to_member(users(:three))
    end
  end
end
