class JobsController < ApplicationController
  #  before_filter :check_login?,:except=>[:show]
  #
  before_filter :find_company,:only=>[:new,:edit,:update,:destroy]
  # GET /jobs
  # GET /jobs.xml
  def index
    search = "%#{params[:search]}%"
    @company = Company.find_by_id(params[:company_id])
    if @company
      @jobs = @company.jobs.all(:conditions=>["title like ? or job_description like ? or skill_description like ?",
          search,search,search])
      #    else
      #      @jobs = Job.all(:conditions=>["title like ? or job_description like ? or skill_description like ?",
      #          search,search,search])
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
    @page_title = @job.title + " "+  @job.company.name
    @page_keyworks = @job.title + " 职位"
    @page_description =  @job.company.name + " 招聘职位 " + @job.title+@job.job_description
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
    @job = Job.find(params[:id])
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
        flash.now[:error] = @company.errors.full_messages.to_s
        format.html { render :action => "new" }
        format.xml  { render :xml => @job.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /jobs/1
  # PUT /jobs/1.xml
  def update
    @job = Job.find(params[:id])

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
    @job = @company.jobs.find(params[:id])
    @job.destroy

    respond_to do |format|
      format.html { redirect_to(company_jobs(@company)) }
      format.xml  { head :ok }
    end
  end
  
  #搜索
  def search
    search_word = "%#{params[:search]}%"

    @jobs = Job.since(params[:since_day]).all(:conditions=>["(title like ? or job_description like ? or skill_description like ?)
      and (state_id=? or ?=0) and (city_id=? or ?=0) and (type_id=? or ?=0)",
        search_word,search_word,search_word,params[:state_id],
        params[:state_id],params[:city_id],params[:city_id],params[:job_type],params[:job_type]])
    
  end

  protected

  def find_company
    @company = Company.find(params[:company_id])
  end
end
