require 'test_helper'

class MailerServerTest < ActionMailer::TestCase
  test "forget_password" do
    @expected.subject = '重设密码'
   
    @expected.body    = read_fixture('forget_password')
    @expected.date    = Time.now
    assert_equal @expected.subject, MailerServer.create_forget_password(Token.find(:first)).subject
  end

  test "send_invite" do
    @expected.subject = Msg.find(:first).title
 
    @expected.body    = ""
    @expected.date    = Time.now
    pass = passes(:one)
    assert_equal @expected.subject, MailerServer.create_send_invite("test@email.com",pass,Msg.find(:first)).subject
  end

end
