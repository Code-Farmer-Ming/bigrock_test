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
    msg =Msg.new(:title=>"multi_msg_title",:content=>"multi_content")
    msg.sender_id = 2
    msg.sendees="zhang(1);san(2)"
    assert Msg.save_all(msg),"同时发送多个信息失败"

  end
  test "send_to_multi_msg_faild" do
    msg =Msg.new(:title=>"multi_msg_title",:content=>"multi_content")
    msg.sender_id = 2
    msg.sendees="zhang(1);san(9999)"
    assert !Msg.save_all(msg),"包含错误地址但发生成功"

  end

  test "msg_response" do
    msg = msgs(:one)
    assert_equal 2, msg.msg_responses.size
    msg.msg_responses << MsgResponse.new(:content=>"test content")
    assert_not_nil  msg.msg_responses.find_by_content("test content")
    assert_equal 3, msg.msg_responses.size
    MsgResponse.destroy(2)
    assert_equal 2, msg.msg_responses.size
  end
end
