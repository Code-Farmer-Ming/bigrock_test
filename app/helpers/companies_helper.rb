module CompaniesHelper
  def company_short_title(company) 
  (company.industry ? link_to(h(company.industry.name),:controller=>:companies,:action=>:search,:industry_id=>company.industry_id) : '')   +
   "&nbsp;.&nbsp;"+ (company.company_type ? link_to(h(company.company_type.name),:controller=>:companies,:action=>:search,:company_type_id=>company.company_type_id) : "") +
     "&nbsp;.&nbsp;"+  (company.company_size ? link_to(h(company.company_size.name),:controller=>:companies,:action=>:search,:company_size_id=>company.company_size_id) : '')
   end
  
end
