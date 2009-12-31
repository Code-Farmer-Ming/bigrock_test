require 'test_helper'

class LogItemTest < ActiveSupport::TestCase

  test "create_and_destroy_edu" do
    resume = resumes(:one)
    assert_equal 2,LogItem.all.size
    assert_equal 1,resume.educations.count
    edu =  Education.new(:school_name=>"test")
    LogItem.destroy_all
    #产生一次 create记录
    resume.educations << edu
    resume.save!
    assert_equal 2,resume.educations.count
    assert_not_nil Education.find_by_id(edu)
    assert_equal 1,LogItem.all.size
    assert_equal 1,LogItem.find_all_by_log_type("resume").size
    assert_equal 1,LogItem.find_all_by_log_type_and_operation("resume","create").size
    edu.update_attribute("school_name", "new_name")
    
    assert_equal 1,LogItem.all.size
    assert_equal 1,LogItem.find_all_by_log_type("resume").size
    assert_equal 0,LogItem.find_all_by_log_type_and_operation("resume","update").size
    
    assert_equal 1,edu.log_items.count
    assert_equal 1,resume.user.log_items.count
    #这里由于做了 两次 acts_as_logger 会产生两个 update的记录
    Education.acts_as_logger :log_action=>["create","update","destroy"],:owner_attribute=>"resume.user",:log_type=>"resume"
    edu.update_attribute("school_name", "new_new_name")
    #产生一次destroy的记录 会把本身所有的 记录删除
    edu.destroy
    assert_equal 0,LogItem.all.size
  end
  test "create_and_destroy_friend" do
    user_one = users(:one)
    user_two = users(:two)
    user_one.friends_user <<  user_two
    assert_equal 1,LogItem.find_all_by_log_type_and_operation("Friend","create").size
    friend = user_one.friends.find_by_friend_id(user_two)
    friend.destroy
    assert_equal 1,LogItem.find_all_by_log_type_and_operation("Friend","destroy").size
  end
  
  test "create_and_destroy_attention" do
    user_one = users(:one)
    user_two = users(:two)
    user_one.my_follow_users << user_two
    assert_equal 1,LogItem.find_all_by_log_type_and_operation("Attention","create").size

#    au =  user_one.my_follow_collection.find_by_target_id(user_two)
#    au.destroy
    #这种那个办法 有问题 可能rails没有完善
    user_one.targets.delete(user_two)
    assert_equal 1,LogItem.find_all_by_log_type_and_operation("Attention","destroy").size
    assert_equal 1,LogItem.find_all_by_log_type_and_operation("Attention","create").size
    user_two.reload()
    assert_not_nil( user_two)
  end

  test "create_pass" do
    user_one = users(:one)
    company_three = companies(:three)
    pass=Pass.new
    pass.user = user_one
    pass.company_id = 3
    user_one.current_resume.passes << pass
    assert_equal 1,company_three.log_items.size
    assert_equal 2,user_one.log_items.size
  end

  test "create_news" do
    one_company = companies(:one)
    piece_news = Piecenews.new
    piece_news.title ="一则新闻"
    piece_news.content = "新闻的内容"
    piece_news.create_user = users(:one)
    one_company.news << piece_news
    assert_equal 1,LogItem.find_all_by_log_type_and_operation("company_news","create").size
    assert_equal 1,LogItem.find_all_by_log_type_and_operation("company_news","create").size
  end
  test "create_and_destroy_recommend" do
    user_one = users(:one)
    recommend = Recommend.new()
    recommend.memo = "my recommend"
    recommend.recommendable = news(:one)
    user_one.recommends << recommend
    assert_equal 1,LogItem.find_all_by_log_type_and_operation("Recommend","create").size
    recommend.destroy
    assert_equal 0,LogItem.find_all_by_log_type_and_operation("Recommend","create").size

  end


end
