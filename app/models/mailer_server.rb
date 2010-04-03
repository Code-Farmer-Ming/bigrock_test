class MailerServer < ActionMailer::Base
  FROM_MAIL= "no-reply@shuikaopu.com"
  #找回密码
  def forget_password(token)
    sent_at = Time.now
    subject '重设密码'
    recipients token.user.name_with_email
    from       FROM_MAIL
    sent_on    sent_at
    content_type "text/html"
    body       :greeting => token


  end
  #发送评价邀请信息
  def send_invite(sendee,pass,msg)
    subject   msg.title
    recipients sendee
    from       FROM_MAIL
    sent_on    Time.now
    content_type "text/html"
    body       :pass => pass,:msg=>msg,:sendee=>sendee
  end

  #收到新的消息时 发送邮件通知
  def get_new_msg(msg)
    subject   "您有新的消息 - "+msg.title
    recipients msg.sendee.name_with_email
    from       FROM_MAIL
    sent_on    Time.now
    content_type "text/html"
    body       :msg =>msg
  end

  #添加好友申请 发邮件通知
  def apply_friend_msg(reuisition_invite)
    subject   "[#{reuisition_invite.applicant.name}] 请求加你为好友"
    recipients reuisition_invite.respondent.name_with_email
    from       FROM_MAIL
    sent_on    Time.now
    content_type "text/html"
    body       :reuisition =>reuisition_invite
  end
  #加入小组邀请  applicant_id   :integer
#  respondent_id
  def join_group_invite(reuisition_invite)
    subject   "好友[#{reuisition_invite.applicant.name}] 邀请你加入小组"
    recipients reuisition_invite.respondent.name_with_email
    from       FROM_MAIL
    sent_on    Time.now
    content_type "text/html"
    body       :reuisition =>reuisition_invite
  end

end
