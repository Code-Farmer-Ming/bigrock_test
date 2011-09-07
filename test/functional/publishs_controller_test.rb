require 'test_helper'

class PublishsControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  def setup
    users(:one).add_attention(users(:one))
    login_as(users(:one))
  end
  test "create" do
   
    assert_difference "LogItem.all.count" do
      assert_difference "users(:one).my_follow_log_items.count" do
        assert_difference "users(:one).my_languages.count" do
          xhr :post,:create,:my_language=>{:content=>"okk"}
        end
      end
    end
  end

  test "destroy " do

    xhr :post,:create,:my_language=>{:content=>"will destroy"}
    my_language = assigns(:my_language)
    assert_difference "LogItem.all.count",-1 do
      assert_difference "users(:one).my_follow_log_items.count",-1 do
        assert_difference "users(:one).my_languages.count",-1 do
          xhr :delete,:destroy,:id=>my_language
        end
      end
    end
  end
end
