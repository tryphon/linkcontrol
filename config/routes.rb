ActionController::Routing::Routes.draw do |map|

  map.resource :link_stream
  
  map.root :controller => "welcome"

end
