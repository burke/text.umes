ActionController::Routing::Routes.draw do |map|

  map.resources :books, :collection => {:list => :any, :search => :any}
  
  map.root :controller => 'books'

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
