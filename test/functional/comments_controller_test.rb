require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  def setup
    login_as(users(:one))
  end

  test "should create company topic comment" do
    topics(:one).comments.clear
    assert_difference("Comment.count", 1) do
      xhr :post ,:create, 
        :topic_id=>topics(:one).id,:comment=>{:content=>"test comment"},
        :alias=>users(:one).id
    end
    topics(:one).reload
    assert_equal 1,topics(:one).comments_count
    assert_equal users(:one), topics(:one).last_comment.user
  end
  
  test "should create  company topic comment with alias" do
    topics(:one).comments.clear
    assert_difference("Comment.count", 1) do
      xhr :post ,:create ,
        :topic_id=>topics(:one).id,:comment=>{:content=>"test comment"},
        :alias=>users(:one).aliases.first
    end
    topics(:one).reload
    assert_equal 1,topics(:one).comments_count
    assert_equal users(:one).aliases.first, topics(:one).last_comment.user
  end
  test "should create  company news comment" do
    news = news(:one)
    news.comments.clear
    assert_difference("Comment.count", 1) do
      xhr :post ,:create ,
        :piecenews_id=>news.id,:comment=>{:content=>"test comment"},
        :alias=>users(:one)
    end

  end

  test "should create  company news comment with alias" do
    news = news(:one)
    news.comments.clear
    assert_difference("Comment.count", 1) do
      xhr :post ,:create ,
        :piecenews_id=>news.id,:comment=>{:content=>"test comment"},
        :alias=>users(:one).aliases.first
    end

  end
  
  test "should destroy" do
    assert_equal 1,topics(:one).comments_count
    assert_difference("Comment.count", -1) do
      xhr :delete ,:destroy,:company_id=>topics(:one).owner.id,:topic_id=>topics(:one).id,:id=>2
    end
    topics(:one).reload
    assert_equal 0,topics(:one).comments_count
  end

  test "up" do
    xhr :post ,:up,:company_id=>topics(:one).owner.id,:topic_id=>topics(:one).id,:id=>comments(:one)
    comments(:one).reload
    assert_equal 1,comments(:one).up
  end
  test "down" do
    xhr :post ,:down,:company_id=>topics(:one).owner.id,:topic_id=>topics(:one).id,:id=>comments(:one)
    comments(:one).reload
    assert_equal 1,comments(:one).down
  end
end
