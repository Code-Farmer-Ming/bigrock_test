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
  
  test " related jobs" do
    job2 = jobs(:two)
    job3 =jobs(:three)
    assert_difference " @job.related_jobs.count",2 do
      job2.apply_job(JobApplicant.new(:applicant_id=>users(:two).to_param))
      job3.apply_job(JobApplicant.new(:applicant_id=>users(:two).to_param))
      
      @job.apply_job(JobApplicant.new(:applicant_id=>users(:three).to_param))
      job3.apply_job(JobApplicant.new(:applicant_id=>users(:three).to_param))
    end
    assert_equal job3, @job.related_jobs.first

  end

  test "create job log" do
    job = Job.new
    job.title="job title"
    job.type_id = 1
    job.state_id = 1
     job.city_id = 1
    job.owner = companies(:one)
    job.create_user = users(:one)
    job.job_description ="job description"
    job.end_at = Time.now
    assert_difference("job.logable_log_items.count",2) do
      job.save!
    end
  end

end
