require 'test_helper'

class CompanyTest < ActiveSupport::TestCase

  test "change_judge" do
    company = Company.find(4)
    judge = CompanyJudge.new(:salary_value=>3,:condition_value=>4,:description=>"说明",:user_id=>1)
 
    company.judges << judge
   

    company.reload()
    assert_equal 3,company.salary_value
    assert_equal 4,company.condition_value
    assert_equal 1,company.company_judges_count
    
    assert_equal 0, company.salary_judge_count(1)
    assert_equal 0, company.salary_judge_count(2)
    assert_equal 1, company.salary_judge_count(3)
    assert_equal 0, company.salary_judge_count(4)
    assert_equal 0, company.salary_judge_count(5)

    assert_equal 0, company.condition_judge_count(1)
    assert_equal 0, company.condition_judge_count(2)
    assert_equal 0, company.condition_judge_count(3)
    assert_equal 1, company.condition_judge_count(4)
    assert_equal 0, company.condition_judge_count(5)
 
    #修改 薪水评价值
    judge.update_attribute("salary_value", 1)
    judge.update_attribute("condition_value", 2)
    judge.update_attribute("description", "描述")
    company.reload()
    assert_equal 1,company.salary_value
    assert_equal 2,company.condition_value
 
    #删除 评价
    judge.destroy
    company.reload()
    assert_equal 0,company.salary_value
    assert_equal 0,company.condition_value
  end

  test "version" do
    company = Company.find(1)
    company.versions.destroy_all()
    company.update_attribute("fax", "change fax")
    assert_equal "change fax",company.fax
    assert_equal 0, company.versions.size

    company.update_attribute("description", "change description")
    assert_equal "change description",company.description
    company.reload()
    assert_equal 1, company.versions.size
  end
  test "employee" do
    company = Company.find(1)
    assert_equal 2, company.all_employees.size
    assert_equal 2, company.current_employees.size
    assert_equal 0, company.pass_employees.size

    Pass.create!(:company=>company,:title=>"职员123",:user_id=>4,:begin_date=>15.hours.ago.to_s(:db),:end_date=>1.hours.ago.to_s(:db))
    company.reload
    assert_equal 3,company.all_employees.size
    assert_equal 1, company.pass_employees.size
    assert_equal 2, company.current_employees.size

    company.passes <<  Pass.new(:title=>"职员",:user_id=>5,:begin_date=>15.hours.ago.to_s(:db),:end_date=>Time.now.to_s(:db),:is_current=>true)
    company.reload()
    assert_equal 4,company.all_employees.size
    assert_equal 1, company.pass_employees.size
    assert_equal 3, company.current_employees.size
  end

  test "company_tags" do
    # fixtures 文件里 company 1 ,2 各包含两个标签
    company = Company.find(1)
    Tagging.destroy_all
    assert_equal 0,company.all_tags.size
    assert_equal 0,Company.all_tags.size
    
    user_one = users(:one)
    user_one.tag_something(company, "伟大的公司")
    assert_equal 1,company.all_tags.size
    assert_equal 1,Company.all_tags.size
    
    user_one.tag_something(company, "")
    company.reload
    assert_equal 0,company.all_tags.size
    assert_equal 0,Company.all_tags.size
  end
  
  test "company_related_tags" do
    company = Company.find(1)
    company_two = Company.find(2)
    user_one = users(:one)
    user_two = users(:two)

    user_one.tag_something(company, "伟大的公司 好公司 大公司")
    assert_equal 3,company.all_tags.size
    assert_equal 2, Company.find_related_tags("伟大的公司").size
    assert_equal ["大公司","好公司"],Company.find_related_tags("伟大的公司").collect{|p| p.name}
    
    user_one.tag_something(company_two, "伟大的公司 好公司 新公司")
    #company_two 有user id 1,2 两个人的评论 现在 1的评论更新了 只剩下 2的一个评论 所以 3+1
    assert_equal 4,company_two.all_tags.size

    user_two.tag_something(company_two, "不赖的公司")
    assert_equal 4, Company.find_related_tags("伟大的公司").size
    assert_equal ["好公司","不赖的公司","大公司","新公司"],Company.find_related_tags("伟大的公司").collect{|p| p.name}
  end
  #  #相关的公司
  #  test "related_company" do
  #    company = Company.find(1)
  #    company_two = Company.find(2)
  #    company_three = Company.find(3)
  #
  #    assert company.related_companies(5).index(companies(:two))
  #    assert_equal 1, company.related_companies(-1).size
  #
  #    assert_equal 1, company_two.related_companies(-1).size
  #    assert_equal 2, company_three.related_companies(-1).size
  #  end
  #测试 真实度高的用户  creditability_value >= 4为真实度高的用户
  test "hight creditability user" do
    Judge.delete_all()
    company_one = companies(:one)
    user_one = users(:one)
    user_two = users(:two)

    judge= Judge.new()
    judge.creditability_value = 5
    judge.user = user_two
    judge.judger = user_one
    pass = user_two.passes.find(2)

    pass.judges << judge
    assert pass.save
    pass.reload
   
    company_one.reload
    assert_equal 1,pass.judges.size
    assert_equal 1,pass.judges_count
    assert pass.creditability_value>=4
    assert pass.is_current
    assert_equal 1, company_one.higher_creditability_employees.size
    assert_equal user_two, company_one.higher_creditability_employees[0]

  end
  test "add job" do
    company = Company.find(1)
    pass = users(:one).current_passes.first
    #提升资料真实度 为4星
    pass.creditability_value =4
    pass.save
    job = Job.new(:title=>"new job",:description=>"job descriptions",:city_id=>1,:state_id=>1,:type_id=>0,:end_at=>DateTime.now)
    assert_difference("company.jobs.size", 1) do
      company.add_job(job,users(:one))
    end
  end
  #资料真实度不够 暂时不检测 真实度
  test "add job without higher creditability value" do
    company = Company.find(1)
    job = Job.new(:title=>"new job",:description=>"job descriptions",:city_id=>1,:state_id=>1,:type_id=>0,:end_at=>DateTime.now)
    assert_difference("company.jobs.size", 1) do
      company.add_job(job,users(:two))
    end
  end
end
