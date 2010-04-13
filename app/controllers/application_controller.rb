# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  helper_method :current_user,:current_user?,:login?
  
  def login?
    current_user != nil
  end
  #检查是否登录
  def check_login?
    if (cookies[:auto_login_user_id].nil?)
      if request.xhr?
        redirect_to login_account_path(:js)
      else
        flash[:notice] = "请先登录后才能进行操作"
        redirect_to login_account_path(:reurl=>url_for())
      end
    else
      user=User.real_users.find_by_id(cookies[:auto_login_user_id])
      if (user)
        return set_user_session(user)
      else
        flash.now[:notice] = auth_text
        redirect_to login_account_path()
      end
    end if (user_session.nil?)
  end
  #将用户 id 保存到 session[:user]
  def set_user_session(user=nil)
    if user
      session[:user]= user.id
    else
      session[:user]=nil
    end
  end
  
  #获取 session[:user]的值
  def user_session
    session[:user]
  end

  #获取当前用户
  def current_user
    User.real_users.find(user_session) if user_session
  end
  #判断是否 当前 用户
  def current_user?(user)
    user && current_user &&   current_user.accounts.include?(user)
  end
 
end
