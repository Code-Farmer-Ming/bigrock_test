require 'test_helper'

class ResumeTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "sub_pass" do
    resume_one = resumes(:one)
    pass=Pass.new
    pass.company_id=1
    pass.resume_id=resume_one
    pass.user = users(:one)
    pass.save!
    pass.reload
    sub_pass= resume_one.passes.find(pass)
    assert_not_nil(sub_pass)
    assert_equal(sub_pass,pass)
  end
  test "sub_education" do
    resume_one = resumes(:one)
    edu= Education.new()
    edu.school_name="sjtu"
    edu.description="description"
    resume_one.educations<<edu
    resume_one.save()
    assert_not_nil resume_one.educations.find(edu)

    
  end
  test "sub_speciality" do
    resume_one = resumes(:one)
    spe= Speciality.new()
    spe.name="sjtu"
    spe.description  ="description"
    resume_one.specialities<<spe
    resume_one.save()
    assert_not_nil resume_one.specialities.find(spe)
    resume_one.specialities.destroy(spe)
    assert_equal resume_one.specialities.find_all_by_id(spe).size,0

  end

  test "resume_yokemate" do
    resume = resumes(:one)
    assert_equal 1, resume.yokemates.size

    resume.passes << Pass.new(:user_id=>1,:company_id=>3,:begin_date=> "2009-06-01",:end_date=> "2009-06-02")
    assert_equal 2, resume.yokemates.size

  end
end
