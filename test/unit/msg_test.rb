require 'test_helper'

class MsgTest < ActiveSupport::TestCase

  test "blank_sendee_sender" do
    msg = Msg.new(:title=>"test_title",:content=>"test_content")
    assert !msg.save
    msg.sendee = User.find(1)
    assert !msg.save
    msg2 = Msg.new(:title=>"test_title",:content=>"test_content")
    msg2.sender = User.find(1)
    assert !msg2.save
  end
  
  test "not_blank_sendee_sender" do
    msg = Msg.new(:title=>"test_title",:content=>"test_content")
    msg.sendee = User.find(1)
    msg.sender = User.find(2)
    assert msg.save,"保存失败"
  end
  test "read_msg" do
    msg = Msg.find(1)
    assert !msg.is_check
    msg.read_msg(msg.sendee)
    assert msg.is_check
  end

  test "stop_or_destroy_msg" do
    msg = Msg.find(1)
    assert msg.can_response?
    msg.stop_or_destroy(msg.sendee)
    assert !msg.can_response?
    msg.stop_or_destroy(msg.sender)
    assert_nil Msg.find_by_id(msg.id)
  end

  test "send_to_multi_msg_ok" do
    ActionMailer::Base.deliveries.clear
    msg =Msg.new(:title=>"multi_msg_title",:content=>"multi_content")
    msg.sender_id = 2
    msg.sendees="1 3"
    assert Msg.save_all(msg),"同时发送多个信息失败"
    assert_equal 2, ActionMailer::Base.deliveries.size
  end
  test "send to self" do
    ActionMailer::Base.deliveries.clear
    msg =Msg.new(:title=>"multi_msg_title",:content=>"multi_content")
    msg.sender_id = 2
    msg.sendees="2 3"
    assert_false Msg.save_all(msg),"发给自己居然成功"
    assert_equal 0, ActionMailer::Base.deliveries.size
  end
  
  test "send_to_multi_msg_faild" do
    msg =Msg.new(:title=>"multi_msg_title",:content=>"multi_content")
    msg.sender_id = 2
    msg.sendees="zhang(1);san(9999)"
    assert !Msg.save_all(msg),msg.errors.full_messages.to_s

  end

  test "msg_response" do
    msg = msgs(:one)
    assert_equal 0, msg.msg_responses.size
    msg.response(msg.msg_responses.new(:sender_id=>1,:sendee_id=>2, :content=>"test content"))
    assert_not_nil  msg.msg_responses.find_by_content("test content")
    assert_equal 1, msg.msg_responses.size
    msg.msg_responses.find_by_content("test content").destroy
    msg.reload
    assert_equal 0, msg.msg_responses.size
  end

  test "new system msg" do
    msg =  Msg.new_system_msg(:title=>"sys title",:content=>"sys content")
    assert_difference("Msg.count",1) do
      msg.send_to(users(:two))
    end
    
  end
end
