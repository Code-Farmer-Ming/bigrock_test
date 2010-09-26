require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # Replace this with your real tests.

  test "create_all_is_null" do
    user=User.new
    assert !user.valid?,"valid date fail"
    assert user.errors.invalid?("email"),"email is not nil"
    assert user.errors.invalid?(:password),"password is not nil"
  end

  test "create" do
    user=User.new
    user.nick_name = "名字"
    user.email="email@gmail.com"
    user.text_password="password"
    user.text_password_confirmation = "password"
    assert user.text_password=="password","两次输入的密码不匹配"
    assert user.valid?,user.errors.full_messages.to_s
    assert user.save,"保存失败"
    assert !user.errors.invalid?("email"),"邮箱是空"
    assert !user.errors.invalid?(:password),"密码是空"
    assert !user.errors.invalid?(:nickName),"昵称是空"

    users= User.find_all_by_email("email@gmail.com")
    assert users.length>0 ,"不存在用户"
    assert users[0].password ==User.encrypted_password("password",users[0].salt),"密码不匹配"
    assert users[0].aliases.size>0,"别名创建失败"
    assert_not_nil users[0].current_resume 
  end

  test "create_exist_email" do

    user=User.new
    user.nick_name = "名字"
    user.email="email@email.com"
    user.text_password="password"
    user.text_password_confirmation = "password"
    assert user.valid?,"user.errors"
    assert user.save,"save fail"
    assert !user.errors.invalid?("email"),"email is nil"
    assert !user.errors.invalid?(:password),"password is nil"
    assert !user.errors.invalid?(:nickName),"nickname is nil"
    
    user=User.new
    user.email="email"
    user.text_password="password"
    assert !user.valid?,user.errors
    assert !user.save,"save ok"
    assert user.errors.invalid?("email"),"email is not error"
    assert !user.errors.invalid?(:password),"password is nil"
    assert !user.errors.invalid?(:nickName),"nickname is nil"
  end

  test "seach" do
    user = User.find_all_by_email("MyStringone")
    first_resume=resumes(:one)
    assert user!=nil,"MyStringone is not exist "
    assert_equal user[0].email,"MyStringone"
    assert_equal user[0].resumes.find(:first),first_resume
  end

  test "destroy" do
    LogItem.destroy_all()
    Attention.delete_all()
    user = User.find(1)
    assert_not_nil user
    user.add_attention(users(:two))
    users(:two).add_attention(user)
    
    assert_equal user, Comment.find_by_id(2).user

    assert_difference("Attention.count",-2) do
      user.destroy
 
    end
 
    assert_nil User.find_by_id(1)
    assert_nil User.find_by_id(17)

    assert_nil Comment.find_by_id(1)
    assert_nil Comment.find_by_id(2)
    assert_nil Topic.find_by_id(1)
    assert_nil Friend.find_by_id(1)
    assert_nil LogItem.find_by_log_type_and_owner_id("Attention",1)
    assert_nil LogItem.find_by_log_type_and_owner_id("Attention",users(:two))
    
  end
  
  test "user attenion log item" do
    user = User.find(1)
    assert_difference("user.log_items.count") do
      user.add_attention(users(:two))
    end
    assert_difference("user.loged_items.count") do
      users(:two).add_attention(user)
    end
    #测试 关注 产生的 log
    assert user.log_items.exists?(LogItem.find_by_log_type_and_owner_id("Attention",user))
    assert users(:two).loged_items.exists?(LogItem.find_by_log_type_and_owner_id("Attention",user))
    
    assert users(:two).log_items.exists?(LogItem.find_by_log_type_and_owner_id("Attention",users(:two)))
    assert user.loged_items.exists?(LogItem.find_by_log_type_and_owner_id("Attention",users(:two)))
  end

  test "sub_resumes" do
    user_one = users(:one)
    resume=Resume.new()
    resume.name="resumename"
    resume.user_name ="user_name"
    resume.address=""
    resume.user_id = user_one.id
    resume.save!
    resume.reload
    user_first=User.find(1)
    sub_resume= user_first.resumes.find(resume.id)
    assert_not_nil(sub_resume)
    assert_equal sub_resume.id,resume.id

  end

  test "new_msg" do
    user= users(:one)
    assert_equal 1, user.unread_msgs.size

    new_msg = user.unread_msgs[0]
    new_msg.read_msg(user)
    user.reload
    assert_equal 0, user.unread_msgs.size

    new_msg.response(new_msg.msg_responses.build(:sender_id=>2,:sendee_id=>1,:content=>"2 send"))
    user.reload
    assert_equal 1, user.unread_msgs.size
    new_msg.read_msg(user)
    assert_equal 0, user.unread_msgs.size
    new_msg.msg_responses << new_msg.msg_responses.build(:sender_id=>1,:content=>"1 send")
    assert_equal 0, user.unread_msgs.size
  end

  test "send_msg" do
    msg = Msg.new(:sender_id=>1,:sendee_id=>2,:title=>"title",:content=>"content")
    msg.save
    user= users(:one)
    assert_equal 2, user.send_msgs.size
    assert msg.can_response?
    msg.stop_or_destroy(user)
    assert !msg.can_response?
    assert_equal 1, user.send_msgs.size
  end
  test "recive_msg" do
    msg = Msg.new(:sender_id=>2,:sendee_id=>1,:title=>"title",:content=>"content")
    msg.save
    user= users(:one)
    assert_equal 2, user.receive_msgs.size
    assert_equal 2, user.unread_msgs.size
    msg.read_msg(user)
    assert_equal 1, user.unread_msgs.size
    assert msg.can_response?
    msg.stop_or_destroy(user)
    assert !msg.can_response?
    user_two= users(:two)
    msg.stop_or_destroy(user_two)
    assert_nil  Msg.find_by_id(msg)
    assert_equal 1, user.receive_msgs.size
  end


  test "destroy_friend" do
    user =  users(:two)
    friend = user.friends.find_by_friend_id(users(:one))
    assert_difference("user.friends.count", -1) do
      friend.destroy
    end
  end

  test "user_tags" do
    user_one = users(:one)
    assert_equal 2, user_one.user_tags.size
    assert_equal 2, user_one.user_taggings.size
    
  end
  test "tag_something" do
    user_one = users(:one)
    user_three = users(:three)
    user_one.user_tags.clear
    cp =companies(:three)
    cp_2 =companies(:two)
    user_one.tag_something(cp,"大公司 好")
    assert_equal "大公司 好", cp.tag_list
    assert_equal 2,user_one.user_tags.count
    assert_equal 2, cp.taggings.count

    user_one.tag_something(cp,"大公司 500强 著名")
    assert_equal "500强 大公司 著名", cp.tag_list
    assert_equal 3,user_one.user_tags.count
    assert_equal 3, cp.taggings.count

    user_three.tag_something(cp,"欧美 it")
    user_three.tag_something(cp_2 ,"欧美")
    assert_equal 3,user_three.user_tags.count
    assert_equal 5, cp.taggings.count
    assert_equal "500强 it 大公司 欧美 著名", cp.tag_list


    user_three.tag_something(cp,"500强")
    assert_not_nil Tag.find_by_name("欧美")
    assert_nil Tag.find_by_name("it")
    assert_equal 3, cp.taggings.count
    assert_equal "500强 大公司 著名", cp.tag_list
    assert_equal 2,cp.tags.find_by_name("500强").taggings[0].user_tags.count
    user_one.tag_something(user_three,"人好 有理想")
    assert_equal 2, user_three.taggings.count
    user_one.remove_something_tag(user_three)
    assert_equal 0, user_three.taggings.count
  end

  

  test "attention_someone" do
 
    user_one = users(:one)
    user_two = users(:two)
    LogItem.destroy_all
    user_two.log_items.delete_all
    user_one.follow_me_users.clear
    user_one.targets.clear
    user_one.follow_me_users << user_two
    assert_equal 1,user_one.follow_me_users.count
    assert_equal 1, user_two.targets.count

    user_one.follow_me_users.delete(user_two)
    assert_equal 0,user_one.follow_me_users.count
    assert_equal 0, user_two.targets.count

    user_one.reload
    user_one.targets  << user_two
    assert_equal 1, user_one.targets.count
    assert_equal 1, user_one.my_follow_users.count
    assert_equal 2,user_one.my_follow_log_items.count
    assert_equal user_two,user_one.my_follow_log_items[0].owner
    assert_equal 2,user_one.my_follow_log_items.find_all_by_owner_type("User").size

    user_one.targets.delete(user_two)
    assert_equal 0, user_one.targets.count
    user_one.targets  << companies(:one)
    assert_equal 1, user_one.my_follow_companies.count
   
  end
  test "say_my_language" do
    user_one = users(:one)
    assert_equal 1,user_one.my_languages.count

    MyLanguage.destroy_all()
    user_one.say_something("say something")
    assert_equal 1,user_one.my_languages.count
    assert_equal "say something",user_one.my_phrase
    user_one.say_something("do you need some time ")
   
    assert_equal 2,user_one.my_languages.count
    assert_equal "do you need some time ",user_one.my_phrase
    user_one.destroy
    assert_equal 0, MyLanguage.all.size
  end

  test "do_recommends" do
    user_one = users(:one)
    user_one.recommends.clear
    rc =   Recommend.new()
    rc.memo ="我的的推荐"
    rc.recommendable = news(:one)
    user_one.recommends << rc
    assert_equal 1,user_one.recommends.count
    assert_equal "我的的推荐",user_one.recommends[0].memo
    assert_equal news(:one),user_one.recommends[0].recommendable
  end
  #当前所供职的公司
  test "courrent companies" do
    user_one = users(:one)
    assert_equal 1, user_one.current_companies.size
    assert_equal 1, user_one.current_resume.current_companies.size
    assert_equal companies(:one), user_one.current_companies[0]
  end
 
  test "hidden group" do
    user_one = users(:one)
    assert_equal 1, user_one.hidden_groups.count
    assert_equal groups(:three), user_one.hidden_groups.first
  end
  
  test "all group" do
    user_one = users(:one)
    assert_equal 2, user_one.all_groups.count
  end

  test "my_topic" do
    user_one = users(:one)
    assert_equal 4, user_one.my_created_topics.count
  end

  test "my reply topics with main account" do
    user_one = users(:one)
    topic_one = topics(:three)
    assert_difference("user_one.reply_topics.size",1) do
      topic_one.add_comment(topic_one.comments.new(:content=>"test reply",:user_id=>user_one.id))
    end
  end
  
  test "my reply topics with aliase account" do
    user_one = users(:one)
    topic_three = topics(:three)
    assert_difference("user_one.reply_topics.size",1) do
      topic_three.add_comment(topic_three.comments.new(:content=>"test reply",:user_id=>user_one.aliases.first.id))
    end
  end
  test "user login" do
    user_one = users(:one)
    user =nil
    #正常登陆
    code,user= User.login(user_one.email,"MyString")

    assert_equal 0, code
    assert_equal user_one,user
    #email 错误
    code,user=User.login("prefix"+user_one.email,"MyString")
    assert_equal -1, code
    #密码错误
    code,user=User.login(user_one.email,"prefix MyString")
    assert_equal -2, code
  end

  test "add friend" do
    ActionMailer::Base.deliveries.clear
    user_one= users(:one)
    assert_difference("users(:two).unread_msgs.size",1) do
      user_one.add_friend(users(:two))
    end
    assert_equal 1, user_one.friend_users.size
    assert_not_nil user_one.friend_users.find(users(:two))
    assert user_one.friend_users.exists?(users(:two))
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  test 'applied jobs' do
    user_one = users(:one)
    user_one.job_applicants.clear()
    assert_difference('user_one.job_applicants.count') do
      user_one.job_applicants << JobApplicant.new(:job_id=>1)
    end
  end

  test 'published job' do
    user_one = users(:one)
    user_one.published_jobs.clear()
    assert_difference('user_one.published_jobs.count') do
      new_job = Job.new(:company_id=>1,:city_id=>1,:title=>'title',
        :job_description=>'description',:state_id=>1,:end_at=>Time.now(),:type_id=>1)
      user_one.published_jobs << new_job
    end
  end

  test 'published jobs' do
    user_one = users(:one)
    user_one.published_jobs.clear()
    assert_difference('user_one.published_job_applicants.count') do
      new_job = Job.new(:company_id=>1,:city_id=>1,:title=>'title',
        :job_description=>'description',:state_id=>1,:end_at=>Time.now(),:type_id=>1)
      user_one.published_jobs << new_job
      new_job.reload
      user_one.job_applicants << JobApplicant.new(:job_id=>new_job.id)
    end
  end

  test "unjudge yokemates" do
    user_1 = users(:one)
    user_3=users(:three)
    user_1.current_resume.passes.clear
    user_3.current_resume.passes.clear
 
    temp_pass =  Pass.new(:company=>companies(:two),:resume=>user_1.current_resume,:begin_date=>DateTime.now,:end_date=>DateTime.now,:is_current=>true,:user=>user_1,:job_title_id=>1,:department=>"unjudge yokemates部门")
    user_1.current_resume.passes << temp_pass
    assert_difference("user_1.unjudge_yokemates(user_1.current_resume.passes.first).count") do
      assert_difference("user_3.unjudge_yokemates.count") do
        assert_difference("user_1.unjudge_yokemates.count") do
          temp_pass = user_1.current_resume.passes.first.clone
          temp_pass.resume_id = user_3.current_resume.id
          temp_pass.user_id= user_3.id
          user_3.current_resume.passes << temp_pass
        end
      end
    end
  end

  test "unjudge yokemates other not changed" do
    user_1 = users(:one)
    user_3=users(:three)
    temp_pass =  Pass.new(:company=>companies(:two),:resume=>user_1.current_resume,:begin_date=>DateTime.now,:end_date=>DateTime.now,:is_current=>true,:user=>user_1,:job_title_id=>1,:department=>"unjudge yokemates部门")
    user_1.current_resume.passes << temp_pass
    assert_difference("user_1.unjudge_yokemates(user_1.current_resume.passes.last).count",0) do
      temp_pass = user_1.current_resume.passes.first.clone
      temp_pass.resume_id = user_3.current_resume.id
      temp_pass.user_id= user_3.id
      user_3.current_resume.passes << temp_pass
    end
  end

  test "unjudge companies" do
    user_1 = users(:one)
    user_1.current_resume.passes.clear
    assert_difference("user_1.unjudge_companies.count") do
      user_1.current_resume.passes << Pass.new(:company=>companies(:three),:resume=>user_1.current_resume,:user=>user_1,:job_title_id=>1,:department=>"部门")
    end
  end
end
