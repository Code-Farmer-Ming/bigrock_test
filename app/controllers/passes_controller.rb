class PassesController < ApplicationController
  before_filter :check_login?
  before_filter :find_pass,:only=>[:edit,:update,:destroy,:available_yokemates]
  auto_complete_for :company, :name
 
  # GET /passes/new
  # GET /passes/new.xml
  def new
    @pass = Pass.new
    @page_title= "添加工作经历"
    if params[:request_company_id]
      flash[:notice] = "再填写一下你的资料"
      @pass.company_id = params[:request_company_id]
    end
    respond_to do |format|
      format.html {} # new.html.erb
      format.js {}
      format.xml  { render :xml => @pass }
    end
  end

  # GET /passes/1/edit
  def edit
    respond_to do |format|
      format.js {}
      format.html # new.html.erb
    end
  end

  # POST /passes
  # POST /passes.xml
  def create
    @pass = Pass.new(params[:pass])
    #TODO 这里需要优化 去掉查询公司名称
    @company= Company.find_by_name(params[:company][:name])
    @pass.resume_id = params[:resume_id]
    @pass.user = current_user
    if !@company
      if (request.xhr?)
        render :update do |page|
          page << "Lightbox.show('#{new_company_path(:"company[name]"=>params[:company][:name])}');"
        end
      else
        redirect_to new_company_path(:"company[:name]"=>params[:company][:name])
      end
      return
    end

    respond_to do |format|
      if @company.passes << @pass
        format.html {
          flash[:notice] = '保存成功.'
          redirect_to  user_path(params[:request_user_id] && params[:request_user_id].any? ? params[:request_user_id] : params[:user_id])
        }
        format.xml  { render :xml => @pass, :status => :created, :location => @pass }
        format.js {    }
      else
        flash.now[:error] = @pass.errors.full_messages.to_s
        format.js {    }
        format.html { render :action => "new" }
        format.xml  { render :xml => @pass.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /passes/1
  # PUT /passes/1.xml

  def update
    #TODO 这里需要优化 去掉查询公司名称
    #    if @pass.company.name != params[:company][:name]
    #      @company= Company.find_by_name(params[:company][:name])
    #      if !@company
    #        if (request.xhr?)
    #          render :update do |page|
    #            page << "Lightbox.show('#{new_company_path(:"company[name]"=>params[:company][:name])}');"
    #          end
    #        else
    #          redirect_to new_company_path(:company[name]=>params[:company][:name])
    #        end
    #        return
    #      end
    #       @pass.company = @company
    #    end
    respond_to do |format|
      if @pass.update_attributes(params[:pass])
        format.html {flash[:notice] = '更新成功！.'; redirect_to( user_resume_path(params[:user_id],params[:resume_id])) }
        format.xml  { head :ok }
        format.js {}
      else
        flash.now[:error] = @pass.errors.full_messages.to_s
        format.js {   }
        format.html { render :action => "edit" }
        format.xml  { render :xml => @pass.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /passes/1
  # DELETE /passes/1.xml
  def destroy
    @pass.destroy
    respond_to do |format|
      format.js {}
      format.html { redirect_to( user_resume_passes_path(params[:user_id],params[:resume_id])) }
      format.xml  { head :ok }
    end
  end
  #同事
  def  available_yokemates
    @msg = Msg.new(params[:msg])
  end
  #发送评价邀请信息
  #TODO 发送错误时候需要检查
  def send_invite
    @msg = Msg.new(params[:msg])
    pass = Pass.find(params[:id])
    #发送邮件
    #检查邮件地址是否有效
    @msg.sendees.split(";").uniq.each do |sendee|
      if !validate_email?(sendee)
        flash.now[:error] = (flash.now[:error] || '') + sendee + " "
      end
      if  flash.now[:error]
        flash.now[:error] += "无效的邮箱地址！"
        return
      end
    end

    #发送站内信息
    if (params[:yokemates])
      @msg.sender = current_user
      @msg.sender_stop = true
      @msg.title = "你在 #{pass.company.name} 的同事 #{current_user.name} 邀请你对其工作进行评价"
      @msg.content += "你好<br />我是你在<a href=' #{company_url(pass.company)}' >#{ pass.company.name}</a>的同事"+
        "<a href=' #{user_url(current_user)}' > #{current_user.name}</a>，<br/>赶快来<a href=' #{user_url(current_user)}' >评价我</a>吧!"
      Msg.transaction do
        params[:yokemates].each do |id|
          new_msg = @msg.clone
          new_msg.sendee_id = id
          if  !new_msg.save
            ActiveRecord::Rollback
            flash.now[:error] =new_msg.errors.full_messages.to_s
            return
          end
        end
      end
    end
    @msg.sendees.split(";").uniq.each do |sendee|
      MailerServer.deliver_send_invite(sendee,pass,@msg)
    end
  end


  #  def auto_complete_for_company_name
  #    @items =  Company.find(:all,:conditions =>["name like ?","%#{params[:company][:name]}%"] )
  ##    items_content = @items.map { |entry| content_tag("li",  highlight(entry[field],params[:company][:name])+  content_tag(:p,entry.short_info)) }
  #     render(:inline=>"<ul><%= render(:partial=>'companies/auto_complete_info',:collection=>@items)%></ul>")
  #  end
  #根据公司 查询 对应的部门
  def auto_complete_for_pass_department
    @items =  Pass.find(:all,:conditions =>"lower(companies.name)=lower('#{params[:company][:name]}')",:joins =>"join companies on companies.id=passes.company_id",:select=>"distinct department" )
    render :inline => "<%= auto_complete_result @items, 'department', '#{params[:pass][:department]}' %>"
  end

  #根据公司 查询 对应的部门
  def auto_complete_for_pass_title
    @items =  Pass.find(:all,:conditions =>"lower(companies.name)=lower('#{params[:company][:name]}') ",:joins =>"join companies on companies.id=passes.company_id",:select=>"distinct title" )
    render :inline => "<%= auto_complete_result @items, 'title', '#{params[:pass][:title]}' %>"
  end


  protected
  #是否合法的 email 地址
  def validate_email?(email)
    email=~/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  end
  def find_pass
    @pass=Pass.find(params[:id])
  end
 

end
