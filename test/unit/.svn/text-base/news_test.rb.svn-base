require 'test_helper'

class NewsTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "add_sub_comments" do
    one_news = news(:one)
    one_news.comments.clear
    one_news.comments << Comment.new(:content=>"test",:user_id=>2)
    assert_equal 1,one_news.comments.count
  end
  test "destroy_sub_comments" do
    one_news = news(:one)
    assert_equal 1,one_news.comments.count
    one_comment = comments(:one)
    one_news.comments.delete(one_comment)
    assert_equal 0,one_news.comments.count
  end
  test "clear_sub_comments" do
    one_news = news(:one)
     assert_equal 1,Comment.all(:conditions=>["commentable_type=?","Piecenews"]).size
    one_news.destroy
    assert_equal 0,Comment.all(:conditions=>["commentable_type=?","Piecenews"]).size
  end
end
