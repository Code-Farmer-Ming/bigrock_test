ActionController::Routing::Routes.draw do |map|
 
  map.resources :groups,:member=>{:invite_join=>[:get,:post]},
    :collection=>{:search=>:get} do |groups|
    groups.resources :topics, :collection=>{:search=>:get}  do |topics|
      topics.resources :comments
    end
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
    :logs=>:get },
    :collection=>{:search=>:get} do |companies|
    companies.resources :company_judges
    companies.resources :tags,:only=>[:index]
 
    companies.resources :topics ,:collection=>{:search=>:get} do |topics|
      topics.resources :comments
    end
    companies.resources :news,:collection=>{:search=>:get}   do |news|
      news.resources :comments
    end
  end
  
  map.resource :account,:controller=>"account",
    :collection =>{ :forget_password=>:get,
    :set_resume_visibility=>[:get,:put],
    :reset_password=>:get,
    :set_user_auth=>[:get,:put],
    :set_base_info=>[:get,:put],
    :logout=>:get,
    :login=>:get,
    :add_friend=>[:post],
    :destroy_friend=>[:delete],
    :attention=>[:post],
    :destroy_attention=>[:delete],
    :check_email=>:get,
    :follow_logs=>:get} do |account|
    account.resources :msgs ,:collection=>{},:member=>{:msg_response=>:put}
    account.resources :add_friend_applications,:member=>{:accept=>:post},:collection=>{:apply=>[:get,:post]}
    account.resources :join_group_invites ,:member=>{:accept=>:post}
  end

  map.resources :users,:collection =>{},
    :member=>{:yokemate_list=>:get, :logs=>:get,:friends=>:get,:groups=>:get} do |users|
    users.resources :judges,:only=>[:index]
    users.resources :tags,:only=>[:index]
    users.resources :topics
    users.resources :resumes  do |resumes| #,:member=>{:new_pass=>:get}
      resumes.resources :passes,:member=>{:available_yokemates=>:get,:send_invite=>:post} do |passes|
        passes.resources :work_items
        passes.resources :judges
      end
      resumes.resources :specialities
      resumes.resources :educations
    end
  end
  map.resources :tags
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
  map.root :controller => "account",:action=>"show"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
