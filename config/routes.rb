ActionController::Routing::Routes.draw do |map|
  map.resource :outgoing_stream
  map.resource :incoming_stream
  
  map.root :controller => "welcome"
end
