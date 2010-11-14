class NeedJobsController < ApplicationController
  before_filter :check_login?,:except=>[:show,:index,:search]
  # GET /need_jobs
  # GET /need_jobs.xml
  def index
    @page_title = "我的求职列表"
    @need_jobs = current_user.need_jobs.paginate :page => params[:page]
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @need_jobs }
    end
  end

  # GET /need_jobs/1
  # GET /need_jobs/1.xml
  def show
    @need_job = NeedJob.find(params[:id])
    @page_title =  @need_job.title 
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
    @need_job = NeedJob.new(params[:need_job])
    @need_job.poster = current_user
    respond_to do |format|
      if @need_job.save
        flash[:notice] = '创建成功'
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
      format.html { redirect_to(acount_need_jobs_url) }
      format.xml  { head :ok }
    end
  end
  
  def batch_destroy
    params[:select_ids].each() do |item|
      current_user.need_jobs.destroy(item)
    end
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
    job_type = params[:job_type].to_i
    since_day = params[:since_day].to_i
    @need_jobs = NeedJob.since(since_day).paginate :conditions=>["(title like ? or description like ?)
      and (state_id=? or ?=0) and (city_id=? or ?=0)",
      search_word,search_word,state_id,state_id,
      city_id,city_id], :page => params[:page]
 
  end
end
