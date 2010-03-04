class MailerServer < ActionMailer::Base
  
  #找回密码
  def forget_password(token)
    sent_at = Time.now
    subject '重设密码'
    recipients token.user.email
    from       'tomorrownull@163.com'
    sent_on    sent_at
    content_type "text/html"
    body       :greeting => token


  end
  #发送评价邀请信息
  def send_invite(sendee,pass,msg)
    subject  "你在 #{pass.company.name} 的同事 #{pass.user.name} 邀请你对其工作进行评价"
    recipients sendee
    from       'tomorrownull@163.com'
    sent_on    Time.now
    content_type "text/html"
    body       :pass => pass,:msg=>msg,:sendee=>sendee
  end

end
