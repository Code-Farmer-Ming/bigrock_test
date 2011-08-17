class NeedJobsController < ApplicationController
  include ActionView::Helpers::TextHelper
  before_filter :check_login?,:except=>[:show,:search,:index]
  # GET /need_jobs
  # GET /need_jobs.xml
  def index
    @page_title = "求职"
    @page_keywords = " 求职 求职信息 最新求职"
    @page_description = "发布求职信息"
    @need_jobs =NeedJob.limit(5).order("created_at desc");
  end

  # GET /need_jobs/1
  # GET /need_jobs/1.xml
  def show
    @need_job = NeedJob.find(params[:id])
    @page_description = truncate( @need_job.description,:length=>100)
    @page_title =  @need_job.title + "求职"
    @page_keywords = @need_job.skill_text
    @need_job.incre_show_count
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @need_job }
    end
  end

  # GET /need_jobs/new
  # GET /need_jobs/new.xml
  def new
    @need_job = NeedJob.new
    @page_title =  "新建求职信息"
    @need_job.skill_text=  current_user.specialities.skill_text
    @need_job.state_id = current_user.base_info.state_id
    @need_job.city_id = current_user.base_info.city_id
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @need_job }
    end
  end

  # GET /need_jobs/1/edit
  def edit
    @need_job = current_user.need_jobs.find(params[:id])
    @page_title =  "编辑求职信息"
  end

  # POST /need_jobs
  # POST /need_jobs.xml
  def create
    @need_job = current_user.need_jobs.build(params[:need_job])
    respond_to do |format|
      if @need_job.save
        flash[:notice] = '创建成功'

        if params[:is_need_broadcast]
          broadcast = @need_job.broadcasts.build({:memo=>"帮忙转发一下吧"})
          current_user.broadcasts << broadcast
          current_user.send_broadcast(broadcast,current_user.current_company_colleages,true)
          send_count = current_user.send_to_flow_me_user_broadcast(broadcast)
          if send_count>0
            flash[:notice] += ",并转发给#{send_count}个关注您的人"
          else
            flash[:notice] += ",并转发给关注您的人"
          end
        end
    
        format.html { redirect_to(@need_job) }
        format.xml  { render :xml => @need_job, :status => :created, :location => @need_job }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @need_job.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /need_jobs/1
  # PUT /need_jobs/1.xml
  def update
    @need_job = current_user.need_jobs.find(params[:id])
    respond_to do |format|
      if @need_job.update_attributes(params[:need_job])
        flash[:notice] = '修改成功'
        format.html { redirect_to(@need_job) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @need_job.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /need_jobs/1
  # DELETE /need_jobs/1.xml
  def destroy
    @need_job = current_user.need_jobs.find(params[:id])
    @need_job.destroy
    respond_to do |format|
      format.html { redirect_to(account_need_jobs_path) }
      format.xml  { head :ok }
    end
  end
  
  def batch_destroy
    params[:select_ids].each() do |item|
      current_user.need_jobs.destroy(item)
    end if params[:select_ids]
    respond_to do |format|
      format.html { redirect_to(account_need_jobs_url)   }
      format.xml  { head :ok }
    end
  end
  def search
    @page_title = "求职搜索"
    search_word = "%#{params[:search]}%"
    state_id = params[:state_id].to_i
    city_id = params[:city_id].to_i
    type_id = params[:type_id].to_i
    since_day = params[:since_day].to_i
    @need_jobs = NeedJob.since(since_day).paginate :conditions=>["(title like ? or description like ? or skill_text like ?)
      and (state_id=? or ?=0) and (city_id=? or ?=0) and (type_id=? or ?=-1)",
      search_word,search_word,search_word,state_id,state_id,
      city_id,city_id,type_id,type_id],:order=>"created_at desc", :page => params[:page]
  end

  def  auto_complete_for_need_job_skill_text
    @items =  Skill.all(:conditions =>["lower(name) like ? ","%#{params[:need_job][:skill_text].downcase}%"])
    render :inline => "<%= auto_complete_result @items, 'name', '#{params[:need_job][:skill_text]}' %>"
  end
end
