class JobApplicantsController < ApplicationController
  before_filter :find_job, :except=>[:show,:batch_destroy,:destroy]
  before_filter :check_login?,:except=>[:index]
  # GET /job_applicants
  # GET /job_applicants.xml
  def index
    @job_applicants = @job.applicants.paginate :page=>params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @job_applicants }
    end
  end

  # GET /job_applicants/1
  # GET /job_applicants/1.xml
  def show
    @job_applicant = current_user.published_job_applicants.find(params[:id])
    @job_applicant.read
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @job_applicant }
    end
  end

  # GET /job_applicants/new
  # GET /job_applicants/new.xml
  def new
    @job_applicant = JobApplicant.new(:applicant_id=>current_user.to_param)
    respond_to do |format|
      format.html # new.html.erb
      format.js
      format.xml  { render :xml => @job_applicant }
    end
  end
  
  #推荐人才
  def recommend_talent
    @job_applicant = JobApplicant.new(:recommend_user => current_user)
  end

  # POST /job_applicants
  # POST /job_applicants.xml
  def create
    @job_applicant = JobApplicant.new(params[:job_applicant])
    respond_to do |format|
      if @job.apply_job(@job_applicant)
        flash.now[:success] = '申请成功！'
        format.html { redirect_to(@job_applicant) }
        format.js {
          render :update do |page|
            page << "Lightbox.close()"
            page["flash_msg"].replace_html render(:partial=>"comm_partial/flash_msg")
          end
        }
        format.xml  { render :xml => @job_applicant, :status => :created, :location => @job_applicant }
      else
        flash.now[:error] = @job.errors.full_messages.to_s
        format.html { render :action => "new" }
        format.js{
          render :update do |page|
            page["lightbox_msg"].replace_html render(:partial=>"comm_partial/flash_msg")
          end
        }
        format.xml  { render :xml => @job_applicant.errors, :status => :unprocessable_entity }
      end
    end
  end

  
  # DELETE /job_applicants/1
  # DELETE /job_applicants/1.xml
  def destroy
    @job_applicant = JobApplicant.find(params[:id])
    @job_applicant.try_destroy(current_user)

    respond_to do |format|
      format.html { redirect_to(:back) }
      format.xml  { head :ok }
    end
  end

 
  #成批删除申请记录
  def batch_destroy
    params[:select_applicants].each() do |item|
      @job_applicant = JobApplicant.find(item)
      @job_applicant.try_destroy(current_user)
    end
    redirect_to(:back)
  end

  protected

  def find_job
    @job = Job.find(params[:job_id])
  end
end
