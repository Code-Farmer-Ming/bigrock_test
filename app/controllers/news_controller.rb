class NewsController < ApplicationController
  before_filter :check_login?,:except=>[:show,:index,:search]
  # GET /news
  # GET /news.xml
  def index
    order_str =  (params[:view_count] && !params[:view_count].blank?  ?  "view_count " + (params[:view_count].to_s=="asc" ? 'asc' : 'desc') : nil)

    if !order_str
      order_str =  params[:created_order] && !params[:created_order].blank?  ? "created_at "+ (params[:created_order].to_s=='asc' ? 'asc' : 'desc') : "created_at desc"
    else
      order_str +=  params[:created_order] && !params[:created_order].blank?  ? ",created_at "+ (params[:created_order].to_s=='asc' ? 'asc' : 'desc') : ""
    end
    search_str = "%"+params[:search].to_s.strip+"%"
    
    if params[:company_id] then
      @company = Company.find(params[:company_id])
      @news = @company.news.paginate :conditions=>["title like ? or content like ? ",
        search_str, search_str],:order=>order_str,:page => params[:page]
      @hot_news=@company.news.hot(:limit=>10)
      @higher_scope_news=  @company.news.highter_scope(:limit=>10)
      @higher_scope_comments =  Comment.news_comments.higher_scope(:conditions=>["commentable_id=?",@company],:limit=>10)
      @page_title =   "#{@company.name} 公司博客"
    else
      @news = Piecenews.paginate :conditions=>["title like ? or content like ? ",
        search_str, search_str],:order=>order_str,:page => params[:page]
      @hot_news=Piecenews.hot(:limit=>10)
      @higher_scope_news=  Piecenews.highter_scope(:limit=>10)
      @higher_scope_comments = Comment.news_comments.higher_scope(:limit=>10)
      @page_title =   "公司博客"
    end
      
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @news }
    end
  end

  # GET /news/1
  # GET /news/1.xml
  def show
    @piece_of_news = Piecenews.find(params[:id])
    @company = @piece_of_news.owner
    @is_manager  =@company.current_employee?(current_user)
    @comments = @piece_of_news.comments.paginate :page => params[:page]
    @page_title= "公司博客 " + @piece_of_news.title
    @piece_of_news.update_attribute(:view_count, @piece_of_news.view_count+1)
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @piece_of_news }
    end
  end

  # GET /news/new
  # GET /news/new.xml
  def new
    @page_title = "发布公司博客"
    @company = Company.find(params[:company_id])
    if @company.all_employees.exists?(current_user)
      if !@company.higher_creditability_employees.exists?(current_user)
        flash[:notice]="资料真实度需要4星，才可以发布公司博客！"
        redirect_to @company
      else
        @piece_of_news = Piecenews.new
      end
    else
      flash[:notice] = "必须是公司的员工，才能发布公司博客"
      redirect_to @company
    end
  end

  # GET /news/1/edit
  def edit
    @company = Company.find(params[:company_id])
    
    if @company.all_employees.exists?(current_user)
      if !@company.higher_creditability_employees.exists?(current_user)
        flash[:notice]="资料真实度需要4星，才可以编辑公司博客！"
        redirect_to @company
        return
      end
    else
      flash[:notice] = "必须是公司的员工，才可以编辑公司博客！"
      redirect_to @company
      return
    end
    @piece_of_news = @company.news.find_by_id(params[:id])
    @page_title= @piece_of_news.title+ " 编辑"
  end

  # POST /news
  # POST /news.xml
  def create
    @piece_of_news = Piecenews.new(params[:piecenews])
    @company = Company.find(params[:company_id])
    @piece_of_news.create_user = current_user
    respond_to do |format|
      if @company.news << @piece_of_news
        flash[:success] = '公司博客创建成功'
        format.html { redirect_to( company_piecenews_path(@company,@piece_of_news)) }
        format.xml  { render :xml => @piece_of_news, :status => :created, :location => @piece_of_news }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @piece_of_news.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /news/1
  # PUT /news/1.xml
  def update
    @piece_of_news = Piecenews.find(params[:id])
    @piece_of_news.last_edit_user = current_user
    respond_to do |format|
      if @piece_of_news.update_attributes(params[:piecenews])
        flash[:success] = '公司博客修改成功'
        format.html { redirect_to(company_piecenews_path(params[:company_id],@piece_of_news)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @piece_of_news.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /news/1
  # DELETE /news/1.xml
  def destroy
    @company = Company.find(params[:company_id])
    if @company.all_employees.exists?(current_user)
      if !@company.higher_creditability_employees.exists?(current_user)
        flash[:notice]="资料真实度需要4星，才可以编辑公司博客！"
        redirect_to @company
        return
      end
    else
      flash[:notice] = "必须是公司的员工，才可以编辑公司博客！"
      redirect_to @company
      return
    end
    @piece_of_news = Piecenews.find_by_id_and_company_id(params[:id],params[:company_id])
    @piece_of_news.destroy
    respond_to do |format|
      format.html { redirect_to(company_news_url(params[:company_id])) }
      format.xml  { head :ok }
    end
  end
  #顶 公司博客
  def up
    @piece_news = Piecenews.find(params[:id])
    @piece_news.add_vote(Vote.new(:value=>1,:user=>current_user))
    render :partial => "comm_partial/update_up_down_panel",:object=> @piece_news
  end
  #踩 公司博客
  def down
    @piece_news = Piecenews.find(params[:id])
    @piece_news.add_vote(Vote.new(:value=>-1,:user=>current_user))
    render :partial => "comm_partial/update_up_down_panel",:object=> @piece_news
  end
  #搜索公司博客
  def search
    @page_title= "公司博客搜索"
    order_str =  (params[:view_count] && !params[:view_count].blank?  ?  "view_count " + (params[:view_count].to_s=="asc" ? 'asc' : 'desc') : nil)

    if !order_str
      order_str =  params[:created_order] && !params[:created_order].blank?  ? "created_at "+ (params[:created_order].to_s=='asc' ? 'asc' : 'desc') : "created_at desc"
    else
      order_str +=  params[:created_order] && !params[:created_order].blank?  ? ",created_at "+ (params[:created_order].to_s=='asc' ? 'asc' : 'desc') : ""
    end
    search_str = "%"+params[:search].to_s.strip+"%"
    if params[:company_id] then
      @company = Company.find(params[:company_id])
      @news = @company.news.paginate :conditions=>["title like ? or content like ? ",
        search_str, search_str],:order=>order_str,:page => params[:page]
    else
      @news = Piecenews.paginate :conditions=>["title like ? or content like ? ",
        search_str, search_str],:order=>order_str,:page => params[:page]
    end
  end
end
