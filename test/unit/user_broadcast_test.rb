require 'test_helper'

class UserBroadcastTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "read" do
    user_broadcast = user_broadcasts(:one)
    assert !user_broadcast.is_read
    user_broadcast.read
    assert user_broadcast.is_read
  end
end
