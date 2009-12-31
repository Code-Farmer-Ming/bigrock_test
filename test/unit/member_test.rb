require 'test_helper'

class MemberTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "add member" do
    assert_difference("groups(:one).members_count") do
      groups(:one).all_members  << users(:user_016)
      groups(:one).reload
    end
  end
  test "destroy member" do
    groups(:one).all_members  << users(:user_016)
    groups(:one).reload
    assert_difference("groups(:one).members_count",-1) do
      groups(:one).members.find_by_user_id(users(:user_016)).destroy
      groups(:one).reload
    end
  end
end
