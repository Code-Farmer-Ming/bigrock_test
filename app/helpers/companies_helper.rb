module CompaniesHelper
  def company_short_title(company) 
    (company.industry ? link_to(h(company.industry.name),:controller=>:companies,:action=>:search,:industry_id=>company.industry_id) : '')   +
      "&nbsp;.&nbsp;"+ (company.company_type ? link_to(h(company.company_type.name),:controller=>:companies,:action=>:search,:company_type_id=>company.company_type_id) : "") +
      "&nbsp;.&nbsp;"+  (company.company_size ? link_to(h(company.company_size.name),:controller=>:companies,:action=>:search,:company_size_id=>company.company_size_id) : '')
  end

  def options_for_salary_order(default_state)
    options_for_select([['不排序',""],["按待遇升序",'asc'],["按待遇降序",'desc']],default_state)
  end

  def options_for_condition_order(default_state)
    options_for_select([['不排序',""],["按环境升序",'asc'],["按环境降序",'desc']],default_state)
  end

  def options_for_industry(default_id)
    options_for_select([['所有行业',0]]+Industry.select_options(),:selected=>default_id.to_i)
  end
  
  def options_for_company_type(default_id)
    options_for_select([['所有类型',0]]+CompanyType.select_options,default_id.to_i)
  end

  def options_for_company_size(default_id)
    options_for_select([['所有规模',0]]+CompanySize.select_options,default_id.to_i)
  end

  def options_for_state(default_state)
    options_for_select([['所有省',0]]+State.all.collect {|p| [p.name,p.id]},default_state.to_i)
  end
  
  def options_for_city(state_id,default_city)
    options_for_select([['所有市',0]]+
        City.find_all_by_state_id(state_id.to_i).collect{|q| [q.name,q.id] } ,default_city.to_i)
  end

  def options_for_since_day(default_id)
    options_for_select([['所有',0],["今天",1],["三天内",3],["一周内",7],["一个月内",30]],default_id.to_i)
  end

  def options_for_job_type(default_id)
     options_for_select([['所有',0]]+Job.types,default_id.to_i)
  end
end
