class CompanyJudgesController < ApplicationController
  before_filter :check_login?,:except=>[:auto_complete_for_tag]

  def new
    @company_judge= CompanyJudge.new
    @company_judge.company = Company.find(params[:company_id])
    respond_to do |format|
      format.html {}# new_judge.html.erb
      format.js { }# new_judge.js.erb
      format.xml  { render :xml => @company_judge }
    end
  end
  #这个 new_form 显示 form 用 参数传递给 new
  def new_form
    company = Company.find(params[:company_id])
    respond_to do |format|
      format.html { redirect_to :action=>:new,:company_id=>params[:company_id] }
      format.js  {

        render :update do |page|
          if    company.all_employees.exists?(current_user)
            page << "Lightbox.show('/company_judges/new?company_id=#{params[:company_id]}')"
          else
            flash.now[:notice] = "必须是公司的员工才能评价"
            page["flash_msg"].replace_html render(:partial=>"comm_partial/flash_msg")
          end
        end
      }
    end
  end

  def create
    @company = Company.find(params[:company_id])
    @judge = CompanyJudge.new(params[:company_judge])
    current_user.tag_something(@company, params[:user_tags])
    @judge.user = current_user

    respond_to do |format|
      if  (@company.judges << @judge)
        format.html { redirect_to(@judge) }
        format.xml  { render :xml => @judge, :status => :created, :location => @judge }
        format.js  {}
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @judge.errors, :status => :unprocessable_entity }
        format.js  {
          flash.now[:error] = "添加失败,关闭后再重试！"
          render :update do |page|
            page["lightbox_msg"].replace_html render(:partial=>"comm_partial/flash_msg")
          end
        }
      end
    end
  end

  def edit
    @company_judge = CompanyJudge.find(params[:id])
    respond_to do |format|
      format.js {}
    end
  end

  def update
    @company_judge = CompanyJudge.find(params[:id])
    current_user.tag_something(@company_judge.company, params[:user_tags])

    respond_to do |format|
      if @company_judge.update_attributes(params[:company_judge])
        format.js {}
      end
    end
  end
  def destroy
    @company_judge = current_user.judged_companies.find(params[:id])
    @company_judge.destroy
    current_user.remove_something_tag(@company_judge.company)
   
    respond_to do |format|
      format.xml  { head :ok }
      format.js {}
    end
  end
  
  def index
    @company=Company.find(params[:company_id])
    @company_jugdes =   @company.judges.paginate :page => params[:page]
  end

  def auto_complete_for_tag
    @items =  Tag.find(:all,
      :conditions =>" lower(name) like '%#{params[:user_tags].downcase}%' ",
      :select=>"distinct name" )
    render :inline => "<%= auto_complete_result @items, 'name', '#{params[:user_tags]}' %>"
  end

end
