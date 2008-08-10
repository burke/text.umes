ActionController::Routing::Routes.draw do |map|
  map.resources :books

  map.root :controller => 'books'

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
