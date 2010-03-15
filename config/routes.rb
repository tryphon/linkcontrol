ActionController::Routing::Routes.draw do |map|

  map.resource :link_stream
  map.resource :save_point
  
  map.root :controller => "welcome"

end
