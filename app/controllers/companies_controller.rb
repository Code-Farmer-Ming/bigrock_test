
class CompaniesController < ApplicationController
  before_filter :check_login?,:except=>[:show,:index,:news,:show_by_tag,:all_tags,:tags,:search]

  # GET /companies
  # GET /companies.xml    
  def index
    @page_title="公司 首页"
    @newly_companies = Company.all(:limit=>3,:order=>"created_at desc")
    @salary_best_companies =  Company.all(:limit=>3,:order=>"salary_value/company_judges_count desc")
    @condition_best_companies =  Company.all(:limit=>3,:order=>"condition_value/company_judges_count desc")
    @integration_best_companies =  Company.all(:limit=>3,:order=>"salary_value/company_judges_count desc ,condition_value/company_judges_count desc ")
    @hot_tags = Company.all_tags(:limit=>20)
    respond_to do |format|
      format.html{} # index.html.erb
      format.xml  { render :xml => @companies }
    end
  end
  # GET /companies/1
  # GET /companies/1.xml
  def show
    @company = Company.find(params[:id])
    respond_to do |format|
      format.html {} # show.html.erb
      format.xml  { render :xml => @company }
    end
  end
  # GET /companies/new
  # GET /companies/new.xml
  def new
    @company = Company.new
    @company.name = params[:company] ? params[:company][:name] : ""
    @company_icon= CompanyIcon.new
    #    @company_judge = CompanyJudge.new
    respond_to do |format|
      format.html {} # new.html.erb
      format.js {}# new.js.erb
      format.xml  { render :xml => @company }
    end
  end
  # GET /companies/1/edit
  def edit
    @company = Company.find(params[:id])
    @company_icon= CompanyIcon.new
    if !@company.all_employees.exists?(current_user)
      flash[:notice] = "必须是公司的员工才能修改公司资料"
      redirect_to  @company
    end
  end
  # POST /companies
  # POST /companies.xml
  def create
    @company = Company.new(params[:company])
    @company.create_user =current_user
    if params[:uploaded_file_id] && params[:uploaded_file_id]!=""
      @company.icon = CompanyIcon.find(params[:uploaded_file_id])
    end
    respond_to do |format|
      if  @company.save
        format.html {flash[:notice] = 'Company was successfully created.'
          redirect_to(@company) }
        format.xml  { render :xml => @company, :status => :created, :location => @company }
        format.js  {}
      else
        format.html {
          flash[:notice] = @company.errors.full_messages.to_s
          render :action => "new" }
        format.xml  { render :xml => @company.errors, :status => :unprocessable_entity }
        format.js  {}
      end
    end
  end
  # PUT /companies/1
  # PUT /companies/1.xml
  def update
    @company = Company.find(params[:id])
    if params[:uploaded_file_id] && params[:uploaded_file_id]!=""
      @company.icon = CompanyIcon.find(params[:uploaded_file_id])
    end
    respond_to do |format|
      if  @company.update_attributes(params[:company])  
        format.html { redirect_to(@company) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @company.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /companies/1
  # DELETE /companies/1.xml
  def destroy
    @company = Company.find(params[:id])
    @company.destroy
    respond_to do |format|
      format.html { redirect_to(companies_url) }
      format.xml  { head :ok }
    end
  end


  def logs
    @company = Company.find(params[:id])
    if params[:type]=="" || params[:type]==nil || params[:type]=="all"
      @log_items = @company.log_items.paginate :page => params[:page]
    else
      @log_items = @company.log_items.paginate_by_log_type params[:type], :page => params[:page]
    end
  end
  
  def employee_list
    @company = Company.find(params[:id])
    if params[:type].blank? || params[:type]=='current' then
      @employees = @company.current_employees.paginate  :conditions=>"nick_name like '%#{params[:search]}%'", :page => params[:page]
    else
      @employees = @company.pass_employees.paginate  :conditions=>"nick_name like '%#{params[:search]}%'",:page => params[:page]
    end
  end
 
  def search()
    order_str =  params[:salary_order] && !params[:salary_order].blank? ? "salary_value/company_judges_count "+ (params[:salary_order].to_s=='asc' ? 'asc' : 'desc') : nil

    if !order_str
      order_str =  params[:condition_order] && !params[:condition_order].blank? ? "condition_value/company_judges_count "+ (params[:condition_order].to_s=='asc' ? 'asc' : 'desc') : nil
    else
      order_str +=  params[:condition_order] && !params[:condition_order].blank? ? ",condition_value/company_judges_count "+ (params[:condition_order].to_s=='asc' ? 'asc' : 'desc') : ""
    end
    @companies = Company.paginate :all,
      :conditions=>["(name like ? or ?='') and (industry_id=? or ?=0) and (company_type_id=? or ?=0)"+
        " and (company_size_id=? or ?=0) and (state_id=? or ?=0) and (city_id=? or ?=0) ",
      '%'+params[:search].to_s+'%', params[:search],params[:industry_id],params[:industry_id] || 0,
      params[:company_type_id],params[:company_type_id] || 0,
      params[:company_size_id] ,params[:company_size_id] || 0,
      params[:state_id] ,params[:state_id] || 0,
      params[:city_id],params[:city_id] || 0
    ], :order=> order_str,:page => params[:page]
  end
end
