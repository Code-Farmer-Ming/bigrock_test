class SettingsController < ApplicationController
  before_filter :check_login?
  
  def password
    @page_title ="设置密码"
    @user = current_user
    if request.put?
      if params[:old_password] && User.login(@user.email, params[:old_password])[0]!=0
        flash.now[:error] = "原密码错误!"
      else
        if @user.update_attributes(params[:user])
          flash.now[:success] = "设置成功!"
        else
          flash[:error] = @user.errors.full_messages.to_s
        end
      end
    end
    respond_to do |format|
      format.html {}# show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  #用户隐私设置
  def auth
    @page_title ="用户隐私设置"
    @user = current_user
    if request.put?
      if @user.setting.update_attributes(params[:user_setting])
        flash[:success] = "设置成功!"
      else
        flash[:error] = @user.errors.full_messages.to_s
      end
    end
  end
  
  def alias
    @page_title ="马甲设置"
    @alias = current_user.aliases.first
    if request.put?
      if params[:uploaded_file_id] && params[:uploaded_file_id]!=""
        @alias.icon = UserIcon.find(params[:uploaded_file_id])
      end
      if @alias.update_attributes(params[:user])
        flash[:success] = "更新成功"
      else
        flash[:error] = @alias.errors.full_messages.to_s
      end
    end
  end
  
  def base_info
    @page_title ="基本设置"
    @user = current_user
    if request.put?
      if params[:uploaded_file_id] && params[:uploaded_file_id]!=""
        @user.icon = UserIcon.find(params[:uploaded_file_id])
      end
      if @user.update_attributes(params[:user])
        flash[:success] = "设置成功!"
      else
        flash[:error] = @user.errors.full_messages.to_s
      end
    end
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }

    end
  end
end
