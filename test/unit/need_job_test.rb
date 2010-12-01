require 'test_helper'

class NeedJobTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end

  test "add skill" do
    need_job = NeedJob.new()
    need_job.poster = users(:one)
    need_job.save()
    assert_difference("need_job.skills.count",2) do
      need_job.add_skills("test test2")
    end
  end

  test "skill list" do
    need_job = NeedJob.new()
    need_job.poster = users(:one)
    need_job.save()
    assert_difference("need_job.skills.count",2) do
      need_job.skill_list="test test2"
    end
    assert_equal "test test2", need_job.skill_list
    assert_difference("need_job.skills.count",-1) do
      need_job.skill_list="test"
    end

  end
  test "skill text" do
    need_job = NeedJob.new()
    need_job.poster = users(:one)
    need_job.skill_text="test test2"
    
    assert_difference("need_job.skills.count",2) do
      need_job.save()
    end
    assert_equal "test test2", need_job.skill_text
    assert_difference("need_job.skills.count",-1) do
      need_job.skill_text="test"
      need_job.save()
    end
  end
  
  test "similar need jobs" do
    need_job = NeedJob.new()
    need_job.poster = users(:one)
    need_job.title ="job one"
    need_job.skill_text = "test test1"
    need_job.save()

    need_job_2 = NeedJob.new()
    
    need_job_2.poster = users(:two)
    need_job_2.title ="job two"
    need_job_2.skill_text = "test test1"
    need_job_2.save()

    assert_equal need_job_2.id, need_job.similar_need_jobs.first.id

  end
  
  test "create log" do
    need_job = NeedJob.new()
    need_job.poster = users(:one)
    need_job.title ="job one"
    need_job.skill_text = "test test1"
    assert_difference("need_job.logable_logs.count") do
      need_job.save!
    end
    assert_difference("need_job.logable_logs.count",-1) do
      need_job.destroy
    end
  end
end
