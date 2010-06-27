class JobsController < ApplicationController
  include ActionView::Helpers::TextHelper
  #  before_filter :check_login?,:except=>[:show]
  #
  before_filter :find_company,:only=>[:new,:edit,:update,:create]
  # GET /jobs
  # GET /jobs.xml
  def index
    search = "%#{params[:search]}%"
    @company = Company.find_by_id(params[:company_id])
    if @company
      @jobs = @company.jobs.paginate(:conditions=>["title like ? or
                job_description like ? or skill_description like ?",
          search,search,search],:page=>params[:page])
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @jobs }
    end
  end

  # GET /jobs/1
  # GET /jobs/1.xml
  def show
    @job = Job.find(params[:id])
    @page_title = @job.title + "职位 "+  @job.owner.name
    @page_keyworks = @job.title + " 职位"
    @page_description = " 招聘职位 " +  truncate(@job.job_description,:length=>100)
    @comments = @job.comments.paginate :page=>params[:page]
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
    @job.state_id = @company.state_id
    @job.city_id = @company.city_id
    respond_to do |format|
      if @company.current_employee_and_higher_creditability(current_user)
        format.html # new.html.erb
        format.xml  { render :xml => @job }
      else
        format.html{
          flash[:error] = @company.errors.full_messages.to_s
          redirect_to @company
        }
      end
    end
  end

  # GET /jobs/1/edit
  def edit
    @job =  current_user.published_jobs.find(params[:id])
  end

  # POST /jobs
  # POST /jobs.xml
  def create
    @job = Job.new(params[:job]) 
    respond_to do |format|
      if @company.add_job(@job,current_user)
        flash.now[:notice] = '招聘信息发布成功'
        format.html { redirect_to([@company,@job]) }
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
    @job = @company.jobs.find(params[:id])
    respond_to do |format|
      if @job.update_attributes(params[:job])
        flash[:notice] = '修改成功!'
        format.html { redirect_to([@company,@job]) }
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
        if request.headers["Referer"] == company_job_url(params[:company_id],params[:id])
          redirect_to(company_jobs_path(params[:company_id]))
        else
          redirect_to(:back)
        end
      }
      format.xml  { head :ok }
    end
  end

  def batch_destroy
    params[:select_jobs].each() do |item|
      current_user.published_jobs.destroy(item)
    end
    respond_to do |format|
      format.html { redirect_to(:back) }
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

    @jobs = Job.since(since_day).paginate :select=>"jobs.*",:joins=>"join companies on jobs.company_id=companies.id" ,:conditions=>["(title like ? or job_description like ? or skill_description like ?)
      and (jobs.state_id=? or ?=0) and (jobs.city_id=? or ?=0) and (type_id=? or ?=0)
      and (company_size_id=? or ?=0) and (company_type_id=? or ?=0)",
      search_word,search_word,search_word,state_id,state_id,
      city_id,city_id,job_type,job_type,company_size,company_size,
      company_type,company_type], :page => params[:page]
  end

  protected

  def find_company
    @company =  current_user.current_companies.find(params[:company_id])
  end
end
