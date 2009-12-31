class MailerServer < ActionMailer::Base
  
  #找回密码
  def forget_password(token)
    sent_at = Time.now
    subject '重设密码'
    recipients token.user.email
    from       'zhangming321@21cn.com'
    sent_on    sent_at
    content_type "text/html"
    body       :greeting => token


  end
  #发送评价邀请信息
  def send_invite(msg)
    sent_at = Time.now
    subject  msg.title
    recipients msg.sendees
    from       'zhangming321@21cn.com'
    sent_on    sent_at

    body       :greeting => msg
  end

end
