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
  test "read" do
    job_one = jobs(:one)
    job_applicant = JobApplicant.new(:applicant_id=>users(:two).id.to_s)
    job_one.apply_job(job_applicant)
    job_applicant.reload()
    assert_difference "job_applicant.applicant_user.unread_msgs.size" do
      job_applicant.read
    end
    assert_equal true, job_applicant.is_read
    #第二次读取不发送 消息
    assert_difference "job_applicant.applicant_user.unread_msgs.size",0 do
      job_applicant.read
    end
  end
  
  test "create" do
    job_one = jobs(:one)
    job_applicant = JobApplicant.new(:applicant_id=>users(:two).id.to_s)
    assert_difference "job_one.poster.unread_msgs.size" do
      job_one.apply_job(job_applicant)
    end
  end

  test "recommend create" do
    job_one = jobs(:one)
    job_applicant = JobApplicant.new(:recommend_id=>users(:three).id.to_s, :applicant_id=>users(:two).id.to_s)
    assert_difference "job_applicant.applicant_user.unread_msgs.size" do
      assert_difference "job_one.poster.unread_msgs.size" do
        job_one.apply_job(job_applicant)
      end
    end
  end

end
