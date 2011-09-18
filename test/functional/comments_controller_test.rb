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
    assert_equal users(:one), topics(:one).last_comment_user
   
    assert_equal 1, users(:one).reply_topics.size
  end
  
  test "should create  company topic comment with alias" do
    topics(:one).comments.clear
    assert_difference("Comment.count", 1) do
      xhr :post ,:create ,
        :topic_id=>topics(:one).id,:comment=>{:content=>"test comment"},
        :alias=>users(:one).alias
    end
    topics(:one).reload
    assert_equal 1,topics(:one).comments_count
    assert_equal users(:one).alias, topics(:one).last_comment_user
#    assert_equal 1, users(:one).join_topics.size
  end

  test "should create  company job comment" do
    job = jobs(:one)
    job.comments.clear
    assert_difference("Comment.count", 1) do
      xhr :post ,:create,
        :job_id=>job.id,:comment=>{:content=>"test comment"},
        :alias=>users(:one)
    end
    job.reload
    assert_equal 1, job.comments.size
  end

  test "should create  company job comment with alias" do
    job = jobs(:one)
    job.comments.clear
    assert_difference("Comment.count", 1) do
      xhr :post ,:create ,
        :job_id=>job.id,:comment=>{:content=>"test comment"},
        :alias=>users(:one).alias
    end
    job.reload
    assert_equal 1, job.comments.size
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
