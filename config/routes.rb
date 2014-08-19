Linkcontrol::Application.routes.draw do
  resource :outgoing_stream
  resource :incoming_stream

  root :to => 'welcome#index'
end
