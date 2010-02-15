
class ResumesController < ApplicationController
  in_place_edit_for :resume, :name
  in_place_edit_for :resume,:self_description
  before_filter :check_login?,:except=>[:show]
 
 
  def render_resume
    render :partial=>"resumes/show_resume",:object=> Resume.find(params[:id])
  end
  # GET /resumes/1
  # GET /resumes/1.xml
  def show
#    @resumes = Resume.find_all_by_user_id(params[:user_id])
    @resume = Resume.find_by_id_and_user_id!(params[:id],params[:user_id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @resume }
    end
  end

  # GET /resumes/new
  # GET /resumes/new.xml
  def new
    @resume = Resume.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @resume }
    end
  end

  # GET /resumes/1/edit
  def edit
    @resume = Resume.find(params[:id])
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @resume }
      format.js {}
    end
  end

  # POST /resumes
  # POST /resumes.xml
  def create
    @resume = Resume.new(params[:resume])
    @resume.user_id = params[:user_id]
    @resume.name =  "#{@resume.user_name}的档案 #{@resume.id}"
    @resume.is_current =true
    @resume.type_name =   Resume::RESUME_TYPES[0]
    respond_to do |format|
      if @resume.save
        flash[:notice] = '简历已经创建成功.'

        format.html {
          if params[:commit]=="下一步"
            redirect_to new_user_resume_pass_path(params[:user_id],@resume)
            return
          end
          redirect_to(user_resumes_path()) }
        format.xml  { render :xml => @resume, :status => :created, :location => [:user,@resume] }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @resume.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /resumes/1
  # PUT /resumes/1.xml
  def update
    @resume = Resume.find(params[:id])
    if params[:uploaded_file_id] && params[:uploaded_file_id]!=""
      @resume.user.icon = UserIcon.find(params[:uploaded_file_id])
      current_user.reload()
    end
    respond_to do |format|
      if @resume.update_attributes(params[:resume])
        
        format.html { flash[:notice] = '简历更新成功';redirect_to( user_resumes_path()) }
        format.xml  { head :ok }
        format.js {}
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @resume.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /resumes/1
  # DELETE /resumes/1.xml
  def destroy
#    @resume = Resume.find(params[:id])
#    @resume.destroy

    respond_to do |format|
      format.html { redirect_to( user_resumes_path()) }
      format.xml  { head :ok }
      format.js {}
    end
  end
  
end
