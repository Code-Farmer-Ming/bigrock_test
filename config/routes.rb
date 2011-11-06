ActionController::Routing::Routes.draw do |map|
  map.resources :broadcasts,:except=>[:new,:create],:member=>{:ignore=>:post,:redo=>:post}

  map.resources :colleagues
  map.resources :publishs
  map.resources :apply_colleagues,:member=>{:accept=>:post}
  map.resources :add_friend_applications,:member=>{:accept=>:post}
    
  map.resources :log_items
  
  map.resources :need_jobs,:collection=>{:batch_destroy=>[:delete],:search=>:get},:only=>[:search,:show,:index,:destroy,:edit] do |need_job|
    need_job.resources :broadcasts ,:only=>[:new,:create]
  end

  map.resources :groups,:member=>{:invite_join=>[:get,:post]},
    :collection=>{:search=>:get} do |groups|
    groups.resources :topics, :collection=>{:search=>:get}  

    groups.resources :tags,:only=>[:index]
    #    groups.resources :recommends
    groups.resources :members,:member=>{:to_root=>:post,:to_manager=>:post,:to_normal=>:post}
    groups.resources :add_group_applications,:member=>{:accept=>:post},:collection=>{:apply=>[:get,:post]}
  end

  map.resources :recommends
  map.resources :news,:only=>[:index]
  map.resources :attachments

  
  map.resources :companies,
    :member=>{:employee_list=>:get,     
    :logs=>:get,
    :jobs=>:get},
    :collection=>{:search=>:get} do |companies|
    companies.resources :company_judges
    companies.resources :jobs,:only=>[:new,:create]
    companies.resources :tags,:only=>[:index]
    companies.resources :topics ,:collection=>{:search=>:get}
  end
  map.resource  :news,:collection=>{:search=>:get}   do |news|
    news.resources :comments,:member=>{:up=>:post,:down=>:post}
  end
  map.resources :accounts,:controller=>"account",:only=>[:index]
  map.resource :account,:controller=>"account",
    :collection =>{ :forget_password=>:get,
    :set_resume_visibility=>[:get,:put],
    :reset_password=>:get,
    :set_signature=>[:post, :put],
    :set_user_state=>:post,
    :logout=>:get,
    :login=>:get,
 
    :attention=>[:post],
    :destroy_attention=>[:delete],
    :check_email=>:get,
    :judged_colleagues=>:get,
    :unjudge_colleagues=>:get,
    :judged_company=>:get,
    :unjudge_company=>:get,
    :published_jobs=>:get,
    :published_job_applicants=>:get,
    :add_job=>:get,
    :follow_logs=>:get,
    :need_jobs=>:get} do |account|
    account.resource :setting,:collection=>{ :auth=>[:get,:put],
      :base_info=>[:get,:put],
      :alias=>[:get,:put],
      :password=>[:get,:put]}
    account.resource :base_info
    account.resources :judges,:except=>[:index]
    account.resources :msgs ,:collection=>{},:member=>{:msg_response=>:put}
 
    account.resources :join_group_invites ,:member=>{:accept=>:post}
    account.resources :need_jobs,:collection=>{:batch_destroy=>[:delete]},:except=>[:show,:index,:edit,:destroy] 
  end

  map.resources :users,:collection =>{},
    :member=>{:colleague_list=>:get, :logs=>:get,:following=>:get,:groups=>:get} do |users|
    users.resources :judges,:only=>[:index]
    users.resources :colleagues,:collection=>{:cancel=>:post} #同事

    users.resources :tags,:only=>[:index]
    users.resources :topics
    #    users.resources :base_infos
    users.resources :passes,:member=>{:available_colleagues=>:get,:send_invite=>:post,
      :invite_join=>:get,:send_invite_join=>:post}
    users.resources :friends
    users.resources :specialities
    users.resources :educations
  end
  map.resources :tags
  map.resources :topics ,:only=>[:index,:show],:member=>{:up=>:post,:down=>:post}  do |topics|
    topics.resources :comments,:member=>{:up=>:post,:down=>:post}
  end
  map.resources :jobs ,:collection=>{:batch_destroy=>[:delete],:search=>:get}, :except=>[:new,:create] do |jobs|
    jobs.resources :comments,:member=>{:up=>:post,:down=>:post}
    jobs.resources :applicants,:controller=>"JobApplicants",
      :member=>{:recommend_talent=>:get}
    jobs.resources :broadcasts ,:only=>[:new,:create]
  end
  map.resources :job_applicants ,:collection=>{:batch_destroy=>[:delete]},:only=>[:batch_destroy]
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "account",:action=>"index"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect 'users/:id/resumes',:controller => 'users', :action=>'show'
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
 
end
