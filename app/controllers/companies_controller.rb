#company judge 环境和 薪水 是否综合到一个参数！！！！
class CompaniesController < ApplicationController
  include ActionView::Helpers::TextHelper
  before_filter :check_login?,:except=>[:show,:index,:news,:show_by_tag,:all_tags,:tags,:search]
  before_filter :find_company,:only=>[:show,:edit,:update,:destroy,:logs,:employee_list,:jobs]
  # GET /companies
  # GET /companies.xml    
  def index
    @page_title="公司 首页"
    @page_description="公司信息的首页,提供更真实的公司环境和待遇评价,列出行业分类和公司标签"
    @newly_companies = Company.newly.all(:limit=>4)
    @hot_tags = Company.all_tags(:limit=>20)
    respond_to do |format|
      format.html{} # index.html.erb
      format.xml  { render :xml => @companies }
    end
  end
  # GET /companies/1
  # GET /companies/1.xml
  def show
    @page_title=" #{@company.name}"
    @page_description =  truncate(@company.description,:length=>100)
    @page_keywords = @company.tag_list + " 评价信息,话题,员工 相关公司 招聘"
    respond_to do |format|
      format.html {} # show.html.erb
      format.xml  { render :xml => @company }
    end
  end
  # GET /companies/new
  # GET /companies/new.xml
  def new
    @page_title=" 创建公司信息"
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
    @page_title=" 编辑 #{@company.name} 信息"
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
        format.html {flash[:notice] = '公司创建成功！'
          redirect_to(@company) }
        format.js  {}
      else
        format.html {
          flash[:notice] = @company.errors.full_messages.to_s
          render :action => "new" }
        format.js  {}
      end
    end
  end
  # PUT /companies/1
  # PUT /companies/1.xml
  def update
    if params[:uploaded_file_id] && params[:uploaded_file_id]!=""
      @company.icon = CompanyIcon.find(params[:uploaded_file_id])
    end
    @company.last_edit_user = current_user
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
    @company.destroy
    respond_to do |format|
      format.html { redirect_to(companies_url) }
      format.xml  { head :ok }
    end
  end


  def logs
    @page_title=" #{@company.name} 动态记录信息"
    if params[:type]=="" || params[:type]==nil || params[:type]=="all"
      @log_items = @company.log_items.paginate :page => params[:page]
    else
      @log_items = @company.log_items.paginate_by_log_type params[:type], :page => params[:page]
    end
  end
  
  def employee_list
    @page_title=" #{@company.name} 员工"
    @page_description= "当前员工和曾经的员工信息"
    if params[:type].blank? || params[:type]=='current' then
      @employees = @company.current_employees.paginate(:joins=>" join resumes on resumes.user_id=users.id",
        :conditions=>["resumes.user_name like ?",'%'+ (params[:search] || '') +'%'],:select=>"users.*",:order=>"users.created_at",:page => params[:page])
    else
      @employees = @company.pass_employees.paginate   :joins=>" join resumes on resumes.user_id=users.id",
        :conditions=>["resumes.user_name like ?",'%'+ (params[:search] || '') +'%'],:select=>"users.*",:order=>"users.created_at",:page => params[:page]
    end
  end

  def jobs
    search = "%#{params[:search]}%"
    @jobs = @company.jobs.paginate(:conditions=>["title like ? or
                job_description like ? or skill_description like ?",
        search,search,search],:order=>"created_at desc",:page=>params[:page])
    @page_title = @company.name + " 的职位"
  end
 
  def search()
    @page_title=" 公司信息搜索 #{params[:search]}"
    @page_description=",搜索符合关键字的的公司"
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

  protected
  
  def find_company
    @company = Company.find(params[:id])
  end
end
