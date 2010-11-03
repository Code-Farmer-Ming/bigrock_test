class NeedJobsController < ApplicationController
  # GET /need_jobs
  # GET /need_jobs.xml
  def index
    @need_jobs = NeedJob.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @need_jobs }
    end
  end

  # GET /need_jobs/1
  # GET /need_jobs/1.xml
  def show
    @need_job = NeedJob.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @need_job }
    end
  end

  # GET /need_jobs/new
  # GET /need_jobs/new.xml
  def new
    @need_job = NeedJob.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @need_job }
    end
  end

  # GET /need_jobs/1/edit
  def edit
    @need_job = NeedJob.find(params[:id])
  end

  # POST /need_jobs
  # POST /need_jobs.xml
  def create
    @need_job = NeedJob.new(params[:need_job])

    respond_to do |format|
      if @need_job.save
        flash[:notice] = 'NeedJob was successfully created.'
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
    @need_job = NeedJob.find(params[:id])

    respond_to do |format|
      if @need_job.update_attributes(params[:need_job])
        flash[:notice] = 'NeedJob was successfully updated.'
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
    @need_job = NeedJob.find(params[:id])
    @need_job.destroy

    respond_to do |format|
      format.html { redirect_to(need_jobs_url) }
      format.xml  { head :ok }
    end
  end
  
  def search
    
  end
end
