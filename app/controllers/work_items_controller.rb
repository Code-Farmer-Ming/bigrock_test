class WorkItemsController < ApplicationController
  before_filter :check_login?
  before_filter :find_work_item,:only=>[:edit,:update,:destroy]
  # GET /work_lists/new
  # GET /work_lists/new.xml
  def new
    @work_item = WorkItem.new
    respond_to do |format|
      format.html # new.html.erb
      format.js {}
      format.xml  { render :xml => @work_item }
    end
  end

  # GET /work_lists/1/edit
  def edit
    respond_to do |format|
      format.html # new.html.erb
      format.js {}
      format.xml  { render :xml => @work_item }
    end
  end

  # POST /work_lists
  # POST /work_lists.xml
  def create
    @work_item = WorkItem.new(params[:work_item])
    @work_item.pass_id = params[:pass_id]
    respond_to do |format|
      if @work_item.save
        format.html {     flash[:notice] = 'WorkList was successfully created.'
          redirect_to(user_resume_pass_work_item_path(params[:user_id],params[:resume_id],params[:pass_id],@work_item)) }
        format.xml  { render :xml => @work_item, :status => :created, :location => @work_item }
        format.js   {}
      else
        flash.now[:error] = @work_item.errors.full_messages.to_s
        format.js {     }
        format.html { render :action => "new" }
        format.xml  { render :xml => @work_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /work_items/1
  # PUT /work_items/1.xml
  def update
    respond_to do |format|
      if @work_item.update_attributes(params[:work_item])
        format.js  {}
        format.html { flash[:notice] = 'WorkList was successfully updated.'
          redirect_to(user_resume_pass_work_item_path(params[:user_id],params[:resume_id],params[:pass_id],@work_item)) }
        format.xml  { head :ok }
      else
        flash.now[:error] = @work_item.errors.full_messages.to_s
        format.js {   }
        format.html { render :action => "edit" }
        format.xml  { render :xml => @work_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /work_lists/1
  # DELETE /work_lists/1.xml
  def destroy
    @work_item.destroy
    respond_to do |format|
      format.html { redirect_to(user_resume_pass_work_items_path(params[:user_id],params[:resume_id],params[:pass_id])) }
      format.xml  { head :ok }
      format.js {}
    end
  end

  protected

  def find_work_item
    @work_item = WorkItem.find(params[:id])
  end
end
