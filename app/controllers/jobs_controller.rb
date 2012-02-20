
class JobsController < ApplicationController
  uses_tiny_mce  
  include ActionView::Helpers::TextHelper
  before_filter :check_login?,:except=>[:show,:index,:search]
  #
  before_filter :find_company,:only=>[:new,:create]
  # GET /jobs
  # GET /jobs.xml
  def index
    @page_title =  "职位"
    @page_keywords = " 招聘 找工作 职位搜索"
    @page_description = "找工作，招聘职位搜索"
  end
  # GET /jobs/1
  # GET /jobs/1.xml
  def show
    @job = Job.find(params[:id])
    @page_title = @job.title + "职位 "+  @job.owner.name
    @page_keyworks = " 职位"
    @page_description = @job.owner.name + " 招聘职位," +  truncate(@job.description,:length=>100)
    @comments = @job.comments.paginate :page=>params[:page]
    @job.increment!(:view_count)
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @job }
    end
  end

  # GET /jobs/new
  # GET /jobs/new.xml
  def new
    @page_title= "创建招聘职位"
    @job = Job.new
    @job.description = "<h2>职位介绍</h2> &nbsp; <h2>要求</h2>";
    @job.state_id = @company.state_id
    @job.city_id = @company.city_id
    respond_to do |format|
      #      if @company.current_employee_and_higher_creditability(current_user)
      format.html # new.html.erb
      format.xml  { render :xml => @job }
      #      else
      #        format.html{
      #          flash[:notice] = @company.errors.full_messages.to_s
      #          redirect_to @company
      #        }
      #      end
    end
  end

  # GET /jobs/1/edit
  def edit
    @page_title= "职位编辑"
    @job =  current_user.published_jobs.find(params[:id])
  end

  # POST /jobs
  # POST /jobs.xml
  def create
    @job = Job.new(params[:job])
    @job.end_at =  Time.now
    respond_to do |format|
      if @company.add_job(@job,current_user)
        flash.now[:notice] = '招聘信息发布成功'

        if params[:is_need_broadcast]
          broadcast = @job.broadcasts.build({:memo=>"帮忙转发一下吧"})
          current_user.broadcasts << broadcast
          send_count = current_user.send_to_flow_me_user_broadcast(broadcast)
          if send_count>0
            flash[:notice] += ",并转发给#{send_count}个关注您的人"
          else
            flash[:notice] += ",并转发给关注您的人"
          end
        end
        format.html { redirect_to(@job) }
        format.xml  { render :xml => @job, :status => :created, :location => @job }
      else
        flash.now[:error] = @company.errors.full_messages.to_s+@job.errors.full_messages.to_s
        format.html { render :action => "new" }
        format.xml  { render :xml => @job.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /jobs/1
  # PUT /jobs/1.xml
  def update
    @page_title= "职位编辑"
    @job = current_user.published_jobs.find(params[:id])
    respond_to do |format|
      if @job.update_attributes(params[:job])
        flash[:notice] = '修改成功!'
        format.html { redirect_to(@job) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @job.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /jobs/1
  # DELETE /jobs/1.xml
  def destroy
    current_user.published_jobs.destroy(params[:id])
    respond_to do |format|
      format.html {
        redirect_to published_jobs_account_path()
      }
      format.xml  { head :ok }
    end
  end

  def batch_destroy
    params[:select_jobs].each() do |item|
      current_user.published_jobs.destroy(item)
    end
    respond_to do |format|
      format.html { redirect_to(published_jobs_account_path()) }
      format.xml  { head :ok }
    end
  end
  
  #搜索
  def search
    @page_title = "职位搜索"
    search_word = "%#{params[:search]}%"
    state_id = params[:state_id].to_i
    city_id = params[:city_id].to_i
    job_type = params[:job_type].to_i
    since_day = params[:since_day].to_i
    company_size = params[:company_size_id].to_i
    company_type = params[:company_type_id].to_i

    @jobs = Job.since(since_day).paginate :select=>"jobs.*",:joins=>"join companies on jobs.company_id=companies.id" ,
      :conditions=>["(title like ? or jobs.description like ? or skill_description like ? or skill_text like ?)
      and (jobs.state_id=? or ?=0) and (jobs.city_id=? or ?=0) and (type_id=? or ?=-1)
      and (company_size_id=? or ?=0) and (company_type_id=? or ?=0)",
      search_word,search_word,search_word,search_word,state_id,state_id,
      city_id,city_id,job_type,job_type,company_size,company_size,
      company_type,company_type], :page => params[:page]
  end
  
  def  auto_complete_for_job_skill_text
    @items =  Skill.all(:conditions =>["lower(name) like ? ","%#{params[:job][:skill_text].downcase}%"])
    render :inline => "<%= auto_complete_result @items, 'name', '#{params[:job][:skill_text]}' %>"
  end
  protected

  def find_company
    @company =  Company.find(params[:company_id])
  end
end
