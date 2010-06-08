require 'test_helper'

class JobTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def setup
    @job = jobs(:one)
  end

  test "apply job" do
    
    applicant = JobApplicant.new(:applicant_user=>users(:one),:memo=>'I wanna applicat the job')
    assert_difference("@job.applicants.count",1) do
      @job.apply_job applicant
    end
  end
  test "apply job with multi-applicant" do
     applicant = JobApplicant.new(:applicant_user_ids=>"1 2 3",:recommend_user=>users(:foru),:memo=>'I wanna applicat the job')
     assert_difference("@job.applicants.count",3) do
      @job.apply_job applicant
    end
  end
end
