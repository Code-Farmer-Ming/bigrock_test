
class BaseInfosController < ApplicationController
  include ActionView::Helpers::TextHelper
  #  in_place_edit_for :resume, :name
  
  before_filter :check_login?,:except=>[:index,:render_resume]
 
  def set_self_description
    unless [:post, :put].include?(request.method) then
      return render(:text => 'Method not allowed', :status => 405)
    end
    @item = current_user.base_info
    @item.update_attribute(:self_description, params[:value])
    render :inline => "<%= simple_format( @item.self_description) %>"
  end
  
  def render_resume
#    if  Resume.find(params[:id]).user.setting.can_see_resume(current_user)
#      render :partial=>"resumes/show_resume",:object=> Resume.find(params[:id])
#    else
#      render :text=>"<div class='text_center'> <h2>详细资料已经设置为不公开</h2></div>"
#    end
  end
  
  def index
    @resume = Resume.find_by_user_id!(params[:user_id],:limit=>1)
    @page_title= "#{@resume.user.name}个人简历"
    @page_description = truncate(@resume.self_description,:length=>100)
    @page_keywords = "自我介绍,工作经历 教育 技能 评价"
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @resume }
    end
  end
  # GET /resumes/1
  # GET /resumes/1.xml
#  def show
#    #    @resumes = Resume.find_all_by_user_id(params[:user_id])
#    @resume = Resume.find_by_user_id!(params[:user_id],:limit=>1)
#    respond_to do |format|
#      format.html # show.html.erb
#      format.xml  { render :xml => @resume }
#    end
#  end

  # GET /resumes/new
  # GET /resumes/new.xml
  #  def new
  #    @resume = Resume.new
  #    respond_to do |format|
  #      format.html # new.html.erb
  #      format.xml  { render :xml => @resume }
  #    end
  #  end

  # GET /resumes/1/edit
  def edit
    @user = User.find(params[:user_id])
    @base_info =@user.base_info
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user.base_info }
      format.js {}
    end
  end

  # POST /resumes
  # POST /resumes.xml
  #  def create
  #    @resume = Resume.new(params[:resume])
  #    @resume.user_id = params[:user_id]
  #    @resume.name =  "#{@resume.user_name}的档案 #{@resume.id}"
  #    @resume.is_current =true
  #    @resume.type_name =   Resume::RESUME_TYPES[0]
  #    respond_to do |format|
  #      if @resume.save
  #        flash[:notice] = '简历已经创建成功.'
  #
  #        format.html {
  #          if params[:commit]=="下一步"
  #            redirect_to new_user_resume_pass_path(params[:user_id],@resume)
  #            return
  #          end
  #          redirect_to(user_resumes_path()) }
  #        format.xml  { render :xml => @resume, :status => :created, :location => [:user,@resume] }
  #      else
  #        format.html { render :action => "new" }
  #        format.xml  { render :xml => @resume.errors, :status => :unprocessable_entity }
  #      end
  #    end
  #  end

  # PUT /resumes/1
  # PUT /resumes/1.xml
  def update
    @user = User.find(params[:user_id])
    if params[:uploaded_file_id] && params[:uploaded_file_id]!=""
      @user.icon = UserIcon.find(params[:uploaded_file_id])
      @user.reload()
    end
    respond_to do |format|
      if @user.base_info.update_attributes(params[:base_info])
        
        format.html { flash[:notice] = '简历更新成功'; }
        format.xml  { head :ok }
        format.js {}
      else
        format.js {}
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.base_info.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /resumes/1
  # DELETE /resumes/1.xml
#  def destroy
#    #    @resume = Resume.find(params[:id])
#    #    @resume.destroy
#
#    respond_to do |format|
#      format.html { redirect_to( user_resumes_path()) }
#      format.xml  { head :ok }
#      format.js {}
#    end
#  end
  
end
