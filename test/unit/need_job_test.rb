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
end
