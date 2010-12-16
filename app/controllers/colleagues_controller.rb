class ColleaguesController < ApplicationController
  # GET /colleagues
  # GET /colleagues.xml
  def index
    @colleagues = Colleague.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @colleagues }
    end
  end

  # GET /colleagues/1
  # GET /colleagues/1.xml
  def show
    @colleague = Colleague.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @colleague }
    end
  end

  # GET /colleagues/new
  # GET /colleagues/new.xml
  def new
    @colleague = Colleague.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @colleague }
    end
  end

  # GET /colleagues/1/edit
  def edit
    @colleague = Colleague.find(params[:id])
  end

  # POST /colleagues
  # POST /colleagues.xml
  def create
    @colleague = Colleague.new(params[:colleague])

    respond_to do |format|
      if @colleague.save
        flash[:notice] = 'Colleague was successfully created.'
        format.html { redirect_to(@colleague) }
        format.xml  { render :xml => @colleague, :status => :created, :location => @colleague }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @colleague.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /colleagues/1
  # PUT /colleagues/1.xml
  def update
    @colleague = Colleague.find(params[:id])

    respond_to do |format|
      if @colleague.update_attributes(params[:colleague])
        flash[:notice] = 'Colleague was successfully updated.'
        format.html { redirect_to(@colleague) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @colleague.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /colleagues/1
  # DELETE /colleagues/1.xml
  def destroy
    @colleague = Colleague.find(params[:id])
    @colleague.destroy

    respond_to do |format|
      format.html { redirect_to(colleagues_url) }
      format.xml  { head :ok }
    end
  end
end
