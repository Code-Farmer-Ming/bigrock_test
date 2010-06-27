require 'test_helper'

class JobApplicantTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "try destroy" do
    job_one = jobs(:one)
    job_applicant = JobApplicant.new(:applicant_id=>users(:two).id.to_s)
    assert_difference "JobApplicant.count",1 do
      job_one.apply_job(job_applicant)
    end
    job_applicant.reload

    assert_difference "JobApplicant.count",0 do
      assert_difference "users(:one).published_job_applicants.count",-1 do
        job_applicant.try_destroy(users(:one))
      end
    end

    assert_difference "users(:two).job_applicants.count",-1 do
      assert_difference "JobApplicant.count",-1 do
        job_applicant.try_destroy(users(:two))
      end
    end
  end
end
