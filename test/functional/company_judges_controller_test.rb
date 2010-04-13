require 'test_helper'

class CompanyJudgesControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  def setup
    login_as(users(:one))
  end

  test "new" do
    xhr :get,:new,:company_id=>1
    assert_response :success
  end
  
  test "create" do
    xhr :post,:create,:company_id=>1,:company_judge=>{:salary_value=>1,
      :condition_value=>1,:anonymous=>0,
      :description=>"okk"
    },:my_tags=>"好公司"
    assert(companies(:one).judges.exists?(assigns(:judge)),"judge failed")
    assert(!companies(:one).all_tags(:conditions=>"name='好公司'").size.zero?,"tag failed")
  end

  test "edit" do
    xhr :post,:create,:company_id=>1,:company_judge=>{:salary_value=>1,
      :condition_value=>1,:anonymous=>0,
      :description=>"okk"
    },:my_tags=>"好公司"
    xhr :get,:edit,:company_id=>1,:id=>assigns(:judge)
    assert_response :success
  end
  
  test "update" do
    xhr :post,:create,:company_id=>1,:company_judge=>{:salary_value=>1,
      :condition_value=>1,:anonymous=>0,
      :description=>"okk"
    },:my_tags=>"好公司"
 
    xhr :post,:update,:company_id=>1,:id=>assigns(:judge),:company_judge=>{:salary_value=>1,
      :condition_value=>1,:anonymous=>0,
      :description=>"okk"
    },:my_tags=>"新公司"
    assert(companies(:one).all_tags(:conditions=>"name='好公司'").size.zero?,"tag failed")
    assert(!companies(:one).all_tags(:conditions=>"name='新公司'").size.zero?,"tag failed")
  end
  
  test "destroy" do
    xhr :post,:create,:company_id=>1,:company_judge=>{:salary_value=>1,
      :condition_value=>1,:anonymous=>0,
      :description=>"okk"
    },:my_tags=>"好公司"
    
    xhr :delete,:destroy,:company_id=>1,:id=>assigns(:judge)
    assert(!companies(:one).judges.exists?(assigns(:judge)),"judge failed")
    assert(companies(:one).all_tags(:conditions=>"name='新公司'").size.zero?,"tag failed")
  end
end
