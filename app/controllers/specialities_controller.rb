class SpecialitiesController < ApplicationController
  before_filter :check_login?
  before_filter :find_speciality,:only=>[:edit,:update,:destroy]
  # GET /specialities/new
  # GET /specialities/new.xml
  def new
    @speciality = Speciality.new
    respond_to do |format|
      format.js {}
      format.html # new.html.erb
      format.xml  { render :xml => @speciality }
    end
  end

  # GET /specialities/1/edit
  def edit
    respond_to do |format|
      format.js {}
      format.html{}
    end
  end

  # POST /specialities
  # POST /specialities.xml
  def create
    @speciality = Speciality.new(params[:speciality])
    @speciality.resume_id=params[:resume_id]
    respond_to do |format|
      if @speciality.save
        format.js {}
        format.html { redirect_to(new_user_resume_speciality_path(params[:user_id],params[:resume_id])) }
        format.xml  { render :xml => @speciality, :status => :created, :location => @speciality }
      else
        flash.now[:error] = @speciality.errors.full_messages.to_s
        format.js {        }
        format.html { render :action => "new" }
        format.xml  { render :xml => @speciality.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /specialities/1
  # PUT /specialities/1.xml
  def update
    respond_to do |format|
      if @speciality.update_attributes(params[:speciality])
        format.js {}
        format.html { redirect_to(user_resume_speciality_path(params[:user_id],params[:resume_id],@speciality)) }
        format.xml  { head :ok }
      else
        flash.now[:error] = @speciality.errors.full_messages.to_s
        format.js {  }
        format.html { render :action => "edit" }
        format.xml  { render :xml => @speciality.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /specialities/1
  # DELETE /specialities/1.xml
  def destroy
    @speciality.destroy
    respond_to do |format|
      format.html { redirect_to(user_resume_specialities_url(params[:user_id],params[:resume_id])) }
      format.js {}
      format.xml  { head :ok }
    end
  end
  #查询 专长名称
  def auto_complete_for_speciality_name
    @items =  Skill.find(:all,
      :conditions =>["lower(name) like ?    ","%#{params[:speciality][:name].downcase}%"])
    render :inline => "<%= auto_complete_result @items, 'name', '#{params[:speciality][:name]}' %>"
  end

  protected

  def find_speciality
    @speciality = Speciality.find(params[:id])
  end
end
