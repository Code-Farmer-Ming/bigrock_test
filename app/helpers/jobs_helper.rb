module JobsHelper
  #产生job 和need job的"省 市"的搜索 链接
  def link_to_state_city(job_or_need_job)
    "#{link_to(job_or_need_job.state.name,
    {:action=>'search',:state_id=>job_or_need_job.state_id})}" + (job_or_need_job.city ? ".#{link_to(job_or_need_job.city.name,
      {:action=>'search',:state_id=>job_or_need_job.state_id,:city_id=>job_or_need_job.city_id})}" :"")
  end
end
