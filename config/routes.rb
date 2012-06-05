OaiRepository::Engine.routes.draw do

  get "services/show"

  root :to => "services#show"

end
